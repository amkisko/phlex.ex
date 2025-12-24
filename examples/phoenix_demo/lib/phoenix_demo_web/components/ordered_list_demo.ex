defmodule PhoenixDemoWeb.Components.OrderedListDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    ol(state, [class: "list-demo"], fn state ->
      state
      |> li([], "First step")
      |> li([], "Second step")
      |> li([], "Third step")
    end)
  end
end

