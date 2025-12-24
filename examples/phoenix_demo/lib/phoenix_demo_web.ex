defmodule PhoenixDemoWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, live views and so on.

  This can be used in your application as:

      use PhoenixDemoWeb, :controller
      use PhoenixDemoWeb, :view
      use PhoenixDemoWeb, :router
      use PhoenixDemoWeb, :live_view
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: PhoenixDemoWeb
      import Plug.Conn
      import PhoenixDemoWeb.Gettext
      alias PhoenixDemoWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/phoenix_demo_web/templates",
        namespace: PhoenixDemoWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      import Phoenix.LiveView.Helpers
      import PhoenixDemoWeb.CoreComponents
      import PhoenixDemoWeb.Gettext

      alias PhoenixDemoWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
