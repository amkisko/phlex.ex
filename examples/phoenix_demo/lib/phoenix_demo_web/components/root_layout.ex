defmodule PhoenixDemoWeb.Components.RootLayout do
  @moduledoc """
  Root layout component for the application.
  Replaces root.html.heex with a Phlex component.
  """
  use PhoenixDemoWeb.Components.Base, namespace: :user

  @component_styles """
  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  html {
    -webkit-text-size-adjust: 100%;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif;
    line-height: 1.5;
    color: #1d1d1f;
    background: #fbfbfd;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    transition: background-color 0.2s ease, color 0.2s ease;
    /* Add minimum padding to prevent content from touching edges on mobile */
    padding: 0;
    margin: 0;
  }

  /* Main content wrapper with Apple-style spacing */
  main {
    min-height: calc(100vh - 44px);
    padding: 0;
    margin: 0;
  }

  /* Content container with generous padding following Apple guidelines */
  .content-wrapper {
    max-width: 1200px;
    margin: 0 auto;
    padding: 3rem 2rem;
    width: 100%;
  }

  /* Responsive padding adjustments */
  @media (max-width: 768px) {
    .content-wrapper {
      padding: 2rem 1.5rem;
    }
  }

  @media (max-width: 480px) {
    .content-wrapper {
      padding: 1.5rem 1rem;
    }
  }

  /* Section spacing - Apple recommends 48-64px between major sections */
  section {
    margin-bottom: 3rem;
  }

  section:last-child {
    margin-bottom: 0;
  }

  /* Dark mode body styles */
  :root.dark body,
  html.dark body {
    color: #f5f5f7;
    background: #1d1d1f;
  }

  @media (prefers-color-scheme: dark) {
    :root:not(.light) body {
      color: #f5f5f7;
      background: #1d1d1f;
    }
  }
  """

  def render(assigns) do
    current_path = Map.get(assigns, :current_path) ||
                   (Map.get(assigns, :uri) && Map.get(assigns.uri, :path)) || "/"
    page_title = Map.get(assigns, :page_title, "Component Gallery")
    inner_content = Map.get(assigns, :inner_content, "")
    csrf_token = Map.get(assigns, :csrf_token, "")

    super(%{
      current_path: current_path,
      page_title: page_title,
      inner_content: inner_content,
      csrf_token: csrf_token
    })
  end

  def render_template(assigns, attrs, state) do
    current_path = Map.get(assigns, :current_path, "/")
    page_title = Map.get(assigns, :page_title, "Component Gallery")
    inner_content = normalize_content(Map.get(assigns, :inner_content, ""))
    csrf_token = Map.get(assigns, :csrf_token, "")
    html_attrs = Keyword.put(attrs, :lang, "en")

    state
    |> doctype()
    |> html(html_attrs, fn state ->
      state
      |> head([], fn state ->
        state
        |> meta([charset: "utf-8"])
        |> meta([name: "viewport", content: "width=device-width, initial-scale=1"])
        |> meta([name: "csrf-token", content: csrf_token])
        |> title([], "#{page_title} · Phlex")
        |> link([phx_track_static: true, rel: "stylesheet", href: "/assets/css/app.css"])
        |> unsafe_raw(StyleCapsule.Phoenix.render_precompiled_stylesheets())
      end)
      |> body([], fn state ->
        # Navigation component registers its styles when rendered
        state
        |> unsafe_raw(PhoenixDemoWeb.Components.Navigation.render(%{current_path: current_path}))
        |> main([], fn state ->
          state
          |> div([class: "content-wrapper"], fn state ->
            unsafe_raw(state, inner_content)
          end)
        end)
        # Render runtime styles AFTER inner_content has been rendered
        # This ensures all components have registered their styles
        |> unsafe_raw(StyleCapsule.Phoenix.render_all_runtime_styles())
        |> append_scripts()
      end)
    end)
  end

  defp normalize_content({:safe, iodata}), do: IO.iodata_to_binary(iodata)
  defp normalize_content(iodata) when is_list(iodata), do: IO.iodata_to_binary(iodata)
  defp normalize_content(binary) when is_binary(binary), do: binary
  defp normalize_content(%Phoenix.LiveView.Rendered{} = rendered) do
    static = rendered.static || []
    dynamic_result = rendered.dynamic.(false)
    IO.iodata_to_binary([static, dynamic_result])
  end
  defp normalize_content(other) do
    try do
      IO.iodata_to_binary(other)
    rescue
      _ -> to_string(other)
    end
  end


  defp append_scripts(state) do
    script_content = """
    <script>
      (function() {
        // Initialize dark mode on page load
        function initDarkMode() {
          var theme = localStorage.getItem('theme');
          var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
          var html = document.documentElement;

          if (theme === 'dark' || (!theme && prefersDark)) {
            html.classList.add('dark');
          } else {
            html.classList.remove('dark');
          }

          // Update toggle icon
          var toggle = document.querySelector('[data-dark-mode-toggle]');
          if (toggle) {
            if (html.classList.contains('dark')) {
              toggle.textContent = '☀️';
            } else {
              toggle.textContent = '🌙';
            }
          }
        }

        // Run immediately and also on DOM ready
        initDarkMode();

        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', initDarkMode);
        }

        // Set up dark mode toggle
        function setupDarkModeToggle() {
          var toggle = document.querySelector('[data-dark-mode-toggle]');
          if (toggle) {
            // Remove any existing listeners by cloning the button
            var newToggle = toggle.cloneNode(true);
            toggle.parentNode.replaceChild(newToggle, toggle);

            newToggle.addEventListener('click', function(e) {
              e.preventDefault();
              e.stopPropagation();
              var html = document.documentElement;
              var isDark = html.classList.contains('dark');

              if (isDark) {
                html.classList.remove('dark');
                localStorage.setItem('theme', 'light');
                newToggle.textContent = '🌙';
              } else {
                html.classList.add('dark');
                localStorage.setItem('theme', 'dark');
                newToggle.textContent = '☀️';
              }
            });
          }
        }

        // Set up toggle when DOM is ready
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', setupDarkModeToggle);
        } else {
          setupDarkModeToggle();
        }

        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
          if (!localStorage.getItem('theme')) {
            if (e.matches) {
              document.documentElement.classList.add('dark');
            } else {
              document.documentElement.classList.remove('dark');
            }
          }
        });

        // Set up navigation active state
        function setupNavigation() {
          var currentPath = window.location.pathname;
          var navLinks = document.querySelectorAll('[data-nav-path]');
          navLinks.forEach(function(link) {
            var linkPath = link.getAttribute('data-nav-path');
            link.classList.remove('active');
            link.style.position = '';
            if (linkPath === '/' && currentPath === '/') {
              link.classList.add('active');
              link.style.position = 'relative';
            } else if (linkPath !== '/' && currentPath.startsWith(linkPath)) {
              link.classList.add('active');
              link.style.position = 'relative';
            }
          });
        }

        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', setupNavigation);
        } else {
          setupNavigation();
        }
      })();
    </script>
    """
    Phlex.SGML.append_raw(state, script_content)
  end
end
