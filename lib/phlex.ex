defmodule Phlex do
  @moduledoc """
  Phlex lets you build object-oriented web views in pure Elixir.

  Phlex provides a component-based architecture for building HTML, SVG, and other
  markup views using Elixir's functional programming paradigm.

  ## Getting Started

  Create a component by using `Phlex.HTML` or `Phlex.SVG`:

      defmodule MyApp.Components.Card do
        use Phlex.HTML

        def view_template(assigns, state) do
          state
          |> div([class: "card"], fn state ->
            state
            |> h1([class: "title"], fn state ->
              Phlex.SGML.append_text(state, assigns.title)
            end)
          end)
        end
      end

      MyApp.Components.Card.render(%{title: "Hello"})
      # => "<div class=\"card\"><h1 class=\"title\">Hello</h1></div>"

  ## Phoenix Integration

  Phlex components can be used with Phoenix and Phoenix LiveView:

      defmodule MyAppWeb.Components.Card do
        use Phlex.HTML

        def view_template(assigns, state) do
          state
          |> div([class: "card"], fn state ->
            Phlex.SGML.append_text(state, assigns.title)
          end)
        end
      end

  For LiveView integration, use `Phlex.Phoenix.to_rendered/2`:

      defmodule MyAppWeb.MyLive do
        use Phoenix.LiveView

        def render(assigns) do
          Phlex.Phoenix.to_rendered(
            MyAppWeb.Components.Card.render(assigns)
          )
        end
      end

  ## Attribute Caching

  Phlex automatically caches attribute generation for improved performance.
  The `fetch_attributes/2` function provides a way to cache expensive attribute
  computations.

  ## Modules

  - `Phlex.HTML` - HTML component base
  - `Phlex.SVG` - SVG component base
  - `Phlex.SGML` - Base functionality for markup components
  - `Phlex.Phoenix` - Phoenix and LiveView integration
  - `Phlex.StyleCapsule` - StyleCapsule integration helper

  See the documentation for each module for more details.
  """

  @version "0.1.0"

  @doc """
  Returns the version of Phlex.

  ## Examples

      Phlex.version()
      # => "0.1.0"
  """
  def version, do: @version

  @doc """
  Fetches cached attributes or computes them if not cached.

  Uses a FIFO cache to improve performance for repeated attribute patterns.
  This is useful when generating attributes is expensive or when the same
  attribute patterns are used frequently.

  ## Examples

      Phlex.fetch_attributes([class: "card", id: "card-1"], fn ->
        Phlex.SGML.Attributes.generate_attributes([class: "card", id: "card-1"])
      end)

  ## Arguments

  - `attributes` - The attributes to use as a cache key
  - `fun` - A zero-arity function that generates the attributes if not cached

  ## Returns

  The cached or newly computed attribute string.

  Note: The cache is process-local and uses a FIFO eviction strategy with
  a maximum size of 2MB.
  """
  def fetch_attributes(attributes, fun) when is_function(fun, 0) do
    cache = get_attribute_cache()
    {value, updated_cache} = Phlex.FIFOCache.fetch(cache, {:attributes, attributes}, fun)
    Process.put(:phlex_attribute_cache, updated_cache)
    value
  end

  defp get_attribute_cache do
    case Process.get(:phlex_attribute_cache) do
      nil ->
        cache = Phlex.FIFOCache.new(max_bytesize: 2_000_000, max_value_bytesize: 2_000_000)
        Process.put(:phlex_attribute_cache, cache)
        cache

      cache ->
        cache
    end
  end
end
