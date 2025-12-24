defmodule PhoenixDemoWeb.Components.Card do
  use Phlex.HTML

  @component_styles """
  .card {
    padding: 1.5rem;
    border: none;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(20px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0, 0, 0, 0.05);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12), 0 2px 6px rgba(0, 0, 0, 0.08);
  }

  .card-header {
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  }

  .card-title {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: #1d1d1f;
    letter-spacing: -0.01em;
  }

  .card-body {
    margin-bottom: 1rem;
  }

  .card-content {
    margin: 0;
    color: #86868b;
    line-height: 1.47059;
    font-size: 0.9375rem;
  }

  .card-footer {
    padding-top: 0.75rem;
    border-top: 1px solid rgba(0, 0, 0, 0.06);
    display: flex;
    justify-content: flex-end;
  }

  .btn {
    padding: 0.625rem 1.25rem;
    background: #0071e3;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.2s ease;
    text-decoration: none;
    display: inline-block;
    letter-spacing: -0.01em;
  }

  .btn:hover {
    background: #0077ed;
    transform: scale(1.02);
  }

  .btn:active {
    background: #0066cc;
    transform: scale(0.98);
  }
  """

  def view_template(assigns, state) do
    # Access original assigns from _assigns field
    original_assigns = Map.get(assigns, :_assigns, %{})
    title = Map.get(original_assigns, :title, "Default Title")
    content = Map.get(original_assigns, :content, "")
    id = Map.get(original_assigns, :id, 1)

    # Register styles for head rendering
    capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    # Add capsule attribute using helper
    attrs = Phlex.StyleCapsule.add_capsule_attr([class: "card", id: "card-#{id}"], __MODULE__)

    # Render component with capsule attribute
    div(state, attrs, fn state ->
      state
      |> header([class: "card-header"], fn state ->
        h2(state, [class: "card-title"], title)
      end)
      |> main([class: "card-body"], fn state ->
        p(state, [class: "card-content"], content)
      end)
      |> footer([class: "card-footer"], fn state ->
        button(state, [class: "btn", type: "button"], "Action")
      end)
    end)
  end

  def styles do
    @component_styles
  end
end
