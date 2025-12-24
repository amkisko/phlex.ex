defmodule PhoenixDemoWeb.SurveysLive do
  use PhoenixDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:recommend_score, 5)}
  end

  @impl true
  def handle_event("update_recommend_score", %{"survey" => %{"recommend_score" => value}}, socket) do
    score = String.to_integer(value)
    {:noreply, assign(socket, :recommend_score, score)}
  end

  def handle_event("update_recommend_score", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_survey", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Survey submitted successfully!")}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      recommend_score: assigns.recommend_score
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Surveys.render(component_assigns)
    )
  end
end
