defmodule PhoenixDemoWeb.Components.Base do
  @moduledoc """
  Base module for Phlex components with automatic StyleCapsule integration.

  This is a thin wrapper around `StyleCapsule.Component` that applies
  application-specific defaults from `PhoenixDemoWeb.StyleCapsuleConfig`.

  ## Usage

      defmodule MyAppWeb.Components.Card do
        use PhoenixDemoWeb.Components.Base

        @component_styles \"\"\"
        .card { padding: 1rem; }
        \"\"\"

        defp render_template(assigns, attrs, state) do
          div(state, attrs, fn state ->
            # Component content
          end)
        end
      end

  Override defaults if needed: use PhoenixDemoWeb.Components.Base, strategy: :patch
  """

  defmacro __using__(opts \\ []) do
    # Apply application-specific defaults
    # Default to :user namespace for user-facing components
    namespace = Keyword.get(opts, :namespace) || :user
    strategy = Keyword.get(opts, :strategy) || PhoenixDemoWeb.StyleCapsuleConfig.strategy()
    cache_strategy = Keyword.get(opts, :cache_strategy) || PhoenixDemoWeb.StyleCapsuleConfig.cache_strategy()

    quote do
      use StyleCapsule.PhlexComponent,
        namespace: unquote(namespace),
        strategy: unquote(strategy),
        cache_strategy: unquote(cache_strategy)
    end
  end
end
