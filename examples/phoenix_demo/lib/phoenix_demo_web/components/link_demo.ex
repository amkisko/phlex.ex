defmodule PhoenixDemoWeb.Components.LinkDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    div(state, [], fn state ->
      state
      |> a([href: "#", class: "button-demo"], "Internal")
      |> a([href: "https://github.com/amkisko/phlex.ex", target: "_blank", class: "button-demo"], "External")
    end)
  end
end

