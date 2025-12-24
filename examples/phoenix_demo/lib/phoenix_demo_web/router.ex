defmodule PhoenixDemoWeb.Router do
  use PhoenixDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixDemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PhoenixDemoWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/showcase", PageLive, :index
    live "/auth", AuthLive, :index
    live "/reservations", ReservationsLive, :index
    live "/customers", CustomersLive, :index
    live "/chat", ChatLive, :index
    live "/admin", AdminLive, :index
    live "/admin/chat", AdminChatLive, :index
    live "/admin/reservations", AdminReservationsLive, :index
    live "/admin/blog", AdminBlogLive, :index
    live "/todos", TodosLive, :index
    live "/blog", BlogLive, :index
    live "/blog/:id", BlogLive, :show
    live "/surveys", SurveysLive, :index
  end
end
