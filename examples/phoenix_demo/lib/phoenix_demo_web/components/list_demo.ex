defmodule PhoenixDemoWeb.Components.ListDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    ul(state, [class: "list-demo"], fn state ->
      state
      |> li([], "First item")
      |> li([], "Second item")
      |> li([], "Third item")
    end)
  end
end

