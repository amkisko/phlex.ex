defmodule PhoenixDemoWeb.CoreComponents do
  @moduledoc """
  Core Phoenix components - now using Phlex
  """
  use Phoenix.Component

  def flash_group(assigns) do
    # Delegate to Phlex component and convert to HEEx-safe output
    flash_html = PhoenixDemoWeb.Components.Flash.render_group(assigns)
    assigns = assign(assigns, :flash_html, flash_html)
    ~H"""
    <%= Phoenix.HTML.raw(@flash_html) %>
    """
  end

  def flash(assigns) do
    # Delegate to Phlex component and convert to HEEx-safe output
    flash_html = PhoenixDemoWeb.Components.Flash.render(assigns)
    assigns = assign(assigns, :flash_html, flash_html)
    ~H"""
    <%= Phoenix.HTML.raw(@flash_html) %>
    """
  end
end
