defmodule PhoenixDemoWeb.AuthLive do
  use PhoenixDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form_data, %{
       email: "admin@example.demo",
       password: "demo_password"
     })}
  end

  @impl true
  def handle_event("login", %{"email" => _email, "password" => _password}, socket) do
    {:noreply, socket |> put_flash(:info, "Login successful! (Demo mode)")}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      form_data: assigns.form_data
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Auth.render(component_assigns)
    )
  end
end
