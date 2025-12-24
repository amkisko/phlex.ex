defmodule PhoenixDemoWeb.Components.Customers do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .customers-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
    transition: background-color 0.2s ease;
  }

  :root.dark .customers-container,
  html.dark .customers-container {
    background: #1d1d1f;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .search-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 1.5rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    margin-bottom: 1.5rem;
  }

  :root.dark .search-card,
  html.dark .search-card {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.1);
  }

  .search-form {
    display: flex;
    gap: 1rem;
  }

  .search-input {
    flex: 1;
    padding: 0.75rem 1rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    font-size: 15px;
    background: #ffffff;
    transition: all 0.2s ease;
  }

  .search-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
  }

  .search-button {
    padding: 0.5rem 1.5rem;
    background: #2563eb;
    color: white;
    border-radius: 0.5rem;
    font-weight: 600;
    border: none;
    cursor: pointer;
  }

  .table-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
  }

  :root.dark .table-card,
  html.dark .table-card {
    background: #2d2d2f;
    border-color: rgba(255, 255, 255, 0.1);
  }

  .table-title {
    font-size: 28px;
    font-weight: 600;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
    letter-spacing: -0.02em;
  }

  :root.dark .table-title,
  html.dark .table-title {
    color: #f5f5f7;
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

  :root.dark .table-cell,
  html.dark .table-cell {
    color: #f5f5f7;
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

  .status-active {
    background-color: #d1fae5;
    color: #065f46;
  }

  .status-vip {
    background-color: #e9d5ff;
    color: #6b21a8;
  }

  .status-inactive {
    background-color: #f3f4f6;
    color: #374151;
  }
  """

  def render_template(assigns, attrs, state) do
    search = Map.get(assigns, :search, "")
    filtered_customers = Map.get(assigns, :filtered_customers, [])

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "customers-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> render_search_form(search)
          |> render_customers_table(filtered_customers)
      end)
    end)
  end

  defp render_search_form(state, search_value) do
    div(state, [class: "search-card"], fn state ->
      form(state, [phx_change: "search", class: "search-form"], fn state ->
        state
        |> div([class: "flex-1"], fn state ->
          input(state, [
            type: "search",
            name: "search",
            value: search_value,
            phx_debounce: "300",
            placeholder: "Search customers by name, email, or phone...",
            class: "search-input"
          ])
        end)
      end)
    end)
  end

  defp render_customers_table(state, customers) do
    div(state, [class: "table-card"], fn state ->
      state
      |> h2([class: "table-title"], "All Customers (#{length(customers)})")
      |> div([class: "table-container"], fn state ->
        table(state, [class: "table"], fn state ->
          state
          |> thead([class: "table-header"], fn state ->
            tr(state, [], fn state ->
              state
              |> th([class: "table-header-cell"], "ID")
              |> th([class: "table-header-cell"], "Name")
              |> th([class: "table-header-cell"], "Contact")
              |> th([class: "table-header-cell"], "Reservations")
              |> th([class: "table-header-cell"], "Total Spent")
              |> th([class: "table-header-cell"], "Status")
            end)
          end)
          |> tbody([], fn state ->
            Enum.reduce(customers, state, fn customer, acc_state ->
              render_customer_row(acc_state, customer)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_customer_row(state, customer) do
    status_class = status_class(customer.status)
    status_text = String.upcase(customer.status || "")

    tr(state, [class: "table-row"], fn state ->
      state
      |> td([class: "table-cell"], "##{customer.id}")
      |> td([class: "table-cell"], fn state ->
        span(state, [class: "font-medium"], customer.name || "")
      end)
      |> td([class: "table-cell table-cell-muted"], fn state ->
        state
        |> div([], customer.email || "")
        |> div([class: "text-xs"], customer.phone || "")
      end)
      |> td([class: "table-cell table-cell-muted"], "#{customer.reservations || 0}")
      |> td([class: "table-cell"], fn state ->
        span(state, [class: "font-semibold"], "$#{format_currency(customer.total_spent || 0)}")
      end)
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

  defp status_class("active"), do: "status-active"
  defp status_class("vip"), do: "status-vip"
  defp status_class("inactive"), do: "status-inactive"
  defp status_class(_), do: "status-inactive"
end
