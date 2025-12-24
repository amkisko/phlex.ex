defmodule Phlex.HTML do
  @compile {:no_unused_attributes, false}

  alias Phlex.SGML.{Attributes, State}

  @moduledoc """
  HTML component base for Phlex.

  Use this module to create HTML components:

      defmodule MyComponent do
        use Phlex.HTML

        def view_template(assigns, state) do
          div(state, [class: "container"], fn state ->
            h1(state, [class: "title"], "Hello, World!")
          end)
        end
      end

  ## Standard HTML Elements

  All standard HTML elements are available as functions that accept state explicitly.
  This follows Elixir's functional programming style and ensures clear data flow.

  ## Examples

      def view_template(assigns, state) do
        div(state, [class: "card"], fn state ->
          h1(state, [class: "title"], "Hello")
        end)
      end

  """

  @standard_elements_for_macros [
    # Text content
    :div,
    :span,
    :p,
    :h1,
    :h2,
    :h3,
    :h4,
    :h5,
    :h6,
    :strong,
    :em,
    :code,
    :pre,
    :blockquote,
    :cite,
    :q,
    :abbr,
    :dfn,
    :mark,
    :small,
    :sub,
    :sup,
    :time,
    :var,
    :kbd,
    :samp,
    # Links and navigation
    :a,
    :nav,
    # Lists
    :ul,
    :ol,
    :li,
    :dl,
    :dt,
    :dd,
    # Forms
    :form,
    :button,
    :label,
    :textarea,
    :select,
    :option,
    :optgroup,
    :fieldset,
    :legend,
    :datalist,
    :output,
    :progress,
    :meter,
    # Tables
    :table,
    :caption,
    :colgroup,
    :thead,
    :tbody,
    :tfoot,
    :tr,
    :td,
    :th,
    :map,
    # Sections
    :header,
    :footer,
    :main,
    :article,
    :section,
    :aside,
    :address,
    # Embedded content (non-void)
    :iframe,
    :object,
    :param,
    :video,
    :audio,
    :canvas,
    :picture,
    # Document structure
    :html,
    :head,
    :body,
    :title,
    :style,
    :script,
    :noscript,
    # Interactive elements
    :details,
    :summary,
    :dialog,
    :menu,
    :menuitem,
    # Semantic elements
    :figure,
    :figcaption,
    :data,
    :ruby,
    :rt,
    :rp,
    :bdi,
    :bdo,
    :wbr,
    :ins,
    :del,
    :s,
    :u,
    :i,
    :b,
    # Other
    :template,
    :slot,
    :search
  ]

  # Reserved for future macro implementation
  # These attributes are intentionally unused - reserved for future macro features
  @void_elements_for_macros [:br, :hr, :img, :input, :link, :meta, :area, :base, :col, :embed, :source, :track]

  defmacro __using__(_opts) do
    _ = @standard_elements_for_macros
    _ = @void_elements_for_macros

    quote do
      use Phlex.SGML

      import Phlex.HTML
      import Phlex.Helpers

      @doc """
      Outputs an HTML doctype.
      """
      def doctype(state) do
        if State.should_render?(state) do
          State.append_buffer(state, "<!doctype html>")
        else
          state
        end
      end

      defoverridable doctype: 1
    end
  end

  @doc """
  Renders a standard HTML element.
  """
  def render_element(tag_name, attrs, state, content \\ nil) do
    if State.should_render?(state) do
      state
      |> open_tag(tag_name, attrs)
      |> render_content(content)
      |> close_tag(tag_name)
    else
      # When fragments are specified, execute content
      # so fragments can process and increment depth
      if content do
        render_content(state, content)
      else
        state
      end
    end
  end

  @doc """
  Renders a void HTML element (self-closing).
  """
  def render_void_element(tag_name, attrs, state) do
    if State.should_render?(state) do
      open_void_tag(state, tag_name, attrs)
    else
      state
    end
  end

  defp open_tag(state, tag_name, attrs) do
    tag_str = normalize_tag_name(tag_name)
    attrs_str = Attributes.generate_attributes(attrs)

    State.append_buffer(state, ["<", tag_str, attrs_str, ">"])
  end

  defp close_tag(state, tag_name) do
    tag_str = normalize_tag_name(tag_name)
    State.append_buffer(state, ["</", tag_str, ">"])
  end

  defp open_void_tag(state, tag_name, attrs) do
    tag_str = normalize_tag_name(tag_name)
    attrs_str = Attributes.generate_attributes(attrs)

    State.append_buffer(state, ["<", tag_str, attrs_str, ">"])
  end

  defp render_content(state, nil), do: state
  defp render_content(state, fun) when is_function(fun, 1), do: fun.(state)

  defp render_content(state, %Phlex.SGML.SafeValue{} = safe_content) do
    Phlex.SGML.append_raw(state, safe_content)
  end

  defp render_content(state, content) when is_binary(content) or is_atom(content) or is_number(content) do
    Phlex.SGML.append_text(state, content)
  end

  defp render_content(state, content) when is_list(content) do
    Enum.reduce(content, state, &render_content(&2, &1))
  end

  defp normalize_tag_name(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> String.replace("_", "-")
  end

  defp normalize_tag_name(name) when is_binary(name), do: name

  # Void elements (self-closing) - must be defined first
  @void_elements [:br, :hr, :img, :input, :link, :meta, :area, :base, :col, :embed, :source, :track]

  # Generate helper functions for common HTML elements
  # Standard elements (with closing tags) - exclude void elements
  @standard_elements [
    # Text content
    :div,
    :span,
    :p,
    :h1,
    :h2,
    :h3,
    :h4,
    :h5,
    :h6,
    :strong,
    :em,
    :code,
    :pre,
    :blockquote,
    :cite,
    :q,
    :abbr,
    :dfn,
    :mark,
    :small,
    :sub,
    :sup,
    :time,
    :var,
    :kbd,
    :samp,
    # Links and navigation
    :a,
    :nav,
    # Lists
    :ul,
    :ol,
    :li,
    :dl,
    :dt,
    :dd,
    # Forms
    :form,
    :button,
    :label,
    :textarea,
    :select,
    :option,
    :optgroup,
    :fieldset,
    :legend,
    :datalist,
    :output,
    :progress,
    :meter,
    # Tables
    :table,
    :caption,
    :colgroup,
    :thead,
    :tbody,
    :tfoot,
    :tr,
    :td,
    :th,
    :map,
    # Sections
    :header,
    :footer,
    :main,
    :article,
    :section,
    :aside,
    :address,
    # Embedded content (non-void)
    :iframe,
    :object,
    :param,
    :video,
    :audio,
    :canvas,
    :picture,
    # Document structure
    :html,
    :head,
    :body,
    :title,
    :style,
    :script,
    :noscript,
    # Interactive elements
    :details,
    :summary,
    :dialog,
    :menu,
    :menuitem,
    # Semantic elements
    :figure,
    :figcaption,
    :data,
    :ruby,
    :rt,
    :rp,
    :bdi,
    :bdo,
    :wbr,
    :ins,
    :del,
    :s,
    :u,
    :i,
    :b,
    # Other
    :template,
    :slot,
    :search
  ]

  # Generate functions for standard elements
  for element <- @standard_elements do
    # Function content with attributes: div(state, [class: "card"], fn state -> ... end)
    def unquote(element)(state, attrs, content) when is_function(content, 1) do
      render_element(unquote(element), attrs, state, content)
    end

    # Direct text content: h2(state, [class: "title"], "Hello")
    # Also handle SafeValue for safe content
    def unquote(element)(state, attrs, %Phlex.SGML.SafeValue{} = content) do
      render_element(unquote(element), attrs, state, content)
    end

    def unquote(element)(state, attrs, content)
        when is_binary(content) or is_atom(content) or is_number(content) do
      render_element(unquote(element), attrs, state, content)
    end

    # Function content without attributes: div(state, fn state -> ... end)
    def unquote(element)(state, content) when is_function(content, 1) do
      render_element(unquote(element), [], state, content)
    end

    # No content, just attributes: div(state, [class: "card"])
    def unquote(element)(state, attrs) when is_list(attrs) or is_map(attrs) do
      render_element(unquote(element), attrs, state, nil)
    end

    # No attributes, no content: div(state)
    def unquote(element)(state) do
      render_element(unquote(element), [], state, nil)
    end
  end

  # Generate functions for void elements
  for element <- @void_elements do
    def unquote(element)(state, attrs) do
      render_void_element(unquote(element), attrs, state)
    end

    def unquote(element)(state) do
      render_void_element(unquote(element), [], state)
    end
  end

  @doc """
  Renders a dynamic HTML tag.

  ## Examples

      tag(:section, [class: "main"], state, fn state ->
        p(state, [], fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end)
  """
  def tag(tag_name, attrs, state, content_fun \\ nil) do
    if content_fun do
      render_element(tag_name, attrs, state, content_fun)
    else
      render_void_element(tag_name, attrs, state)
    end
  end
end
