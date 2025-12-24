defmodule PhoenixDemoWeb.Components.PhlexRenderer do
  @moduledoc """
  Deprecated: Use `Phlex.Phoenix.to_rendered/2` instead.

  This module is kept for backward compatibility but delegates to `Phlex.Phoenix.to_rendered/2`.
  """

  defdelegate to_rendered(phlex_html, opts \\ []), to: Phlex.Phoenix
end
