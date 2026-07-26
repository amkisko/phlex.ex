defmodule Phlex.SGML.State do
  @moduledoc """
  Rendering state for Phlex components.

  Manages the buffer, rendering flags, fragments, and cache capture contexts.
  """

  defstruct [
    :buffer,
    :should_render,
    :user_context,
    :fragments,
    :fragment_depth,
    :cache_stack,
    :capturing,
    :output_buffer,
    :fragment_map,
    :content_block,
    :rendering
  ]

  @type fragment_meta :: {non_neg_integer(), non_neg_integer() | nil, list()}
  @type cache_entry :: %{map: map(), frozen_prefix_bytes: non_neg_integer()}

  @type t :: %__MODULE__{
          buffer: IO.chardata(),
          should_render: boolean(),
          user_context: map(),
          fragments: MapSet.t() | nil,
          fragment_depth: non_neg_integer(),
          cache_stack: [cache_entry()],
          capturing: boolean(),
          output_buffer: IO.chardata(),
          fragment_map: map(),
          content_block: function() | nil,
          rendering: boolean()
        }

  @doc """
  Creates a new state with default values.
  """
  def new(opts \\ []) do
    %__MODULE__{
      buffer: [],
      should_render: true,
      user_context: Keyword.get(opts, :user_context, %{}),
      fragments: Keyword.get(opts, :fragments),
      fragment_depth: 0,
      cache_stack: [],
      capturing: false,
      output_buffer: Keyword.get(opts, :output_buffer, []),
      fragment_map: %{},
      content_block: Keyword.get(opts, :content_block),
      rendering: false
    }
  end

  @doc """
  Checks if the component should render.
  """
  def should_render?(%__MODULE__{fragments: nil}), do: true
  def should_render?(%__MODULE__{fragment_depth: depth}) when depth > 0, do: true
  def should_render?(_), do: false

  @doc """
  Increments fragment depth unconditionally.
  """
  def begin_fragment(%__MODULE__{fragment_depth: depth} = state) do
    %{state | fragment_depth: depth + 1}
  end

  @doc """
  Begins a named fragment: updates selective-render depth and cache offsets.
  """
  def begin_fragment(%__MODULE__{} = state, id) do
    state
    |> maybe_increment_fragment_depth(id)
    |> cache_begin_fragment(id)
  end

  @doc """
  Decrements fragment depth unconditionally.
  """
  def end_fragment(%__MODULE__{fragment_depth: depth} = state) when depth > 0 do
    %{state | fragment_depth: depth - 1}
  end

  def end_fragment(%__MODULE__{} = state), do: state

  @doc """
  Ends a named fragment: finalizes cache length and clears selective-render membership.
  """
  def end_fragment(%__MODULE__{} = state, id) do
    state
    |> cache_end_fragment(id)
    |> maybe_decrement_fragment_depth(id)
    |> maybe_delete_fragment(id)
  end

  defp maybe_increment_fragment_depth(%__MODULE__{fragments: nil} = state, _id), do: state

  defp maybe_increment_fragment_depth(%__MODULE__{fragments: fragments} = state, id) do
    if fragment_member?(fragments, id) do
      %{state | fragment_depth: state.fragment_depth + 1}
    else
      state
    end
  end

  defp maybe_decrement_fragment_depth(%__MODULE__{fragments: nil} = state, _id), do: state

  defp maybe_decrement_fragment_depth(%__MODULE__{fragments: fragments} = state, id) do
    if fragment_member?(fragments, id) do
      %{state | fragment_depth: max(0, state.fragment_depth - 1)}
    else
      state
    end
  end

  defp maybe_delete_fragment(%__MODULE__{fragments: nil} = state, _id), do: state

  defp maybe_delete_fragment(%__MODULE__{fragments: fragments} = state, id) do
    %{state | fragments: delete_fragment_id(fragments, id)}
  end

  defp fragment_member?(fragments, id) do
    MapSet.member?(fragments, id) or
      (is_atom(id) and MapSet.member?(fragments, Atom.to_string(id))) or
      (is_binary(id) and atom_member?(fragments, id))
  end

  defp atom_member?(fragments, id) do
    MapSet.member?(fragments, String.to_existing_atom(id))
  rescue
    ArgumentError -> false
  end

  defp delete_fragment_id(fragments, id) do
    fragments
    |> MapSet.delete(id)
    |> then(fn set ->
      if is_atom(id), do: MapSet.delete(set, Atom.to_string(id)), else: set
    end)
    |> then(fn set ->
      if is_binary(id) do
        try do
          MapSet.delete(set, String.to_existing_atom(id))
        rescue
          ArgumentError -> set
        end
      else
        set
      end
    end)
  end

  @doc """
  Appends content to the buffer.
  """
  def append_buffer(%__MODULE__{} = state, content) do
    new_buffer =
      case state.buffer do
        [] -> content
        list when is_list(list) -> [list | content]
        other -> [other | content]
      end

    %{state | buffer: new_buffer}
  end

  @doc """
  Captures the output of a block.

  Returns the captured buffer content as a binary.
  """
  def capture(%__MODULE__{} = state, fun) when is_function(fun, 1) do
    captured_state = %{
      state
      | buffer: [],
        capturing: true,
        fragments: nil
    }

    captured_state
    |> fun.()
    |> Map.fetch!(:buffer)
    |> IO.iodata_to_binary()
  end

  @doc """
  Renders a block into an isolated buffer for cache storage.

  Returns `{binary, fragment_map}` where `fragment_map` maps fragment names to
  `{byte_offset, byte_length, nested_fragment_names}`.
  """
  def caching(%__MODULE__{} = state, fun) when is_function(fun, 1) do
    parent_bytes = IO.iodata_length(state.buffer)

    raised_stack =
      Enum.map(state.cache_stack, fn entry ->
        %{entry | frozen_prefix_bytes: entry.frozen_prefix_bytes + parent_bytes}
      end)

    captured_state = %{
      state
      | buffer: [],
        capturing: true,
        fragments: nil,
        cache_stack: [%{map: %{}, frozen_prefix_bytes: 0} | raised_stack]
    }

    captured_state = fun.(captured_state)
    buffer = IO.iodata_to_binary(captured_state.buffer)
    [%{map: fragment_map} | _] = captured_state.cache_stack
    {buffer, fragment_map}
  end

  def caching?(%__MODULE__{cache_stack: stack}), do: stack != []

  @doc """
  Records a fragment range into the current cache context, shifting by buffer size.
  """
  def record_fragment(%__MODULE__{cache_stack: []} = state, _name, _offset, _length, _nested),
    do: state

  def record_fragment(%__MODULE__{} = state, name, offset, length, nested_fragments) do
    current_bytes = IO.iodata_length(state.buffer)

    new_stack =
      Enum.map(state.cache_stack, fn entry ->
        adjusted_offset = offset + entry.frozen_prefix_bytes + current_bytes
        %{entry | map: Map.put(entry.map, name, {adjusted_offset, length, nested_fragments})}
      end)

    %{state | cache_stack: new_stack}
  end

  def record_fragment(%__MODULE__{} = state, name, {offset, length, nested_fragments}) do
    record_fragment(state, name, offset, length, nested_fragments)
  end

  defp cache_begin_fragment(%__MODULE__{cache_stack: []} = state, _id), do: state

  defp cache_begin_fragment(%__MODULE__{} = state, id) do
    current_bytes = IO.iodata_length(state.buffer)

    new_stack =
      Enum.map(state.cache_stack, fn entry ->
        offset = entry.frozen_prefix_bytes + current_bytes

        map =
          entry.map
          |> add_nested_to_open_fragments(id)
          |> Map.put(id, {offset, nil, []})

        %{entry | map: map}
      end)

    %{state | cache_stack: new_stack}
  end

  defp cache_end_fragment(%__MODULE__{cache_stack: []} = state, _id), do: state

  defp cache_end_fragment(%__MODULE__{} = state, id) do
    current_bytes = IO.iodata_length(state.buffer)

    {new_stack, _length} =
      Enum.map_reduce(state.cache_stack, nil, fn entry, shared_length ->
        case Map.get(entry.map, id) do
          {offset, nil, nested} ->
            length = shared_length || current_bytes + entry.frozen_prefix_bytes - offset
            {%{entry | map: Map.put(entry.map, id, {offset, length, nested})}, length}

          _other ->
            {entry, shared_length}
        end
      end)

    %{state | cache_stack: new_stack}
  end

  defp add_nested_to_open_fragments(fragment_map, id) do
    Enum.reduce(fragment_map, %{}, fn
      {^id, meta}, acc ->
        Map.put(acc, id, meta)

      {name, {offset, nil, nested}}, acc ->
        Map.put(acc, name, {offset, nil, nested ++ [id]})

      {name, meta}, acc ->
        Map.put(acc, name, meta)
    end)
  end

  @doc """
  Flushes the buffer to the output buffer.
  """
  def flush(%__MODULE__{capturing: true} = state), do: state

  def flush(%__MODULE__{} = state) do
    new_output = [state.output_buffer, state.buffer]
    %{state | buffer: [], output_buffer: new_output}
  end
end
