defmodule PhoenixDemoWeb.CustomersLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.Customer

  @impl true
  def mount(_params, _session, socket) do
    customers =
      Repo.all(
        from c in Customer,
          order_by: [desc: c.inserted_at],
          select: %{
            id: c.id,
            name: c.name,
            email: c.email,
            phone: c.phone,
            status: c.status,
            reservations: c.total_reservations,
            total_spent: c.total_spent
          }
      )

    {:ok,
     socket
     |> assign(:search, "")
     |> assign(:customers, customers)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    filtered_customers = filter_customers(socket.assigns.customers, search)
    {:noreply, socket |> assign(:search, search) |> assign(:filtered_customers, filtered_customers)}
  end

  @impl true
  def render(assigns) do
    filtered_customers = filter_customers(assigns.customers, assigns.search)

    component_assigns = %{
      search: assigns.search,
      filtered_customers: filtered_customers
    }

    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Customers.render(component_assigns)
    )
  end

  defp filter_customers(customers, ""), do: customers
  defp filter_customers(customers, search) do
    search_lower = String.downcase(search)
    Enum.filter(customers, fn customer ->
      String.contains?(String.downcase(customer.name), search_lower) or
      String.contains?(String.downcase(customer.email), search_lower) or
      String.contains?(customer.phone, search)
    end)
  end
end
