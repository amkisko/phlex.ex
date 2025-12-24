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

      import Phlex.SGML
      import Phlex.Helpers
      import Phlex.HTML, only: []

      defstruct []

      @doc """
      Renders the component to a string.

      ## Options

      - `:context` - User context map (default: `%{}`)
      - `:fragments` - MapSet of fragment names to render (default: `nil`)

      ## Examples

          MyComponent.render()
          MyComponent.render(context: %{user: user})
      """
      def render(assigns \\ %{}, opts \\ []) do
        component = struct(__MODULE__, Map.to_list(assigns))
        component = Map.put(component, :_assigns, assigns)
        content_block = Keyword.get(opts, :content_block)

        state =
          State.new(
            user_context: Keyword.get(opts, :context, %{}),
            fragments: Keyword.get(opts, :fragments),
            content_block: content_block
          )

        state = internal_call(component, state, nil)
        state = State.flush(state)
        final_output = [state.output_buffer, state.buffer]
        IO.iodata_to_binary(final_output)
      end

      defoverridable render: 1, render: 2

      defp internal_call(component, state, _parent) do
        view_template(component, state)
      end

      defp view_template(_component, state), do: state

      defoverridable view_template: 2

      @doc """
      Returns the user context map.

      ## Example

          def view_template(_assigns, state) do
            user = context(state)[:user]
            # ...
          end
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

      Similar to phlex-ruby's block support, this allows components to accept
      and render content blocks.

      ## Examples

          defmodule MyComponent do
            use Phlex.HTML

            def render_template(assigns, state) do
              state
              |> div([], fn state ->
                if state.content_block do
                  yield_content(state)
                else
                  append_text(state, "Default content")
                end
              end)
            end
          end

          MyComponent.render(%{}, content_block: fn state ->
            Phlex.SGML.append_text(state, "Custom content")
          end)
      """
      def yield_content(%Phlex.SGML.State{content_block: nil} = state), do: state

      def yield_content(%Phlex.SGML.State{content_block: block} = state) when is_function(block, 1) do
        block.(state)
      end

      def yield_content(%Phlex.SGML.State{content_block: block} = state) when is_function(block, 2) do
        # Arity 2 block receives (state, component)
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
  Appends raw (unescaped) content to the buffer.

  ⚠️ Warning: Only use with trusted content to avoid XSS vulnerabilities.

  Accepts:
  - Binary strings (raw HTML)
  - SafeObject implementations (SafeValue, etc.)
  - Other types (converted to string)

  For explicit unsafe content, use `unsafe_raw/2` instead.
  """
  def append_raw(%Phlex.SGML.State{} = state, %Phlex.SGML.SafeValue{} = safe_object) do
    if State.should_render?(state) do
      content = SafeObject.to_safe_string(safe_object)
      State.append_buffer(state, content)
    else
      state
    end
  end

  def append_raw(%Phlex.SGML.State{} = state, content) when is_binary(content) do
    if State.should_render?(state) do
      State.append_buffer(state, content)
    else
      state
    end
  end

  def append_raw(%Phlex.SGML.State{} = state, content) do
    safe_string = SafeObject.to_safe_string(content)
    append_raw(state, safe_string)
  rescue
    Protocol.UndefinedError -> append_raw(state, to_string(content))
  end

  @doc """
  Appends raw (unescaped) content to the buffer, explicitly marking it as potentially unsafe.

  ⚠️ Warning: This function bypasses HTML escaping. Only use with trusted content
  to avoid XSS vulnerabilities. The name `unsafe_raw` is intentional to make the
  risk explicit.

  This is similar to phlex-ruby's `raw` method, but in phlex.ex we use `unsafe_raw`
  to make the safety implications clear.

  ## Examples

      # Safe: rendering your own component output
      state
      |> unsafe_raw(MyComponent.render())

      # Safe: using safe() wrapper
      state
      |> unsafe_raw(Phlex.SGML.safe("<div>Hello</div>"))

      # ⚠️ Unsafe: user-provided content (don't do this!)
      # unsafe_raw(state, user_input)  # XSS vulnerability!

  Accepts:
  - Binary strings (raw HTML)
  - SafeObject implementations (SafeValue, etc.)
  - Other types (converted to string)
  """
  def unsafe_raw(%Phlex.SGML.State{} = state, content) do
    append_raw(state, content)
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
  Renders another component.
  """
  def render_component(%Phlex.SGML.State{} = state, component_module, assigns \\ %{}) do
    if function_exported?(component_module, :render, 2) do
      rendered = component_module.render(assigns, context: state.user_context, fragments: state.fragments)
      State.append_buffer(state, rendered)
    else
      raise ArgumentError, "Component #{inspect(component_module)} does not implement render/2"
    end
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

  The cache key should uniquely identify the content being cached.
  This is useful for expensive computations or database queries.

  ## Example

      def view_template(assigns, state) do
        state
        |> div([], fn state ->
          Enum.reduce(assigns.products, state, fn product, state ->
            cache(state, [product.id, product.updated_at], fn state ->
              product_card(state, product)
            end)
          end)
        end)
      end

  Note: This requires a cache store to be configured. See `low_level_cache/3` for more control.
  """
  def cache(%Phlex.SGML.State{} = state, _cache_key, fun) when is_function(fun, 1) do
    fun.(state)
  end

  @doc """
  Low-level cache function that requires a cache store.

  This gives you full control over the cache key and cache store.
  """
  def low_level_cache(%Phlex.SGML.State{} = state, _cache_key, _cache_store, fun)
      when is_function(fun, 1) do
    fun.(state)
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
    fragment_id_atom =
      cond do
        is_binary(fragment_id) ->
          try do
            String.to_existing_atom(fragment_id)
          rescue
            ArgumentError -> String.to_atom(fragment_id)
          end

        is_atom(fragment_id) ->
          fragment_id

        true ->
          fragment_id
      end

    should_increment_depth =
      case state.fragments do
        nil ->
          true

        fragments ->
          if MapSet.size(fragments) == 0 do
            false
          else
            MapSet.member?(fragments, fragment_id_atom) or
              (is_binary(fragment_id) and MapSet.member?(fragments, fragment_id))
          end
      end

    if should_increment_depth do
      new_fragment_depth = state.fragment_depth + 1
      state = %{state | fragment_depth: new_fragment_depth}
      state = fun.(state)
      final_fragment_depth = max(0, state.fragment_depth - 1)

      new_fragments =
        if state.fragments do
          updated = MapSet.delete(state.fragments, fragment_id_atom)
          if is_binary(fragment_id), do: MapSet.delete(updated, fragment_id), else: updated
          updated
        else
          state.fragments
        end

      %{state | fragment_depth: final_fragment_depth, fragments: new_fragments}
    else
      state
    end
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
end
