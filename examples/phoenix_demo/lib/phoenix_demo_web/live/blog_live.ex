defmodule PhoenixDemoWeb.BlogLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.{Article, ArticleLike, ArticleComment}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Show page
    article = Repo.get!(Article, String.to_integer(id))

    likes_count = Repo.aggregate(
      from(l in ArticleLike, where: l.article_id == ^article.id),
      :count,
      :id
    ) || 0

    comments = Repo.all(
      from c in ArticleComment,
        where: c.article_id == ^article.id,
        order_by: [asc: c.inserted_at],
        select: %{
          id: c.id,
          author: c.author,
          content: c.content,
          inserted_at: c.inserted_at
        }
    )

    {:ok,
     socket
     |> assign(:article, article)
     |> assign(:likes_count, likes_count)
     |> assign(:comments, comments)
     |> assign(:new_comment, %{author: "", content: ""})}
  end

  def mount(_params, _session, socket) do
    # Index page
    articles =
      Repo.all(
        from a in Article,
          order_by: [desc: a.date],
          select: %{
            id: a.id,
            title: a.title,
            author: a.author,
            date: a.date,
            excerpt: a.excerpt,
            content: a.content,
            category: a.category
          }
      )

    # Get likes count for each article
    article_ids = Enum.map(articles, & &1.id)
    likes_counts = Repo.all(
      from l in ArticleLike,
        where: l.article_id in ^article_ids,
        group_by: l.article_id,
        select: {l.article_id, count(l.id)}
    ) |> Enum.into(%{})

    # Get comments count for each article
    comments_counts = Repo.all(
      from c in ArticleComment,
        where: c.article_id in ^article_ids,
        group_by: c.article_id,
        select: {c.article_id, count(c.id)}
    ) |> Enum.into(%{})

    articles_with_counts = Enum.map(articles, fn article ->
      Map.merge(article, %{
        likes_count: Map.get(likes_counts, {article.id}, 0),
        comments_count: Map.get(comments_counts, {article.id}, 0)
      })
    end)

    {:ok, socket |> assign(:articles, articles_with_counts)}
  end

  @impl true
  def handle_event("like", %{"article_id" => article_id}, socket) do
    # Get user IP (simplified - in production use proper IP detection)
    user_ip = "127.0.0.1" # Simplified for demo

    # Check if already liked
    existing_like = Repo.one(
      from l in ArticleLike,
        where: l.article_id == ^String.to_integer(article_id) and l.user_ip == ^user_ip
    )

    if existing_like do
      # Unlike - remove the like
      Repo.delete!(existing_like)
    else
      # Like - add the like
      max_id = Repo.aggregate(ArticleLike, :max, :id) || 0
      next_id = max_id + 1

      %ArticleLike{}
      |> Ecto.Changeset.change(%{
        id: next_id,
        article_id: String.to_integer(article_id),
        user_ip: user_ip
      })
      |> Repo.insert!()
    end

    # Reload likes count
    likes_count = Repo.aggregate(
      from(l in ArticleLike, where: l.article_id == ^String.to_integer(article_id)),
      :count,
      :id
    ) || 0

    {:noreply, assign(socket, :likes_count, likes_count)}
  end

  @impl true
  def handle_event("add_comment", %{"comment" => comment_params}, socket) do
    max_id = Repo.aggregate(ArticleComment, :max, :id) || 0
    next_id = max_id + 1

    %ArticleComment{}
    |> Ecto.Changeset.change(%{
      id: next_id,
      article_id: socket.assigns.article.id,
      author: comment_params["author"],
      content: comment_params["content"]
    })
    |> Repo.insert!()

    # Reload comments
    comments = Repo.all(
      from c in ArticleComment,
        where: c.article_id == ^socket.assigns.article.id,
        order_by: [asc: c.inserted_at],
        select: %{
          id: c.id,
          author: c.author,
          content: c.content,
          inserted_at: c.inserted_at
        }
    )

    {:noreply,
     socket
     |> assign(:comments, comments)
     |> assign(:new_comment, %{author: "", content: ""})
     |> put_flash(:info, "Comment added successfully!")}
  end

  @impl true
  def handle_event("update_comment", %{"comment" => comment_params}, socket) do
    {:noreply, assign(socket, :new_comment, comment_params)}
  end

  @impl true
  def render(assigns) do
    if Map.has_key?(assigns, :article) do
      # Show page
      component_assigns = %{
        article: assigns.article,
        likes_count: assigns.likes_count,
        comments: assigns.comments,
        new_comment: assigns.new_comment
      }
      PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
        PhoenixDemoWeb.Components.Blog.render(component_assigns)
      )
    else
      # Index page
      component_assigns = %{
        articles: assigns.articles
      }
      PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
        PhoenixDemoWeb.Components.Blog.render(component_assigns)
      )
    end
  end
end
