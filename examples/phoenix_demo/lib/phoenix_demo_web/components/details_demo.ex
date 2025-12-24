defmodule PhoenixDemoWeb.Components.DetailsDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    details(state, [], fn state ->
      state
      |> summary([], "Click to expand")
      |> p([], "This is hidden content that appears when you click the summary.")
    end)
  end
end

