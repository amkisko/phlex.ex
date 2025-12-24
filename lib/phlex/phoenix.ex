defmodule Phlex.Phoenix do
  @moduledoc """
  Phoenix and Phoenix LiveView integration for Phlex components.

  This module provides helpers for using Phlex components with Phoenix LiveView.

  ## LiveView Integration

  When rendering Phlex components from LiveView's `render/1` function, you need
  to convert the HTML string to a `Phoenix.LiveView.Rendered` struct:

      defmodule MyAppWeb.MyLive do
        use Phoenix.LiveView

        def render(assigns) do
          Phlex.Phoenix.to_rendered(
            MyAppWeb.Components.Card.render(%{title: "Hello"})
          )
        end
      end

  ## Direct Usage

  You can also use Phlex components directly in HEEx templates:

      <%= raw MyAppWeb.Components.Card.render(%{title: "Hello"}) %>

  However, using `to_rendered/1` in LiveView is recommended for better
  performance and proper LiveView rendering lifecycle integration.
  """

  @doc """
  Converts a Phlex component's HTML output to a `Phoenix.LiveView.Rendered` struct.

  This allows Phlex components to be used directly in LiveView's `render/1` function
  without needing to wrap them in HEEx templates.

  ## Examples

      def render(assigns) do
        Phlex.Phoenix.to_rendered(
          MyComponent.render(assigns)
        )
      end

  ## Options

  - `:fingerprint` - Optional fingerprint for LiveView diffing (default: `0`)
  - `:root` - Whether this is a root element (default: `false`)

  """
  def to_rendered(phlex_html, opts \\ []) when is_binary(phlex_html) do
    fingerprint = Keyword.get(opts, :fingerprint, 0)
    root = Keyword.get(opts, :root, false)

    %Phoenix.LiveView.Rendered{
      static: ["", ""],
      dynamic: fn _ ->
        # Return as iodata list - LiveView's renderer handles this correctly
        # The HTML string from Phlex is already safe HTML
        [phlex_html]
      end,
      root: root,
      fingerprint: fingerprint
    }
  end
end
