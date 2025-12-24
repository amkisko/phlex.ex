defmodule PhoenixDemoWeb.Components.AsideDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    aside(state, [], fn state ->
      state
      |> h4([], "Aside")
      |> p([], "This is an aside element, used for tangentially related content.")
    end)
  end
end

