defmodule PhoenixDemoWeb.PageLive do
  use PhoenixDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  @impl true
  def render(_assigns) do
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.PageGallery.render(%{})
    )
  end
end
