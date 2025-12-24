defmodule PhoenixDemoWeb.Components.ButtonDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    div(state, [], fn state ->
      state
      |> button([type: "button", class: "button-demo"], "Primary")
      |> button([type: "button", class: "button-demo secondary"], "Secondary")
    end)
  end
end

