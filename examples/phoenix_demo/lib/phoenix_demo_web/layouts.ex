defmodule PhoenixDemoWeb.Layouts do
  use PhoenixDemoWeb, :html

  # Root layout now uses Phlex component instead of HEEx template
  def root(assigns) do
    # Extract necessary assigns for Phlex component
    # For LiveView, get path from URI or conn
    current_path = cond do
      # Try URI first (for LiveView)
      assigns[:uri] && assigns[:uri].path -> assigns[:uri].path
      # Fallback to conn.request_path (for regular controllers)
      assigns[:conn] && assigns[:conn].request_path -> assigns[:conn].request_path
      # Default to "/"
      true -> "/"
    end
    page_title = assigns[:page_title] || "Component Gallery"
    csrf_token = Phoenix.Controller.get_csrf_token()

    # Render Phlex layout component and mark as safe HTML
    # Phoenix's layout system expects safe HTML, not a Phlex struct
    layout_html = PhoenixDemoWeb.Components.RootLayout.render(%{
      current_path: current_path,
      page_title: page_title,
      inner_content: assigns[:inner_content],
      csrf_token: csrf_token
    })

    # Mark as safe HTML to prevent escaping
    Phoenix.HTML.raw(layout_html)
  end
end
