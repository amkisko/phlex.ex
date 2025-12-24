# Standalone Phlex Example
#
# This example demonstrates basic Phlex usage without Phoenix.
# Run with: mix run examples/standalone/example.exs
#
# For StyleCapsule integration, see: example_with_style_capsule.exs

defmodule CardComponent do
  use Phlex.HTML

  def view_template(assigns, state) do
    # Access original assigns from _assigns field
    original_assigns = Map.get(assigns, :_assigns, %{})
    title = Map.get(original_assigns, :title, "Default Title")
    content = Map.get(original_assigns, :content, "")

    state
    |> div([class: "card"], fn state ->
      state
      |> h1([class: "title"], fn state ->
        Phlex.SGML.append_text(state, title)
      end)
      |> p([class: "content"], fn state ->
        Phlex.SGML.append_text(state, content)
      end)
    end)
  end
end

defmodule IconComponent do
  use Phlex.SVG

  def view_template(_assigns, state) do
    state
    |> svg([viewBox: "0 0 24 24", width: "24", height: "24", class: "icon"], fn state ->
      state
      |> circle([cx: "12", cy: "12", r: "10", fill: "currentColor"])
    end)
  end
end

defmodule PageComponent do
  use Phlex.HTML

  def view_template(_assigns, state) do
    state
    |> doctype()
    |> html([lang: "en"], fn state ->
      state
      |> head([], fn state ->
        state
        |> meta([charset: "UTF-8"])
        |> meta([name: "viewport", content: "width=device-width, initial-scale=1.0"])
        |> title([], fn state ->
          Phlex.SGML.append_text(state, "Phlex Example")
        end)
      end)
      |> body([], fn state ->
        state
        |> header([class: "header"], fn state ->
          state
          |> h1([], fn state ->
            Phlex.SGML.append_text(state, "Welcome to Phlex")
          end)
        end)
        |> main([class: "main"], fn state ->
          state
          |> Phlex.SGML.render_component(CardComponent, %{title: "Hello", content: "This is a card component!"})
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
IO.puts("Phlex Standalone Example")
IO.puts("=" <> String.duplicate("=", 78))
IO.puts("")
IO.puts(PageComponent.render())
IO.puts("")
IO.puts("=" <> String.duplicate("=", 78))
IO.puts("")
IO.puts("Note: For StyleCapsule integration example, see:")
IO.puts("  examples/standalone/example_with_style_capsule.exs")
