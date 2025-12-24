defmodule PhoenixDemoWeb.ReservationsLive do
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

    # Pre-fill form with demo data
    demo_form_data = %{
      customer_name: "Customer One",
      email: "john@example.com",
      phone: "+1-555-0101",
      check_in: Date.add(Date.utc_today(), 7) |> Date.to_string(),
      check_out: Date.add(Date.utc_today(), 10) |> Date.to_string(),
      guests: "2",
      room_type: "Deluxe",
      special_requests: "Late check-in requested"
    }

    {:ok,
     socket
     |> assign(:form_data, demo_form_data)
     |> assign(:reservations, reservations)}
  end

  @impl true
  def handle_event("submit", %{"reservation" => params}, socket) do
    alias PhoenixDemo.Schemas.Reservation

    # Get next ID
    max_id = Repo.aggregate(Reservation, :max, :id) || 0
    next_id = max_id + 1

    attrs = %{
      id: next_id,
      customer_name: params["customer_name"],
      customer_email: params["email"],
      customer_phone: params["phone"],
      check_in: Date.from_iso8601!(params["check_in"]),
      check_out: Date.from_iso8601!(params["check_out"]),
      guests: String.to_integer(params["guests"]),
      room_type: params["room_type"],
      special_requests: Map.get(params, "special_requests", ""),
      status: "pending"
    }

    %Reservation{}
    |> Ecto.Changeset.change(attrs)
    |> Repo.insert!()

    # Reload reservations
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

    {:noreply, socket |> assign(:reservations, reservations) |> put_flash(:info, "Reservation created successfully!")}
  end

  @impl true
  def render(assigns) do
    # Convert LiveView assigns to a map for Phlex component
    component_assigns = %{
      form_data: assigns.form_data,
      reservations: assigns.reservations
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Reservations.render(component_assigns)
    )
  end
end
