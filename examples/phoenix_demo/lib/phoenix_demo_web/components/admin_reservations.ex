defmodule PhoenixDemoWeb.Components.AdminReservations do
  use PhoenixDemoWeb.Components.Base, namespace: :admin

  @component_styles """
  .admin-reservations-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .admin-reservations-card {
    background: #ffffff;
    border-radius: 12px;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    padding: 2rem;
  }

  .admin-reservations-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .admin-reservations-table {
    width: 100%;
    border-collapse: collapse;
  }

  .admin-reservations-table-header {
    border-bottom: 1px solid #e5e7eb;
    background: #f9fafb;
  }

  .admin-reservations-table-header-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
  }

  .admin-reservations-table-row {
    border-bottom: 1px solid #f3f4f6;
  }

  .admin-reservations-table-row:hover {
    background-color: #f9fafb;
  }

  .admin-reservations-table-cell {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    color: #1d1d1f;
  }

  .admin-reservations-status-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .admin-reservations-status-pending {
    background: #fef3c7;
    color: #92400e;
  }

  .admin-reservations-status-confirmed {
    background: #d1fae5;
    color: #065f46;
  }

  .admin-reservations-status-cancelled {
    background: #fee2e2;
    color: #991b1b;
  }
  """

  def render_template(assigns, attrs, state) do
    reservations = Map.get(assigns, :reservations, [])

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "admin-reservations-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "admin-reservations-card"], fn state ->
          state
          |> h2([class: "admin-reservations-card-title"], "All Reservations (#{length(reservations)})")
          |> div([style: "overflow-x: auto;"], fn state ->
            table(state, [class: "admin-reservations-table"], fn state ->
              state
              |> thead([class: "admin-reservations-table-header"], fn state ->
                tr(state, [], fn state ->
                  state
                  |> th([class: "admin-reservations-table-header-cell"], "ID")
                  |> th([class: "admin-reservations-table-header-cell"], "Customer")
                  |> th([class: "admin-reservations-table-header-cell"], "Contact")
                  |> th([class: "admin-reservations-table-header-cell"], "Check In")
                  |> th([class: "admin-reservations-table-header-cell"], "Check Out")
                  |> th([class: "admin-reservations-table-header-cell"], "Guests")
                  |> th([class: "admin-reservations-table-header-cell"], "Room Type")
                  |> th([class: "admin-reservations-table-header-cell"], "Status")
                end)
              end)
              |> tbody([], fn state ->
                Enum.reduce(reservations, state, fn reservation, acc_state ->
                  render_reservation_row(acc_state, reservation)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_reservation_row(state, reservation) do
    status_class = case reservation.status do
      "pending" -> "admin-reservations-status-badge admin-reservations-status-pending"
      "confirmed" -> "admin-reservations-status-badge admin-reservations-status-confirmed"
      "cancelled" -> "admin-reservations-status-badge admin-reservations-status-cancelled"
      _ -> "admin-reservations-status-badge admin-reservations-status-pending"
    end

    tr(state, [class: "admin-reservations-table-row"], fn state ->
      state
      |> td([class: "admin-reservations-table-cell"], "##{reservation.id}")
      |> td([class: "admin-reservations-table-cell"], reservation.customer)
      |> td([class: "admin-reservations-table-cell"], fn state ->
        state
        |> div([], reservation.email)
        |> div([style: "font-size: 0.75rem; color: #6b7280;"], reservation.phone)
      end)
      |> td([class: "admin-reservations-table-cell"], Date.to_string(reservation.check_in))
      |> td([class: "admin-reservations-table-cell"], Date.to_string(reservation.check_out))
      |> td([class: "admin-reservations-table-cell"], "#{reservation.guests}")
      |> td([class: "admin-reservations-table-cell"], reservation.room_type)
      |> td([class: "admin-reservations-table-cell"], fn state ->
        span(state, [class: status_class], String.capitalize(reservation.status))
      end)
    end)
  end
end
