defmodule PhoenixDemoWeb.Components.Flash do
  use Phlex.HTML

  @component_styles """
  .flash-group {
    position: fixed;
    top: 1rem;
    right: 1rem;
    z-index: 1000;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .flash {
    padding: 1rem 1.5rem;
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    min-width: 300px;
  }

  .flash:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
  }

  .flash-info {
    background: #0071e3;
    color: white;
  }

  .flash-error {
    background: #ff3b30;
    color: white;
  }

  .flash strong {
    font-weight: 600;
    margin-right: 0.5rem;
  }

  .flash span {
    flex: 1;
  }
  """

  def render_group(assigns) do
    flash = Map.get(assigns, :flash, %{})

    # Register styles manually
    capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(
      @component_styles,
      capsule_id,
      namespace: :user,
      strategy: PhoenixDemoWeb.StyleCapsuleConfig.strategy()
    )

    # Use Phlex rendering with assigns
    __MODULE__.render(%{flash: flash, mode: :group, capsule_id: capsule_id})
  end

  def render(assigns) do
    flash = Map.get(assigns, :flash, %{})
    kind = Map.get(assigns, :kind, :info)
    title = Map.get(assigns, :title, "")

    # Register styles manually
    capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(
      @component_styles,
      capsule_id,
      namespace: :user,
      strategy: PhoenixDemoWeb.StyleCapsuleConfig.strategy()
    )

    # Use Phlex rendering with assigns
    __MODULE__.render(%{flash: flash, kind: kind, title: title, capsule_id: capsule_id})
  end

  def view_template(assigns, state) do
    flash = Map.get(assigns, :flash, %{})
    mode = Map.get(assigns, :mode, :single)
    capsule_id = Map.get(assigns, :capsule_id)

    case mode do
      :group ->
        Phlex.HTML.div(state, [id: "flash-group", class: "flash-group", data_capsule: capsule_id], fn state ->
          state
          |> render_flash(flash, :info, "Success!")
          |> render_flash(flash, :error, "Error!")
        end)
      :single ->
        kind = Map.get(assigns, :kind, :info)
        title = Map.get(assigns, :title, "")
        render_flash(state, flash, kind, title)
    end
  end

  defp render_flash(state, flash, kind, title) do
    case Phoenix.Flash.get(flash, kind) do
      nil ->
        state
      msg ->
        flash_id = "flash-#{kind}"
        flash_class = "flash flash-#{kind}"

        Phlex.HTML.div(state, [
          id: flash_id,
          class: flash_class,
          phx_click: Phoenix.LiveView.JS.push("lv:clear-flash", value: %{key: kind}) |> Phoenix.LiveView.JS.hide(transition: "fade-out"),
          role: "alert"
        ], fn state ->
          state
          |> Phlex.HTML.strong([], title)
          |> Phlex.HTML.span([], msg)
        end)
    end
  end
end
