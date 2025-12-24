defmodule PhoenixDemoWeb.Components.Blog do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .blog-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
    transition: background-color 0.2s ease;
  }

  :root.dark .blog-container,
  html.dark .blog-container {
    background: #1d1d1f;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .blog-posts {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .blog-post {
    background: #ffffff;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    border-radius: 12px;
    padding: 1.5rem;
    display: flex;
    gap: 1rem;
    transition: all 0.2s ease;
  }

  :root.dark .blog-post,
  html.dark .blog-post {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.1);
  }

  .blog-post:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  }

  .blog-vote {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.25rem;
    padding: 0.25rem 0.5rem;
    min-width: 40px;
  }

  .blog-vote-button {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    color: #878a8c;
    font-size: 1.25rem;
    line-height: 1;
  }

  .blog-vote-button:hover {
    color: #ff4500;
  }

  .blog-vote-count {
    font-size: 0.75rem;
    font-weight: 700;
    color: #1a1a1b;
  }

  :root.dark .blog-vote-count,
  html.dark .blog-vote-count {
    color: #f5f5f7;
  }

  .blog-content {
    flex: 1;
    min-width: 0;
  }

  .blog-meta {
    display: flex;
    gap: 0.5rem;
    align-items: center;
    font-size: 0.75rem;
    color: #787c7e;
    margin-bottom: 0.5rem;
  }

  .blog-category {
    background: #e9ecef;
    padding: 0.125rem 0.375rem;
    border-radius: 2px;
    font-weight: 500;
    color: #1a1a1b;
  }

  .blog-author {
    font-weight: 500;
  }

  .blog-date {
    color: #787c7e;
  }

  .blog-post-title {
    font-size: 1.125rem;
    font-weight: 500;
    color: #1a1a1b;
    margin-bottom: 0.5rem;
    line-height: 1.4;
  }

  :root.dark .blog-post-title,
  html.dark .blog-post-title {
    color: #f5f5f7;
  }

  .blog-post-title a {
    color: inherit;
    text-decoration: none;
  }

  .blog-post-title a:hover {
    text-decoration: underline;
  }

  .blog-excerpt {
    font-size: 0.875rem;
    color: #1c1c1c;
    line-height: 1.5;
    margin-bottom: 0.5rem;
  }

  :root.dark .blog-excerpt,
  html.dark .blog-excerpt {
    color: #d2d2d7;
  }

  .blog-actions {
    display: flex;
    gap: 1rem;
    font-size: 0.75rem;
    color: #878a8c;
    margin-top: 0.5rem;
  }

  .blog-action {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    text-decoration: none;
    color: inherit;
  }

  .blog-action:hover {
    color: #1a1a1b;
  }

  .blog-details {
    margin-top: 0.75rem;
    padding-top: 0.75rem;
    border-top: 1px solid #e5e7eb;
  }

  .blog-full-content {
    font-size: 0.875rem;
    color: #1c1c1c;
    line-height: 1.6;
    white-space: pre-wrap;
  }

  :root.dark .blog-full-content,
  html.dark .blog-full-content {
    color: #d2d2d7;
  }

  .blog-post-single {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
  }

  :root.dark .blog-post-single,
  html.dark .blog-post-single {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.1);
  }

  .blog-post-header {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
  }

  :root.dark .blog-post-header,
  html.dark .blog-post-header {
    border-bottom-color: rgba(255, 255, 255, 0.1);
  }

  .blog-post-title-single {
    font-size: 2rem;
    font-weight: 600;
    color: #1a1a1b;
    margin: 1rem 0;
    line-height: 1.3;
  }

  :root.dark .blog-post-title-single,
  html.dark .blog-post-title-single {
    color: #f5f5f7;
  }

  .blog-actions-single {
    display: flex;
    gap: 1.5rem;
    align-items: center;
    margin-top: 1rem;
  }

  .blog-like-button {
    background: none;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font-size: 0.875rem;
    color: #1a1a1b;
    transition: all 0.2s ease;
  }

  .blog-like-button:hover {
    background: #f9fafb;
    border-color: #ff4500;
    color: #ff4500;
  }

  :root.dark .blog-like-button,
  html.dark .blog-like-button {
    border-color: rgba(255, 255, 255, 0.2);
    color: #f5f5f7;
  }

  :root.dark .blog-like-button:hover,
  html.dark .blog-like-button:hover {
    background: #3d3d3f;
    border-color: #ff4500;
    color: #ff4500;
  }

  .blog-comments-count {
    font-size: 0.875rem;
    color: #787c7e;
  }

  :root.dark .blog-comments-count,
  html.dark .blog-comments-count {
    color: #a1a1a6;
  }

  .blog-post-content {
    margin: 2rem 0;
    font-size: 1rem;
    line-height: 1.8;
    color: #1c1c1c;
  }

  :root.dark .blog-post-content,
  html.dark .blog-post-content {
    color: #d2d2d7;
  }

  .blog-comments-section {
    margin-top: 3rem;
    padding-top: 2rem;
    border-top: 1px solid #e5e7eb;
  }

  :root.dark .blog-comments-section,
  html.dark .blog-comments-section {
    border-top-color: rgba(255, 255, 255, 0.1);
  }

  .blog-comments-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: #1a1a1b;
    margin-bottom: 1.5rem;
  }

  :root.dark .blog-comments-title,
  html.dark .blog-comments-title {
    color: #f5f5f7;
  }

  .blog-comment-form {
    margin-bottom: 2rem;
    padding: 1.5rem;
    background: #f9fafb;
    border-radius: 8px;
  }

  :root.dark .blog-comment-form,
  html.dark .blog-comment-form {
    background: #252527;
  }

  .blog-comment-field {
    margin-bottom: 1rem;
  }

  .blog-comment-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    margin-bottom: 0.5rem;
  }

  :root.dark .blog-comment-label,
  html.dark .blog-comment-label {
    color: #d2d2d7;
  }

  .blog-comment-input,
  .blog-comment-textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 0.9375rem;
    background: #ffffff;
    color: #1a1a1b;
  }

  :root.dark .blog-comment-input,
  html.dark .blog-comment-input,
  :root.dark .blog-comment-textarea,
  html.dark .blog-comment-textarea {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.2);
    color: #f5f5f7;
  }

  .blog-comment-submit {
    background: #0071e3;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 0.75rem 1.5rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s ease;
  }

  .blog-comment-submit:hover {
    background: #0077ed;
  }

  .blog-comments-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .blog-comment {
    padding: 1rem;
    background: #ffffff;
    border-radius: 8px;
    border: 1px solid #e5e7eb;
  }

  :root.dark .blog-comment,
  html.dark .blog-comment {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.1);
  }

  .blog-comment-header {
    display: flex;
    gap: 1rem;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
  }

  .blog-comment-author {
    font-weight: 600;
    color: #1a1a1b;
  }

  :root.dark .blog-comment-author,
  html.dark .blog-comment-author {
    color: #f5f5f7;
  }

  .blog-comment-date {
    color: #787c7e;
  }

  :root.dark .blog-comment-date,
  html.dark .blog-comment-date {
    color: #a1a1a6;
  }

  .blog-comment-content {
    color: #1c1c1c;
    line-height: 1.6;
    white-space: pre-wrap;
  }

  :root.dark .blog-comment-content,
  html.dark .blog-comment-content {
    color: #d2d2d7;
  }
  """

  def render_template(assigns, attrs, state) do
    article = Map.get(assigns, :article)

    if article do
      # Show single article
      render_show_template(assigns, attrs, state)
    else
      # Show article list
      articles = Map.get(assigns, :articles, [])

      # Merge component-specific class with capsule attrs
      final_attrs = Keyword.put(attrs, :class, "blog-container")

      div(state, final_attrs, fn state ->
          state
          |> div([class: "container"], fn state ->
            state
            |> div([class: "blog-posts"], fn state ->
            Enum.reduce(articles, state, fn article, acc_state ->
              render_post(acc_state, article)
            end)
          end)
        end)
      end)
    end
  end

  defp render_post(state, article) do
    article(state, [class: "blog-post"], fn state ->
      state
      |> div([class: "blog-vote"], fn state ->
        state
        |> button([class: "blog-vote-button"], "▲")
        |> div([class: "blog-vote-count"], "45")
        |> button([class: "blog-vote-button"], "▼")
      end)
      |> div([class: "blog-content"], fn state ->
        state
        |> div([class: "blog-meta"], fn state ->
          state
          |> span([class: "blog-category"], article.category)
          |> span([class: "blog-author"], "by #{article.author}")
          |> span([class: "blog-date"], format_date(article.date))
        end)
        |> h2([class: "blog-post-title"], fn state ->
          a(state, [href: "/blog/#{article.id}"], article.title)
        end)
        |> p([class: "blog-excerpt"], article.excerpt)
        |> details([], fn state ->
          state
          |> summary([style: "cursor: pointer; color: #0079d3; font-weight: 500; margin-top: 0.5rem;"], "Read more")
          |> div([class: "blog-details"], fn state ->
            p(state, [class: "blog-full-content"], article.content)
          end)
        end)
        |> div([class: "blog-actions"], fn state ->
          state
          |> a([class: "blog-action", href: "/blog/#{article.id}"], fn state ->
            state
            |> Phlex.SGML.append_text("💬 ")
            |> Phlex.SGML.append_text("#{Map.get(article, :comments_count, 0)} comments")
          end)
          |> a([class: "blog-action", href: "/blog/#{article.id}"], fn state ->
            state
            |> Phlex.SGML.append_text("❤️ ")
            |> Phlex.SGML.append_text("#{Map.get(article, :likes_count, 0)} likes")
          end)
          |> a([class: "blog-action", href: "/blog/#{article.id}"], fn state ->
            state
            |> Phlex.SGML.append_text("📖 ")
            |> Phlex.SGML.append_text("Read more")
          end)
        end)
      end)
    end)
  end

  def render_show(assigns) do
    # Use the component's render method to get proper state handling
    render(assigns)
  end

  defp render_show_template(assigns, attrs, state) do
    article = Map.get(assigns, :article)
    likes_count = Map.get(assigns, :likes_count, 0)
    comments = Map.get(assigns, :comments, [])
    new_comment = Map.get(assigns, :new_comment, %{author: "", content: ""})

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "blog-container")

    div(state, final_attrs, fn state ->
      state
      |> div([class: "container"], fn state ->
        state
        |> a([href: "/blog", class: "blog-back-link", style: "display: inline-block; margin-bottom: 2rem; color: #0071e3; text-decoration: none; font-weight: 500;"], "← Back to Blog")
        |> div([class: "blog-post-single"], fn state ->
          state
          |> div([class: "blog-post-header"], fn state ->
            state
            |> div([class: "blog-meta"], fn state ->
              state
              |> span([class: "blog-category"], article.category)
              |> span([class: "blog-author"], "by #{article.author}")
              |> span([class: "blog-date"], format_date(article.date))
            end)
            |> h1([class: "blog-post-title-single"], article.title)
            |> div([class: "blog-actions-single"], fn state ->
              state
              |> button([
                class: "blog-like-button",
                phx_click: "like",
                phx_value_article_id: article.id
              ], fn state ->
                state
                |> Phlex.SGML.append_text("❤️ ")
                |> Phlex.SGML.append_text("#{likes_count} likes")
              end)
              |> span([class: "blog-comments-count"], "💬 #{length(comments)} comments")
            end)
          end)
          |> div([class: "blog-post-content"], fn state ->
            p(state, [class: "blog-full-content"], article.content)
          end)
          |> div([class: "blog-comments-section"], fn state ->
            state
            |> h3([class: "blog-comments-title"], "Comments (#{length(comments)})")
            |> form([phx_submit: "add_comment", class: "blog-comment-form"], fn state ->
              state
              |> div([class: "blog-comment-field"], fn state ->
                state
                |> label([for: "comment_author", class: "blog-comment-label"], "Your Name")
                |> input([
                  type: "text",
                  id: "comment_author",
                  name: "comment[author]",
                  value: new_comment[:author] || "",
                  class: "blog-comment-input",
                  required: true
                ])
              end)
              |> div([class: "blog-comment-field"], fn state ->
                state
                |> label([for: "comment_content", class: "blog-comment-label"], "Your Comment")
                |> textarea([
                  id: "comment_content",
                  name: "comment[content]",
                  rows: "4",
                  class: "blog-comment-textarea",
                  required: true
                ], new_comment[:content] || "")
              end)
              |> button([type: "submit", class: "blog-comment-submit"], "Post Comment")
            end)
            |> div([class: "blog-comments-list"], fn state ->
              Enum.reduce(comments, state, fn comment, acc_state ->
                render_comment(acc_state, comment)
              end)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_comment(state, comment) do
    div(state, [class: "blog-comment"], fn state ->
      state
      |> div([class: "blog-comment-header"], fn state ->
        state
        |> span([class: "blog-comment-author"], comment.author)
        |> span([class: "blog-comment-date"], format_datetime(comment.inserted_at))
      end)
      |> div([class: "blog-comment-content"], comment.content)
    end)
  end

  defp format_date(%Date{} = date), do: Date.to_string(date)
  defp format_date(date) when is_binary(date), do: date
  defp format_date(_), do: ""

  defp format_datetime(%DateTime{} = dt) do
    dt
    |> DateTime.to_date()
    |> Date.to_string()
  end
  defp format_datetime(_), do: ""
end
