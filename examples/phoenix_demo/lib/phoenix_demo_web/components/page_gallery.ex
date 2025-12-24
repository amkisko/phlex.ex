defmodule PhoenixDemoWeb.Components.PageGallery do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .page-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 3rem 2rem;
  }

  .page-header {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(20px);
    padding: 3rem 2.5rem;
    border-radius: 18px;
    margin-bottom: 3rem;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0, 0, 0, 0.05);
    text-align: center;
  }

  .page-header h1 {
    margin: 0 0 0.75rem 0;
    font-size: 3.5rem;
    font-weight: 700;
    color: #1d1d1f;
    letter-spacing: -0.03em;
    line-height: 1.07143;
  }

  .page-header p {
    margin: 0;
    color: #86868b;
    font-size: 1.1875rem;
    font-weight: 400;
    letter-spacing: -0.01em;
  }

  .page-header-badges {
    margin-top: 1rem;
    display: flex;
    gap: 0.5rem;
    justify-content: center;
  }

  .page-header-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .badge-stylecapsule {
    background: #dbeafe;
    color: #1e40af;
  }

  .badge-tailwind {
    background: #f3e8ff;
    color: #6b21a8;
  }

  .badge-phlex {
    background: #dcfce7;
    color: #166534;
  }

  .section {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(20px);
    padding: 2.5rem;
    border-radius: 18px;
    margin-bottom: 2rem;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0, 0, 0, 0.05);
  }

  .section h2 {
    margin: 0 0 2rem 0;
    font-size: 2.5rem;
    font-weight: 700;
    color: #1d1d1f;
    letter-spacing: -0.02em;
    line-height: 1.07143;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
    padding-bottom: 1rem;
  }

  .component-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
    margin-top: 1.5rem;
  }

  .demo-item {
    padding: 1.5rem;
    border: none;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(10px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .demo-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .demo-item h4 {
    margin: 0 0 1rem 0;
    font-size: 0.8125rem;
    font-weight: 600;
    color: #86868b;
    text-transform: uppercase;
    letter-spacing: 0.08em;
  }

  .code-block {
    background: rgba(0, 0, 0, 0.04);
    border: none;
    border-radius: 12px;
    padding: 1.5rem;
    margin: 1.5rem 0;
    font-family: "SF Mono", "Monaco", "Menlo", "Ubuntu Mono", monospace;
    font-size: 0.875rem;
    overflow-x: auto;
    color: #1d1d1f;
    line-height: 1.47059;
  }

  .code-block pre {
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
  }

  .form-demo {
    max-width: 500px;
  }
  """

  def render_template(_assigns, attrs, state) do
    final_attrs = Keyword.put(attrs, :class, "page-container")

    div(state, final_attrs, fn state ->
      state
      |> render_header()
      |> render_text_elements()
      |> render_lists()
      |> render_forms()
      |> render_tables()
      |> render_semantic_elements()
      |> render_interactive_elements()
      |> render_custom_components()
      |> render_component_reference()
    end)
  end

  defp render_header(state) do
    div(state, [class: "page-header"], fn state ->
      state
      |> h1([], "Phlex Component Gallery")
      |> p([], "Comprehensive showcase of all available Phlex HTML components with StyleCapsule scoped CSS and Tailwind CSS")
      |> div([class: "page-header-badges"], fn state ->
        state
        |> span([class: "page-header-badge badge-stylecapsule"], "StyleCapsule")
        |> span([class: "page-header-badge badge-tailwind"], "Tailwind CSS")
        |> span([class: "page-header-badge badge-phlex"], "Phlex")
      end)
    end)
  end

  defp render_text_elements(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Text Elements")
      |> div([class: "component-grid"], fn state ->
        state
        |> render_demo_item("Headings", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.HeadingDemo.render())
        end)
        |> render_demo_item("Text Formatting", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.TextFormattingDemo.render())
        end)
        |> render_demo_item("Code & Pre", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.CodeDemo.render())
        end)
      end)
    end)
  end

  defp render_lists(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Lists")
      |> div([class: "component-grid"], fn state ->
        state
        |> render_demo_item("Unordered List", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.ListDemo.render())
        end)
        |> render_demo_item("Ordered List", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.OrderedListDemo.render())
        end)
        |> render_demo_item("Definition List", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.DefinitionListDemo.render())
        end)
      end)
    end)
  end

  defp render_forms(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Form Elements")
      |> div([class: "form-demo"], fn state ->
        Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.FormDemo.render())
      end)
    end)
  end

  defp render_tables(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Tables")
      |> then(fn state ->
        Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.TableDemo.render())
      end)
    end)
  end

  defp render_semantic_elements(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Semantic Elements")
      |> div([class: "component-grid"], fn state ->
        state
        |> render_demo_item("Article", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.ArticleDemo.render())
        end)
        |> render_demo_item("Section", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.SectionDemo.render())
        end)
        |> render_demo_item("Aside", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.AsideDemo.render())
        end)
      end)
    end)
  end

  defp render_interactive_elements(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Interactive Elements")
      |> div([class: "component-grid"], fn state ->
        state
        |> render_demo_item("Buttons", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.ButtonDemo.render())
        end)
        |> render_demo_item("Links", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.LinkDemo.render())
        end)
        |> render_demo_item("Details/Summary", fn state ->
          Phlex.SGML.append_raw(state, PhoenixDemoWeb.Components.DetailsDemo.render())
        end)
      end)
    end)
  end

  defp render_custom_components(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Custom Components")
      |> div([class: "component-grid"], fn state ->
        Enum.reduce(1..3, state, fn i, acc_state ->
          card_html = PhoenixDemoWeb.Components.Card.render(%{
            id: i,
            title: "Card #{i}",
            content: "This is card component #{i} demonstrating Phlex with StyleCapsule"
          })
          Phlex.SGML.append_raw(acc_state, card_html)
        end)
      end)
    end)
  end

  defp render_component_reference(state) do
    div(state, [class: "section"], fn state ->
      state
      |> h2([], "Component Reference")
      |> p([], "All available Phlex HTML elements:")
      |> div([class: "code-block"], fn state ->
        pre(state, [], component_reference_text())
      end)
    end)
  end

  defp render_demo_item(state, title, content_fn) do
    div(state, [class: "demo-item"], fn state ->
      state
      |> h4([], title)
      |> content_fn.()
    end)
  end

  defp component_reference_text do
    """
    Text: h1, h2, h3, h4, h5, h6, p, span, strong, em, code, pre, blockquote, cite, q, abbr, dfn, mark, small, sub, sup, time, var, kbd, samp
    Lists: ul, ol, li, dl, dt, dd
    Forms: form, button, label, textarea, select, option, optgroup, fieldset, legend, datalist, output, progress, meter
    Tables: table, caption, colgroup, thead, tbody, tfoot, tr, td, th
    Sections: header, footer, main, article, section, aside, address
    Interactive: details, summary, dialog, menu, menuitem
    Semantic: figure, figcaption, data, ruby, rt, rp, bdi, bdo, wbr, ins, del, s, u, i, b
    Void: br, hr, img, input, link, meta, area, base, col, embed, source, track
    Other: a, nav, iframe, object, param, video, audio, canvas, picture, html, head, body, title, style, script, noscript, template, slot, search
    """
  end
end
