defmodule Phlex.SGML do
  @moduledoc """
  Standard Generalized Markup Language foundation for Phlex.

  This module provides the base functionality shared between HTML and SVG components,
  including state management, buffer handling, and attribute generation.

  ## Example

      defmodule MyComponent do
        use Phlex.SGML

        def render_template(assigns, state) do
          state
          |> append_text("Hello, World!")
        end
      end

      MyComponent.render()
      # => "Hello, World!"
  """

  alias Phlex.SGML.{Attributes, SafeObject, SafeValue, State}

  defmacro __using__(_opts) do
    quote do
      @behaviour Phlex.SGML

      import Phlex.SGML, except: [render: 2, render: 3]
      import Phlex.Helpers
      import Phlex.HTML, only: []

      defstruct []

      @doc """
      Renders the component to a string.

      ## Options

      - `:context` - User context map (default: `%{}`)
      - `:fragments` - MapSet of fragment names to render (default: `nil`)
      - `:content_block` - optional content function `(state -> state)`

      Nested rendering into an existing state uses `render/2` or `render/3` with a
      `%Phlex.SGML.State{}` as the first argument.
      """
      def render(assigns \\ %{}, opts \\ [])

      def render(%Phlex.SGML.State{} = state, renderable) do
        Phlex.SGML.render(state, renderable)
      end

      def render(%Phlex.SGML.State{} = state, renderable, opts) when is_list(opts) do
        Phlex.SGML.render(state, renderable, opts)
      end

      def render(assigns, opts) when is_map(assigns) or is_list(assigns) do
        component = build_component(assigns)
        content_block = Keyword.get(opts, :content_block)

        state =
          State.new(
            user_context:
              Keyword.get(opts, :context, %{})
              |> Map.put(:phlex_cache_class, __MODULE__),
            fragments: Phlex.SGML.normalize_fragments(Keyword.get(opts, :fragments)),
            content_block: content_block
          )

        state = __phlex_call__(component, state, opts)
        state = State.flush(state)
        final_output = [state.output_buffer, state.buffer]
        IO.iodata_to_binary(final_output)
      end

      defoverridable render: 1, render: 2, render: 3

      @doc false
      def __phlex_call__(component, state, opts \\ []) do
        previous = Process.get(:phlex_rendering_component)
        Process.put(:phlex_rendering_component, __MODULE__)

        try do
          state = put_content_block(state, opts)

          if render?(component, state) do
            component
            |> before_template(state)
            |> then(fn state ->
              around_template(component, state, fn state ->
                view_template(component, state)
              end)
            end)
            |> then(&after_template(component, &1))
          else
            state
          end
        after
          Process.put(:phlex_rendering_component, previous)
        end
      end

      defp build_component(assigns) when is_map(assigns) do
        __MODULE__
        |> struct(Map.to_list(assigns))
        |> Map.put(:_assigns, assigns)
      end

      defp build_component(assigns) when is_list(assigns) do
        build_component(Map.new(assigns))
      end

      defp put_content_block(state, opts) do
        case Keyword.fetch(opts, :content_block) do
          {:ok, content_block} -> %{state | content_block: content_block}
          :error -> state
        end
      end

      def before_template(_component, state), do: state
      def after_template(_component, state), do: state
      def around_template(_component, state, fun) when is_function(fun, 1), do: fun.(state)
      def render?(_component, _state), do: true

      defoverridable before_template: 2,
                     after_template: 2,
                     around_template: 3,
                     render?: 2

      defp view_template(_component, state), do: state

      defoverridable view_template: 2

      @doc """
      Returns the user context map.
      """
      def context(%Phlex.SGML.State{} = state) do
        state.user_context
      end

      @doc """
      Returns true if the component is currently rendering, false otherwise.
      """
      def rendering?(%Phlex.SGML.State{} = state), do: state.rendering || false
      def rendering?(_), do: false

      @doc """
      Yields content block if one was provided.
      """
      def yield_content(%Phlex.SGML.State{content_block: nil} = state), do: state

      def yield_content(%Phlex.SGML.State{content_block: block} = state) when is_function(block, 1) do
        block.(state)
      end

      def yield_content(%Phlex.SGML.State{content_block: block} = state) when is_function(block, 2) do
        component = Map.get(state, :_component)
        block.(state, component)
      end

      def yield_content(state), do: state
    end
  end

  @doc """
  The render template that must be implemented by components.
  """
  @callback view_template(component :: struct(), state :: Phlex.SGML.State.t()) :: Phlex.SGML.State.t()

  @doc """
  Appends text content to the buffer, escaping HTML entities.
  """
  def append_text(%Phlex.SGML.State{} = state, nil), do: state

  def append_text(%Phlex.SGML.State{} = state, content) when is_binary(content) do
    if State.should_render?(state) do
      escaped = Phlex.Helpers.escape_html(content)
      State.append_buffer(state, escaped)
    else
      state
    end
  end

  def append_text(%Phlex.SGML.State{} = state, content) when is_atom(content) do
    append_text(state, Atom.to_string(content))
  end

  def append_text(%Phlex.SGML.State{} = state, content) when is_number(content) do
    if State.should_render?(state) do
      State.append_buffer(state, to_string(content))
    else
      state
    end
  end

  def append_text(%Phlex.SGML.State{} = state, content) do
    str = inspect(content)
    append_text(state, str)
  rescue
    _ -> state
  end

  @doc """
  Output plain text (HTML-escaped). Matches Phlex Ruby `plain`.
  """
  def plain(state, content), do: append_text(state, content)

  @doc """
  Appends a SafeObject without escaping. Matches Phlex Ruby `raw`.

  Pass binaries through `safe/1`, or use `unsafe_raw/2` for an explicit opt-in.
  """
  def append_raw(state, content), do: raw(state, content)

  def raw(%Phlex.SGML.State{} = state, content) when content in [nil, ""], do: state

  def raw(%Phlex.SGML.State{} = state, content) do
    case safe_object_string(content) do
      {:ok, safe_string} ->
        if State.should_render?(state) do
          State.append_buffer(state, safe_string)
        else
          state
        end

      :error ->
        raise ArgumentError,
              "You passed an unsafe object to `raw`. Wrap trusted HTML with Phlex.SGML.safe/1."
    end
  end

  @doc """
  Appends raw HTML without a SafeObject wrapper.

  Prefer `raw/2` with `safe/1` for trusted markup.
  """
  def unsafe_raw(%Phlex.SGML.State{} = state, nil), do: state

  def unsafe_raw(%Phlex.SGML.State{} = state, content) when is_binary(content) do
    if State.should_render?(state) do
      State.append_buffer(state, content)
    else
      state
    end
  end

  def unsafe_raw(%Phlex.SGML.State{} = state, content) do
    case safe_object_string(content) do
      {:ok, safe_string} -> unsafe_raw(state, safe_string)
      :error -> unsafe_raw(state, to_string(content))
    end
  end

  defp safe_object_string(%SafeValue{} = safe_value) do
    {:ok, SafeObject.to_safe_string(safe_value)}
  end

  defp safe_object_string(content) do
    {:ok, SafeObject.to_safe_string(content)}
  rescue
    Protocol.UndefinedError -> :error
  end

  @doc """
  Marks a string as safe for HTML output.

  ## Example

      safe_html = Phlex.SGML.safe("<strong>Hello</strong>")
      Phlex.SGML.append_raw(state, safe_html)
  """
  def safe(content) when is_binary(content) do
    SafeValue.new(content)
  end

  def safe(_), do: raise(ArgumentError, "safe/1 expects a binary string")

  @doc """
  Outputs whitespace. If a block is given, outputs whitespace before and after the block.

  ## Example

      whitespace(state)
      whitespace(state, fn state ->
        Phlex.SGML.append_text(state, "content")
      end)
  """
  def whitespace(%Phlex.SGML.State{} = state) do
    if State.should_render?(state) do
      State.append_buffer(state, " ")
    else
      state
    end
  end

  def whitespace(%Phlex.SGML.State{} = state, fun) when is_function(fun, 1) do
    if State.should_render?(state) do
      state
      |> State.append_buffer(" ")
      |> then(fn s -> fun.(s) end)
      |> State.append_buffer(" ")
    else
      fun.(state)
    end
  end

  @doc """
  Wraps the output in an HTML comment.

  ## Example

      comment(state, fn state ->
        Phlex.SGML.append_text(state, "This is a comment")
      end)
  """
  def comment(%Phlex.SGML.State{} = state, fun) when is_function(fun, 1) do
    if State.should_render?(state) do
      state
      |> State.append_buffer("<!-- ")
      |> then(fn s -> fun.(s) end)
      |> State.append_buffer(" -->")
    else
      fun.(state)
    end
  end

  @doc """
  Renders another component into the current state.

  Prefer `render/2` or `render/3` for the full polymorphic Phlex Ruby surface.
  """
  def render_component(%Phlex.SGML.State{} = state, component_module, assigns \\ %{}) do
    render(state, component_module, assigns: assigns)
  end

  @doc """
  Polymorphic nested render aligned with Phlex Ruby `render`.

  Accepts component modules or structs, binaries (via `plain/2`), lists of
  renderables, arity-1 functions, or `nil` with an optional `:content_block`.
  """
  def render(%Phlex.SGML.State{} = state, renderable), do: render(state, renderable, [])

  def render(%Phlex.SGML.State{} = state, %mod{} = component, opts)
      when is_atom(mod) and is_list(opts) do
    call_component(mod, component, state, opts)
  end

  def render(%Phlex.SGML.State{} = state, renderable, opts)
      when is_atom(renderable) and is_list(opts) do
    assigns = Keyword.get(opts, :assigns, %{})
    component = build_renderable_component(renderable, assigns)
    call_component(renderable, component, state, opts)
  end

  def render(%Phlex.SGML.State{} = state, renderables, opts)
      when is_list(renderables) and is_list(opts) do
    if Keyword.keyword?(renderables) do
      raise ArgumentError, "You can't render a #{inspect(renderables)}."
    else
      Enum.reduce(renderables, state, fn item, acc -> render(acc, item, opts) end)
    end
  end

  def render(%Phlex.SGML.State{} = state, fun, _opts) when is_function(fun, 1) do
    fun.(state)
  end

  def render(%Phlex.SGML.State{} = state, content, _opts) when is_binary(content) do
    plain(state, content)
  end

  def render(%Phlex.SGML.State{} = state, nil, opts) when is_list(opts) do
    case Keyword.get(opts, :content_block) do
      fun when is_function(fun, 1) -> fun.(state)
      nil -> state
      other -> raise ArgumentError, "You can't render a #{inspect(other)}."
    end
  end

  def render(%Phlex.SGML.State{} = _state, renderable, _opts) do
    raise ArgumentError, "You can't render a #{inspect(renderable)}."
  end

  defp call_component(mod, component, state, opts) do
    cond do
      function_exported?(mod, :__phlex_call__, 3) ->
        mod.__phlex_call__(component, state, opts)

      function_exported?(mod, :__phlex_call__, 2) ->
        mod.__phlex_call__(component, state)

      true ->
        raise ArgumentError, "You can't render a #{inspect(mod)}."
    end
  end

  defp build_renderable_component(mod, assigns) when is_map(assigns) do
    if function_exported?(mod, :__struct__, 0) do
      mod
      |> struct(Map.to_list(assigns))
      |> Map.put(:_assigns, assigns)
    else
      raise ArgumentError, "You can't render a #{inspect(mod)}."
    end
  end

  defp build_renderable_component(mod, assigns) when is_list(assigns) do
    build_renderable_component(mod, Map.new(assigns))
  end

  @doc """
  Generates attributes string from a keyword list or map and appends to state buffer.
  """
  def append_attributes(%Phlex.SGML.State{} = state, attributes) do
    if State.should_render?(state) do
      attrs_string = Attributes.generate_attributes(attributes)
      State.append_buffer(state, attrs_string)
    else
      state
    end
  end

  @doc """
  Generates attributes string from a keyword list or map.
  """
  def generate_attributes(attributes) do
    Attributes.generate_attributes(attributes)
  end

  @doc """
  Captures the output of a block without rendering it.

  Useful for extracting content for caching or other processing.
  """
  def capture(%Phlex.SGML.State{} = state, fun) when is_function(fun, 1) do
    State.capture(state, fun)
  end

  @doc """
  Caches a block of content based on a cache key.

  Uses a process-local FIFO cache store by default. Keys include the calling
  module context when available via `state.user_context[:phlex_cache_class]`.

  Calling `cache/2` with only a function uses an empty key fragment, matching
  Ruby `cache { ... }`.
  """
  def cache(%Phlex.SGML.State{} = state, fun) when is_function(fun, 1) do
    cache(state, [], fun)
  end

  def cache(%Phlex.SGML.State{} = state, cache_key, fun) when is_function(fun, 1) do
    full_key = [
      Phlex.deployed_at(),
      Map.get(state.user_context, :phlex_cache_class),
      cache_key
    ]

    low_level_cache(state, full_key, default_cache_store(), fun)
  end

  @doc """
  Caches a block with an explicit cache key and store.

  `cache_store` may be a `Phlex.FIFOCacheStore` or any module/value accepted by
  `fetch_from_cache_store/3`. When omitted-style atoms are passed, the process
  default store is used.
  """
  def low_level_cache(%Phlex.SGML.State{} = state, cache_key, fun)
      when is_function(fun, 1) do
    low_level_cache(state, cache_key, default_cache_store(), fun)
  end

  def low_level_cache(%Phlex.SGML.State{} = state, cache_key, cache_store, fun)
      when is_function(fun, 1) do
    store = resolve_cache_store(cache_store)

    {cached_payload, updated_store} =
      fetch_from_cache_store(store, cache_key, fn ->
        State.caching(state, fun)
      end)

    put_resolved_cache_store(cache_store, updated_store)
    apply_cached_payload(state, cached_payload)
  end

  defp default_cache_store do
    case Process.get(:phlex_component_cache_store) do
      %Phlex.FIFOCacheStore{} = store ->
        store

      nil ->
        store = Phlex.FIFOCacheStore.new(max_bytesize: 2_000_000)
        Process.put(:phlex_component_cache_store, store)
        store
    end
  end

  defp resolve_cache_store(%Phlex.FIFOCacheStore{} = store), do: store
  defp resolve_cache_store(_other), do: default_cache_store()

  defp put_resolved_cache_store(%Phlex.FIFOCacheStore{}, updated_store) do
    Process.put(:phlex_component_cache_store, updated_store)
  end

  defp put_resolved_cache_store(_other, updated_store) do
    Process.put(:phlex_component_cache_store, updated_store)
  end

  defp fetch_from_cache_store(%Phlex.FIFOCacheStore{} = store, cache_key, fun) do
    Phlex.FIFOCacheStore.fetch(store, cache_key, fun)
  end

  defp apply_cached_payload(state, {cached_buffer, fragment_map})
       when is_binary(cached_buffer) and is_map(fragment_map) do
    ordered_fragments =
      Enum.sort_by(fragment_map, fn {_name, {offset, _length, _nested}} -> offset end)

    if State.should_render?(state) do
      state =
        Enum.reduce(ordered_fragments, state, fn {name, {offset, length, nested}}, acc ->
          State.record_fragment(acc, name, offset, length, nested)
        end)

      State.append_buffer(state, cached_buffer)
    else
      Enum.reduce(ordered_fragments, state, fn {fragment_name, {offset, length, nested_fragments}}, acc ->
        if selective_fragment_match?(acc.fragments, fragment_name) do
          updated_fragments =
            acc.fragments
            |> MapSet.delete(fragment_name)
            |> then(fn set ->
              Enum.reduce(nested_fragments, set, &MapSet.delete(&2, &1))
            end)

          slice = binary_part(cached_buffer, offset, length)

          acc
          |> Map.put(:fragments, updated_fragments)
          |> State.append_buffer(slice)
        else
          acc
        end
      end)
    end
  end

  defp apply_cached_payload(state, cached_buffer) when is_binary(cached_buffer) do
    State.append_buffer(state, cached_buffer)
  end

  defp selective_fragment_match?(nil, _name), do: false

  defp selective_fragment_match?(fragments, name) do
    MapSet.member?(fragments, name) or
      (is_atom(name) and MapSet.member?(fragments, Atom.to_string(name))) or
      (is_binary(name) and
         try do
           MapSet.member?(fragments, String.to_existing_atom(name))
         rescue
           ArgumentError -> false
         end)
  end

  @doc """
  Defines a fragment that can be selectively rendered.

  Fragments allow you to render only specific parts of a component,
  which is useful for partial page updates and caching.

  ## Example

      def view_template(_assigns, state) do
        state
        |> div([], fn state ->
          state
          |> h1([], fn state ->
            Phlex.SGML.append_text(state, "Header")
          end)
          |> fragment("content", fn state ->
            state
            |> p([], fn state ->
              Phlex.SGML.append_text(state, "This is a fragment")
            end)
          end)
        end)
      end

  Then render only the fragment:
      MyComponent.render(fragments: MapSet.new(["content"]))
  """
  def fragment(%Phlex.SGML.State{} = state, fragment_id, fun) when is_function(fun, 1) do
    state
    |> State.begin_fragment(fragment_id)
    |> then(fun)
    |> State.end_fragment(fragment_id)
  end

  @doc """
  Returns the user context map from a state.

  This is a module-level function that can be called directly.
  """
  def context(%Phlex.SGML.State{} = state) do
    state.user_context
  end

  def context(_), do: raise(ArgumentError, "context/1 can only be called with a Phlex.SGML.State during rendering")

  @doc """
  Returns true if the component is currently rendering, false otherwise.
  """
  def rendering?(%Phlex.SGML.State{} = _state), do: true
  def rendering?(_), do: false

  @doc false
  def normalize_fragments(nil), do: nil
  def normalize_fragments(%MapSet{} = fragments), do: fragments
  def normalize_fragments(fragments) when is_list(fragments), do: MapSet.new(fragments)
  def normalize_fragments(fragments), do: MapSet.new(List.wrap(fragments))
end
