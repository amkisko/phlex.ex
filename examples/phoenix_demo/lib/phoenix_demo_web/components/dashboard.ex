defmodule PhoenixDemoWeb.Components.Dashboard do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .dashboard-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
  }

  .stat-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 1.75rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    transition: all 0.2s ease;
  }

  .stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  }

  .stat-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1rem;
  }

  .stat-icon {
    font-size: 2rem;
  }

  .stat-badge {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
    border-radius: 9999px;
    font-weight: 500;
  }

  .stat-value {
    font-size: 32px;
    font-weight: 600;
    color: #1d1d1f;
    letter-spacing: -0.02em;
  }

  .reservations-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
  }

  .reservations-title {
    font-size: 28px;
    font-weight: 600;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
    letter-spacing: -0.02em;
  }

  .table-container {
    overflow-x: auto;
  }

  .table {
    width: 100%;
    border-collapse: collapse;
  }

  .table-header {
    border-bottom: 1px solid #e5e7eb;
  }

  .table-header-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
  }

  .table-row {
    border-bottom: 1px solid #f3f4f6;
  }

  .table-row:hover {
    background-color: #f9fafb;
  }

  .table-cell {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    color: #111827;
  }

  .table-cell-muted {
    color: #6b7280;
  }

  .status-badge {
    padding: 0.25rem 0.5rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .status-confirmed {
    background-color: #d1fae5;
    color: #065f46;
  }

  .status-pending {
    background-color: #fef3c7;
    color: #92400e;
  }

  .status-default {
    background-color: #f3f4f6;
    color: #374151;
  }
  """

  def render_template(assigns, attrs, state) do
    stats = Map.get(assigns, :stats, %{})
    recent_reservations = Map.get(assigns, :recent_reservations, [])

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "dashboard-container")

    div(state, final_attrs, fn state ->
      state
      |> div([class: "container"], fn state ->
        state
        |> render_stats_grid(stats)
        |> render_reservations_table(recent_reservations)
      end)
    end)
  end

  defp render_stats_grid(state, stats) do
    div(state, [class: "stats-grid"], fn state ->
      state
      |> render_stat_card("📅", "Total Reservations", "#{Map.get(stats, :total_reservations, 0)}", "blue")
      |> render_stat_card("👥", "Active Customers", "#{Map.get(stats, :active_customers, 0)}", "green")
      |> render_stat_card("💰", "Revenue", "$#{format_currency(Map.get(stats, :revenue, 0))}", "yellow")
      |> render_stat_card("📊", "Occupancy Rate", "#{Map.get(stats, :occupancy_rate, 0)}%", "purple")
    end)
  end

  defp render_stat_card(state, icon, label, value, color) do
    color_classes = %{
      "blue" => "bg-blue-100 text-blue-800",
      "green" => "bg-green-100 text-green-800",
      "yellow" => "bg-yellow-100 text-yellow-800",
      "purple" => "bg-purple-100 text-purple-800"
    }

    badge_class = Map.get(color_classes, color, "bg-gray-100 text-gray-800")

    div(state, [class: "stat-card"], fn state ->
      state
      |> div([class: "stat-header"], fn state ->
        state
        |> span([class: "stat-icon"], icon)
        |> span([class: "stat-badge #{badge_class}"], label)
      end)
      |> h3([class: "stat-value"], value)
    end)
  end

  defp render_reservations_table(state, reservations) do
    div(state, [class: "reservations-card"], fn state ->
      state
      |> h2([class: "reservations-title"], "Recent Reservations")
      |> div([class: "table-container"], fn state ->
        table(state, [class: "table"], fn state ->
          state
          |> thead([class: "table-header"], fn state ->
            tr(state, [], fn state ->
              state
              |> th([class: "table-header-cell"], "ID")
              |> th([class: "table-header-cell"], "Customer")
              |> th([class: "table-header-cell"], "Check-in")
              |> th([class: "table-header-cell"], "Check-out")
              |> th([class: "table-header-cell"], "Status")
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
  end

  defp render_reservation_row(state, reservation) do
    status_class = status_class(reservation.status)
    status_text = String.capitalize(reservation.status || "")

    tr(state, [class: "table-row"], fn state ->
      state
      |> td([class: "table-cell"], "##{reservation.id}")
      |> td([class: "table-cell"], reservation.customer || "")
      |> td([class: "table-cell table-cell-muted"], format_date(reservation.check_in))
      |> td([class: "table-cell table-cell-muted"], format_date(reservation.check_out))
      |> td([class: "table-cell"], fn state ->
        span(state, [class: "status-badge #{status_class}"], status_text)
      end)
    end)
  end

  defp format_currency(amount) do
    amount
    |> Integer.to_string()
    |> String.replace(~r/(\d)(?=(\d{3})+(?!\d))/, "\\1,")
  end

  defp format_date(nil), do: ""
  defp format_date(%Date{} = date), do: Date.to_string(date)
  defp format_date(date) when is_binary(date), do: date

  defp status_class("confirmed"), do: "status-confirmed"
  defp status_class("pending"), do: "status-pending"
  defp status_class(_), do: "status-default"
end
