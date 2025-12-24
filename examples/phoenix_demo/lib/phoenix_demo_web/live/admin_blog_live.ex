defmodule PhoenixDemoWeb.AdminBlogLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.Article

  @impl true
  def mount(_params, _session, socket) do
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

    {:ok,
     socket
     |> assign(:articles, articles)
     |> assign(:form_data, %{
       title: "",
       author: "Admin",
       category: "News",
       excerpt: "",
       content: ""
     })}
  end

  @impl true
  def handle_event("create_post", %{"article" => params}, socket) do
    # Get next ID
    max_id = Repo.aggregate(Article, :max, :id) || 0
    next_id = max_id + 1

    attrs = %{
      id: next_id,
      title: params["title"],
      author: params["author"],
      category: params["category"],
      excerpt: params["excerpt"],
      content: params["content"],
      date: Date.utc_today()
    }

    %Article{}
    |> Ecto.Changeset.change(attrs)
    |> Repo.insert!()

    # Reload articles
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

    {:noreply, socket |> assign(:articles, articles) |> assign(:form_data, %{title: "", author: "Admin", category: "News", excerpt: "", content: ""}) |> put_flash(:info, "Post created successfully!")}
  end

  @impl true
  def handle_event("update_form", %{"article" => params}, socket) do
    updated_form = Map.merge(socket.assigns.form_data, params)
    {:noreply, assign(socket, :form_data, updated_form)}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      articles: assigns.articles,
      form_data: assigns.form_data
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.AdminBlog.render(component_assigns)
    )
  end
end
