defmodule PhoenixDemoWeb.Components.Reservations do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .reservations-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .reservations-grid {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 2rem;
  }

  .form-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
  }

  .form-title {
    font-size: 28px;
    font-weight: 600;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
    letter-spacing: -0.02em;
  }

  .form-group {
    margin-bottom: 1rem;
  }

  .form-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    margin-bottom: 0.25rem;
  }

  .form-input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    font-size: 15px;
    background: #ffffff;
    transition: all 0.2s ease;
  }

  .form-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
  }

  .form-button {
    width: 100%;
    background: #0071e3;
    color: white;
    padding: 0.875rem;
    border-radius: 8px;
    font-weight: 500;
    font-size: 15px;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .form-button:hover {
    background: #0077ed;
    transform: translateY(-1px);
  }

  .form-button:active {
    transform: translateY(0);
  }

  .table-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
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
    background: #f9fafb;
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
  """

  def render_template(assigns, attrs, state) do
    form_data = Map.get(assigns, :form_data, %{})
    reservations = Map.get(assigns, :reservations, [])

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "reservations-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "reservations-grid"], fn state ->
          state
          |> render_booking_form(form_data)
          |> render_reservations_list(reservations)
        end)
      end)
    end)
  end

  defp render_booking_form(state, form_data) do
    div(state, [class: "form-card"], fn state ->
      state
      |> h2([class: "form-title"], "New Reservation")
      |> form([phx_submit: "submit", class: "space-y-4"], fn state ->
        state
        |> render_form_field("customer_name", "Customer Name", "text", Map.get(form_data, :customer_name, ""))
        |> render_form_field("email", "Email", "email", Map.get(form_data, :email, ""))
        |> render_form_field("phone", "Phone", "tel", Map.get(form_data, :phone, ""))
        |> render_form_field("check_in", "Check-in Date", "date", Map.get(form_data, :check_in, ""))
        |> render_form_field("check_out", "Check-out Date", "date", Map.get(form_data, :check_out, ""))
        |> render_form_field("guests", "Number of Guests", "number", Map.get(form_data, :guests, "2"), [min: "1", max: "10"])
        |> render_select_field("room_type", "Room Type", Map.get(form_data, :room_type, "Deluxe"))
        |> render_textarea_field("special_requests", "Special Requests", Map.get(form_data, :special_requests, ""))
        |> button([type: "submit", class: "form-button"], "Create Reservation")
      end)
    end)
  end

  defp render_form_field(state, name, label, type, value, extra_attrs \\ []) do
    div(state, [class: "form-group"], fn state ->
      state
      |> label([for: name, class: "form-label"], label)
      |> input([
        type: type,
        id: name,
        name: "reservation[#{name}]",
        value: value,
        required: true,
        class: "form-input"
      ] ++ extra_attrs)
    end)
  end

  defp render_select_field(state, name, label, selected_value) do
    div(state, [class: "form-group"], fn state ->
      state
      |> label([for: name, class: "form-label"], label)
      |> select([id: name, name: "reservation[#{name}]", required: true, class: "form-input"], fn state ->
        state
        |> render_option("Standard", selected_value)
        |> render_option("Deluxe", selected_value)
        |> render_option("Suite", selected_value)
        |> render_option("Penthouse", selected_value)
      end)
    end)
  end

  defp render_option(state, value, selected_value) do
    attrs = [value: value]
    attrs = if value == selected_value, do: Keyword.put(attrs, :selected, true), else: attrs
    option(state, attrs, value)
  end

  defp render_textarea_field(state, name, label, value) do
    div(state, [class: "form-group"], fn state ->
      state
      |> label([for: name, class: "form-label"], label)
      |> textarea([
        id: name,
        name: "reservation[#{name}]",
        rows: "3",
        class: "form-input"
      ], value)
    end)
  end

  defp render_reservations_list(state, reservations) do
    div(state, [class: "table-card"], fn state ->
      state
      |> h2([class: "form-title"], "All Reservations")
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
              |> th([class: "table-header-cell"], "Guests")
              |> th([class: "table-header-cell"], "Room")
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
    status_class = if reservation.status == "confirmed", do: "status-confirmed", else: "status-pending"
    status_text = String.capitalize(reservation.status || "")

    tr(state, [class: "table-row"], fn state ->
      state
      |> td([class: "table-cell"], "##{reservation.id}")
      |> td([class: "table-cell"], reservation.customer || "")
      |> td([class: "table-cell"], format_date(reservation.check_in))
      |> td([class: "table-cell"], format_date(reservation.check_out))
      |> td([class: "table-cell"], "#{reservation.guests || 1}")
      |> td([class: "table-cell"], reservation.room_type || "")
      |> td([class: "table-cell"], fn state ->
        span(state, [class: "status-badge #{status_class}"], status_text)
      end)
    end)
  end

  defp format_date(nil), do: ""
  defp format_date(%Date{} = date), do: Date.to_string(date)
  defp format_date(date) when is_binary(date), do: date
end
