# Standalone Phlex Example with StyleCapsule
#
# This example demonstrates basic Phlex usage with StyleCapsule CSS scoping.
# Run with: elixir examples/standalone/example_with_style_capsule.exs
#
# Note: This requires phlex and style_capsule to be available.
# For development, you can use Mix.install or ensure they're in your path.

# Try to load modules, or use Mix.install if not in a Mix project
unless Code.ensure_loaded?(Phlex) do
  Mix.install([
    {:phlex, path: Path.expand("../../", __DIR__)},
    {:style_capsule, "~> 0.5"}
  ])
end

defmodule CardComponent do
  use Phlex.HTML

  @component_styles """
  .card {
    padding: 1.5rem;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    background: #ffffff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 1rem;
  }

  .title {
    margin: 0 0 0.75rem 0;
    font-size: 1.5rem;
    font-weight: 600;
    color: #333;
  }

  .content {
    margin: 0;
    color: #666;
    line-height: 1.6;
  }
  """

  def view_template(assigns, state) do
    # Access original assigns from _assigns field
    original_assigns = Map.get(assigns, :_assigns, %{})
    title = Map.get(original_assigns, :title, "Default Title")
    content = Map.get(original_assigns, :content, "")

    # Add capsule attribute
    attrs = Phlex.StyleCapsule.add_capsule_attr([class: "card"], __MODULE__)

    state
    |> div(attrs, fn state ->
      state
      |> h1([class: "title"], fn state ->
        Phlex.SGML.append_text(state, title)
      end)
      |> p([class: "content"], fn state ->
        Phlex.SGML.append_text(state, content)
      end)
    end)
  end

  def scoped_styles do
    Phlex.StyleCapsule.scope_css(@component_styles, __MODULE__)
  end
end

defmodule IconComponent do
  use Phlex.SVG

  @component_styles """
  .icon {
    width: 24px;
    height: 24px;
    color: #007bff;
  }
  """

  def view_template(_assigns, state) do
    # Add capsule attribute
    attrs = Phlex.StyleCapsule.add_capsule_attr(
      [viewBox: "0 0 24 24", width: "24", height: "24", class: "icon"],
      __MODULE__
    )

    state
    |> svg(attrs, fn state ->
      state
      |> circle([cx: "12", cy: "12", r: "10", fill: "currentColor"])
    end)
  end

  def scoped_styles do
    Phlex.StyleCapsule.scope_css(@component_styles, __MODULE__)
  end
end

defmodule PageComponent do
  use Phlex.HTML

  @page_styles """
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    margin: 0;
    padding: 2rem;
    background: #f5f5f5;
  }

  .header {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #007bff;
  }

  .header h1 {
    margin: 0;
    color: #333;
  }

  .main {
    max-width: 800px;
    margin: 0 auto;
  }

  .icon-wrapper {
    display: inline-block;
    padding: 1rem;
    background: white;
    border-radius: 4px;
    margin-top: 1rem;
  }
  """

  def view_template(_assigns, state) do
    # Get scoped styles for all components
    card_styles = CardComponent.scoped_styles()
    icon_styles = IconComponent.scoped_styles()
    page_capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    page_styles = Phlex.StyleCapsule.scope_css(@page_styles, page_capsule_id)

    state
    |> doctype()
    |> html([lang: "en"], fn state ->
      state
      |> head([], fn state ->
        state
        |> meta([charset: "UTF-8"])
        |> meta([name: "viewport", content: "width=device-width, initial-scale=1.0"])
        |> title([], fn state ->
          Phlex.SGML.append_text(state, "Phlex Example with StyleCapsule")
        end)
        |> style([], fn state ->
          Phlex.SGML.append_raw(state, page_styles)
          Phlex.SGML.append_raw(state, "\n")
          Phlex.SGML.append_raw(state, card_styles)
          Phlex.SGML.append_raw(state, "\n")
          Phlex.SGML.append_raw(state, icon_styles)
        end)
      end)
      |> body([], fn state ->
        state
        |> header([class: "header"], fn state ->
          state
          |> h1([], fn state ->
            Phlex.SGML.append_text(state, "Welcome to Phlex with StyleCapsule")
          end)
        end)
        |> main([class: "main"], fn state ->
          state
          |> CardComponent.render(%{title: "Hello", content: "This is a card component with scoped CSS!"})
          |> div([class: "icon-wrapper"], fn state ->
            Phlex.SGML.render_component(state, IconComponent, %{})
          end)
        end)
      end)
    end)
  end
end

# Render and print
IO.puts("=" <> String.duplicate("=", 78))
IO.puts("Phlex Standalone Example with StyleCapsule")
IO.puts("=" <> String.duplicate("=", 78))
IO.puts("")
IO.puts(PageComponent.render())
IO.puts("")
IO.puts("=" <> String.duplicate("=", 78))
