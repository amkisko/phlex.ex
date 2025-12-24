defmodule PhoenixDemoWeb.Components.SectionDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    section(state, [], fn state ->
      state
      |> h3([], "Section Title")
      |> p([], "This is a section element, used for thematic grouping of content.")
    end)
  end
end

