defmodule PhoenixDemoWeb.StyleCapsuleConfig do
  @moduledoc """
  Centralized configuration for StyleCapsule usage across the application.

  Components are organized into three namespaces:
  - `:navigation` - Navigation component
  - `:admin` - Admin components (Admin, AdminChat, AdminReservations, AdminBlog)
  - `:user` - User-facing components (Dashboard, Todos, Blog, Surveys, etc.)
  """

  @strategy :nesting  # Use faster CSS nesting strategy (3.4x faster than :patch)

  def strategy, do: @strategy

  def cache_strategy do
    case Mix.env() do
      :prod -> :file
      :dev -> :none
      :test -> :none
    end
  end

  @doc """
  Returns the default namespace for user-facing components.
  """
  def default_namespace, do: :user
end
