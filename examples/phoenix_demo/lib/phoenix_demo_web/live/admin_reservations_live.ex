defmodule PhoenixDemoWeb.AdminReservationsLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.Reservation

  @impl true
  def mount(_params, _session, socket) do
    reservations =
      Repo.all(
        from r in Reservation,
          order_by: [desc: r.inserted_at],
          select: %{
            id: r.id,
            customer: r.customer_name,
            email: r.customer_email,
            phone: r.customer_phone,
            check_in: r.check_in,
            check_out: r.check_out,
            guests: r.guests,
            room_type: r.room_type,
            status: r.status
          }
      )

    {:ok, socket |> assign(:reservations, reservations)}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      reservations: assigns.reservations
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.AdminReservations.render(component_assigns)
    )
  end
end
