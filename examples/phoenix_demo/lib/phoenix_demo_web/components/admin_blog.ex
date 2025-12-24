defmodule PhoenixDemoWeb.Components.AdminBlog do
  use PhoenixDemoWeb.Components.Base, namespace: :admin

  @component_styles """
  .admin-blog-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .admin-blog-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }

  .admin-blog-card {
    background: #ffffff;
    border-radius: 12px;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    padding: 2rem;
  }

  .admin-blog-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .admin-blog-form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .admin-blog-field {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .admin-blog-label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .admin-blog-input,
  .admin-blog-select,
  .admin-blog-textarea {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.9375rem;
    transition: border-color 0.2s;
  }

  .admin-blog-input:focus,
  .admin-blog-select:focus,
  .admin-blog-textarea:focus {
    outline: none;
    border-color: #667eea;
  }

  .admin-blog-textarea {
    min-height: 150px;
    resize: vertical;
  }

  .admin-blog-submit {
    padding: 0.875rem 2rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
  }

  .admin-blog-submit:hover {
    background: #5568d3;
  }

  .admin-blog-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    max-height: 600px;
    overflow-y: auto;
  }

  .admin-blog-item {
    padding: 1rem;
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
    background: #f9fafb;
  }

  .admin-blog-item-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1d1d1f;
    margin-bottom: 0.5rem;
  }

  .admin-blog-item-meta {
    font-size: 0.875rem;
    color: #6b7280;
    margin-bottom: 0.5rem;
  }

  .admin-blog-item-excerpt {
    font-size: 0.875rem;
    color: #374151;
    line-height: 1.5;
  }
  """

  def render_template(assigns, attrs, state) do
    articles = Map.get(assigns, :articles, [])
    form_data = Map.get(assigns, :form_data, %{})

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "admin-blog-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "admin-blog-grid"], fn state ->
          state
          |> div([], fn state ->
            div(state, [class: "admin-blog-card"], fn state ->
              state
              |> h2([class: "admin-blog-card-title"], "Create New Post")
              |> render_create_form(form_data)
            end)
          end)
          |> div([], fn state ->
            div(state, [class: "admin-blog-card"], fn state ->
              state
              |> h2([class: "admin-blog-card-title"], "Existing Posts (#{length(articles)})")
              |> div([class: "admin-blog-list"], fn state ->
                Enum.reduce(articles, state, fn article, acc_state ->
                  render_article_item(acc_state, article)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_create_form(state, form_data) do
    form(state, [class: "admin-blog-form", phx_submit: "create_post"], fn state ->
      state
      |> div([class: "admin-blog-field"], fn state ->
        state
        |> label([class: "admin-blog-label", for: "title"], "Title")
        |> input([
          type: "text",
          id: "title",
          name: "article[title]",
          value: Map.get(form_data, :title, ""),
          class: "admin-blog-input",
          required: true,
          phx_change: "update_form"
        ])
      end)
      |> div([class: "admin-blog-field"], fn state ->
        state
        |> label([class: "admin-blog-label", for: "author"], "Author")
        |> input([
          type: "text",
          id: "author",
          name: "article[author]",
          value: Map.get(form_data, :author, ""),
          class: "admin-blog-input",
          required: true,
          phx_change: "update_form"
        ])
      end)
      |> div([class: "admin-blog-field"], fn state ->
        state
        |> label([class: "admin-blog-label", for: "category"], "Category")
        |> select([id: "category", name: "article[category]", class: "admin-blog-select", required: true, phx_change: "update_form"], fn state ->
          state
          |> option([value: "News", selected: Map.get(form_data, :category) == "News"], "News")
          |> option([value: "Tips", selected: Map.get(form_data, :category) == "Tips"], "Tips")
          |> option([value: "Sustainability", selected: Map.get(form_data, :category) == "Sustainability"], "Sustainability")
          |> option([value: "Travel", selected: Map.get(form_data, :category) == "Travel"], "Travel")
        end)
      end)
      |> div([class: "admin-blog-field"], fn state ->
        state
        |> label([class: "admin-blog-label", for: "excerpt"], "Excerpt")
        |> textarea([
          id: "excerpt",
          name: "article[excerpt]",
          value: Map.get(form_data, :excerpt, ""),
          class: "admin-blog-textarea",
          required: true,
          phx_change: "update_form"
        ])
      end)
      |> div([class: "admin-blog-field"], fn state ->
        state
        |> label([class: "admin-blog-label", for: "content"], "Content")
        |> textarea([
          id: "content",
          name: "article[content]",
          value: Map.get(form_data, :content, ""),
          class: "admin-blog-textarea",
          required: true,
          phx_change: "update_form",
          rows: "8"
        ])
      end)
      |> button([type: "submit", class: "admin-blog-submit"], "Create Post")
    end)
  end

  defp render_article_item(state, article) do
    div(state, [class: "admin-blog-item"], fn state ->
      state
      |> h3([class: "admin-blog-item-title"], article.title)
      |> div([class: "admin-blog-item-meta"], fn state ->
        state
        |> span([], "By #{article.author} • ")
        |> span([], Date.to_string(article.date))
        |> span([], " • #{article.category}")
      end)
      |> p([class: "admin-blog-item-excerpt"], article.excerpt)
    end)
  end
end
