defmodule PhoenixDemoWeb.Components.ArticleDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    article(state, [], fn state ->
      state
      |> h3([], "Article Title")
      |> p([], "This is an article element, used for independent, self-contained content.")
    end)
  end
end

