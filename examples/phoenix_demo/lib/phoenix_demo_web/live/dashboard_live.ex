defmodule PhoenixDemoWeb.DashboardLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.{Reservation, Customer}

  @impl true
  def mount(_params, _session, socket) do
    total_reservations = Repo.aggregate(Reservation, :count, :id)
    active_customers = Repo.aggregate(from(c in Customer, where: c.status == "active"), :count, :id)
    revenue = Repo.aggregate(Customer, :sum, :total_spent) || 0

    # Calculate occupancy rate from reservations
    today = Date.utc_today()
    total_rooms = 50 # Assume 50 total rooms
    occupied_rooms = Repo.aggregate(
      from(r in Reservation,
        where: r.check_in <= ^today and r.check_out >= ^today
      ),
      :count,
      :id
    ) || 0
    occupancy_rate = if total_rooms > 0, do: trunc(occupied_rooms / total_rooms * 100), else: 0

    recent_reservations =
      Repo.all(
        from r in Reservation,
          order_by: [desc: r.inserted_at],
          limit: 3,
          select: %{
            id: r.id,
            customer: r.customer_name,
            check_in: r.check_in,
            check_out: r.check_out,
            status: r.status
          }
      )

    {:ok,
     socket
     |> assign(:stats, %{
       total_reservations: total_reservations,
       active_customers: active_customers,
       revenue: revenue,
       occupancy_rate: occupancy_rate
     })
     |> assign(:recent_reservations, recent_reservations)}
  end

  @impl true
  def render(assigns) do
    # Convert LiveView assigns to a map for Phlex component
    component_assigns = %{
      stats: assigns.stats,
      recent_reservations: assigns.recent_reservations
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Dashboard.render(component_assigns)
    )
  end
end
