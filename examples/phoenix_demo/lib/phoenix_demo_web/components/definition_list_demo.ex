defmodule PhoenixDemoWeb.Components.DefinitionListDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    dl(state, [class: "list-demo"], fn state ->
      state
      |> dt([], "Term 1")
      |> dd([], "Definition for term 1")
      |> dt([], "Term 2")
      |> dd([], "Definition for term 2")
    end)
  end
end

