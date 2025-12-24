defmodule PhoenixDemoWeb.Components.HeadingDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    state
    |> h1([], "Heading 1")
    |> h2([], "Heading 2")
    |> h3([], "Heading 3")
    |> h4([], "Heading 4")
    |> h5([], "Heading 5")
    |> h6([], "Heading 6")
  end
end

