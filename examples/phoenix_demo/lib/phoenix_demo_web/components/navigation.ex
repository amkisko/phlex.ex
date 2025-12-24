defmodule PhoenixDemoWeb.Components.Navigation do
  use StyleCapsule.PhlexComponent,
    namespace: :navigation,
    strategy: PhoenixDemoWeb.StyleCapsuleConfig.strategy(),
    cache_strategy: :file

  @component_styles """
  .nav {
    background: rgba(251, 251, 253, 0.8);
    backdrop-filter: saturate(180%) blur(20px);
    -webkit-backdrop-filter: saturate(180%) blur(20px);
    border-bottom: 0.5px solid rgba(0, 0, 0, 0.1);
    padding: 0;
    position: sticky;
    top: 0;
    z-index: 1000;
  }

  .nav-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 44px;
  }

  /* Responsive navigation padding */
  @media (max-width: 768px) {
    .nav-container {
      padding: 0 1.5rem;
    }
  }

  @media (max-width: 480px) {
    .nav-container {
      padding: 0 1rem;
    }
  }

  .nav-logo {
    font-size: 17px;
    font-weight: 600;
    color: #1d1d1f;
    text-decoration: none;
    letter-spacing: -0.022em;
    transition: opacity 0.2s;
  }

  .nav-logo:hover {
    opacity: 0.8;
  }

  .nav-links {
    display: flex;
    gap: 0.5rem;
    list-style: none;
    margin: 0;
    padding: 0;
    align-items: center;
  }

  .nav-link {
    color: #1d1d1f;
    text-decoration: none;
    font-size: 12px;
    font-weight: 400;
    padding: 0 10px;
    height: 44px;
    display: flex;
    align-items: center;
    transition: opacity 0.2s;
    letter-spacing: -0.01em;
  }

  .nav-link:hover {
    opacity: 0.65;
  }

  .nav-link.active {
    opacity: 1;
    font-weight: 500;
  }

  .nav-link.active::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: #0071e3;
  }

  .dark-mode-toggle {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0 10px;
    height: 44px;
    display: flex;
    align-items: center;
    color: #1d1d1f;
    font-size: 18px;
    transition: opacity 0.2s;
  }

  .dark-mode-toggle:hover {
    opacity: 0.65;
  }

  /* Dark mode styles */
  :root.dark .nav,
  html.dark .nav {
    background: rgba(29, 29, 31, 0.8);
    border-bottom-color: rgba(255, 255, 255, 0.1);
  }

  :root.dark .nav-logo,
  html.dark .nav-logo,
  :root.dark .nav-link,
  html.dark .nav-link {
    color: #f5f5f7;
  }

  :root.dark .dark-mode-toggle,
  html.dark .dark-mode-toggle {
    color: #f5f5f7;
  }

  @media (prefers-color-scheme: dark) {
    :root:not(.light) .nav {
      background: rgba(29, 29, 31, 0.8);
      border-bottom-color: rgba(255, 255, 255, 0.1);
    }

    :root:not(.light) .nav-logo,
    :root:not(.light) .nav-link {
      color: #f5f5f7;
    }

    :root:not(.light) .dark-mode-toggle {
      color: #f5f5f7;
    }
  }
  """

  defp render_template(assigns, attrs, state) do
    current_path = Map.get(assigns, :current_path, "/")

    div(state, attrs, fn state ->
      nav(state, [class: "nav"], fn state ->
        state
        |> div([class: "nav-container"], fn state ->
          state
          |> a([class: "nav-logo", href: "/"], "DemoApp")
          |> ul([class: "nav-links"], fn state ->
            state
            |> render_nav_item("/", "Dashboard", current_path)
            |> render_nav_item("/auth", "Login", current_path)
            |> render_nav_item("/reservations", "Reservations", current_path)
            |> render_nav_item("/customers", "Customers", current_path)
            |> render_nav_item("/chat", "Chat", current_path)
            |> render_nav_item("/todos", "Tasks", current_path)
            |> render_nav_item("/blog", "Blog", current_path)
            |> render_nav_item("/surveys", "Surveys", current_path)
            |> render_nav_item("/admin", "Admin", current_path)
            |> render_dark_mode_toggle()
          end)
        end)
      end)
    end)
  end

  defp render_nav_item(state, path, label, current_path) do
    # For Dashboard ("/"), only mark as active if current_path is exactly "/"
    # For other paths, check if current_path starts with the path
    # Use JavaScript to set active state on client side for more reliable detection
    is_active = case path do
      "/" -> current_path == "/"
      _ -> String.starts_with?(current_path, path)
    end

    class = if is_active, do: "nav-link active", else: "nav-link"
    # Add data-path attribute for JavaScript-based active state detection
    attrs = [class: class, href: path, "data-nav-path": path]
    attrs = if is_active, do: [{:style, "position: relative;"} | attrs], else: attrs

    li(state, [], fn state ->
      a(state, attrs, label)
    end)
  end

  defp render_dark_mode_toggle(state) do
    li(state, [], fn state ->
      button(state, [
        class: "dark-mode-toggle",
        type: "button",
        "data-dark-mode-toggle": true,
        "aria-label": "Toggle dark mode"
      ], "🌙")
    end)
  end
end
