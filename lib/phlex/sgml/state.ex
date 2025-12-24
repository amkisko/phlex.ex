defmodule Phlex.SGML.State do
  @moduledoc """
  Rendering state for Phlex components.

  Manages the buffer, rendering flags, and context during component rendering.
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

  @type t :: %__MODULE__{
          buffer: IO.chardata(),
          should_render: boolean(),
          user_context: map(),
          fragments: MapSet.t() | nil,
          fragment_depth: non_neg_integer(),
          cache_stack: list(),
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
  def should_render?(%__MODULE__{fragments: fragments}) when is_map(fragments) and map_size(fragments) == 0, do: false
  def should_render?(_), do: false

  @doc """
  Increments the fragment depth for better fragment tracking.
  """
  def begin_fragment(%__MODULE__{fragment_depth: depth} = state) do
    %{state | fragment_depth: depth + 1}
  end

  @doc """
  Decrements the fragment depth.
  """
  def end_fragment(%__MODULE__{fragment_depth: depth} = state) when depth > 0 do
    %{state | fragment_depth: depth - 1}
  end

  def end_fragment(%__MODULE__{} = state), do: state

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
    new_buffer = []
    original_buffer = state.buffer
    original_capturing = state.capturing
    original_fragments = state.fragments

    captured_state = %{
      state
      | buffer: new_buffer,
        capturing: true,
        fragments: nil
    }

    try do
      captured_state = fun.(captured_state)
      captured_state.buffer
    after
      %{state | buffer: original_buffer, capturing: original_capturing, fragments: original_fragments}
    end
    |> then(fn buffer -> IO.iodata_to_binary(buffer) end)
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
