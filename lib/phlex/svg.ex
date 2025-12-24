defmodule Phlex.SVG do
  alias Phlex.SGML.{Attributes, State}

  @moduledoc """
  SVG component base for Phlex.

  Use this module to create SVG components:

      defmodule MyIcon do
        use Phlex.SVG

        def view_template(_assigns, state) do
          state
          |> svg([viewBox: "0 0 24 24"], fn state ->
            state
            |> circle([cx: "12", cy: "12", r: "10"])
          end)
        end
      end

  SVG components can be used within HTML components:

      defmodule MyPage do
        use Phlex.HTML

        def view_template(_assigns, state) do
          state
          |> div([], fn state ->
            render_component(state, MyIcon)
          end)
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      use Phlex.SGML

      import Phlex.SVG
      import Phlex.Helpers

      defoverridable []
    end
  end

  @doc """
  Renders a standard SVG element.
  """
  def render_element(tag_name, attrs, state, content_fun \\ nil) do
    if State.should_render?(state) do
      state
      |> open_tag(tag_name, attrs)
      |> render_content(content_fun)
      |> close_tag(tag_name)
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

  defp render_content(state, nil), do: state
  defp render_content(state, fun) when is_function(fun, 1), do: fun.(state)

  defp render_content(state, content) when is_binary(content) or is_atom(content) or is_number(content) do
    Phlex.SGML.append_text(state, content)
  end

  defp normalize_tag_name(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> String.replace("_", "-")
  end

  defp normalize_tag_name(name) when is_binary(name), do: name

  # Common SVG elements
  @svg_elements [
    :svg,
    :circle,
    :rect,
    :ellipse,
    :line,
    :polyline,
    :polygon,
    :path,
    :text,
    :tspan,
    :g,
    :defs,
    :use,
    :symbol,
    :marker,
    :pattern,
    :clipPath,
    :mask,
    :linearGradient,
    :radialGradient,
    :stop,
    :filter,
    :feGaussianBlur,
    :feColorMatrix,
    :feBlend,
    :feComposite,
    :feOffset,
    :feMerge,
    :feMergeNode,
    :animate,
    :animateTransform,
    :animateMotion,
    :set,
    :a,
    :title,
    :desc,
    :metadata,
    :style,
    :script
  ]

  # Generate functions for SVG elements
  for element <- @svg_elements do
    # Function content with attributes: svg(state, [class: "icon"], fn state -> ... end)
    def unquote(element)(state, attrs, content_fun) when is_function(content_fun, 1) do
      render_element(unquote(element), attrs, state, content_fun)
    end

    # Direct text content with attributes: text(state, [x: 10], "Hello")
    def unquote(element)(state, attrs, content)
        when is_binary(content) or is_atom(content) or is_number(content) do
      render_element(unquote(element), attrs, state, content)
    end

    # Function content without attributes: svg(state, fn state -> ... end)
    def unquote(element)(state, content_fun) when is_function(content_fun, 1) do
      render_element(unquote(element), [], state, content_fun)
    end

    # No content, just attributes: svg(state, [viewBox: "0 0 100 100"])
    def unquote(element)(state, attrs) when is_list(attrs) or is_map(attrs) do
      render_element(unquote(element), attrs, state, nil)
    end

    # No attributes, no content: svg(state)
    def unquote(element)(state) do
      render_element(unquote(element), [], state, nil)
    end
  end

  @doc """
  Renders a dynamic SVG tag.

  ## Examples

      tag(:path, [d: "M 10 10 L 20 20"], state)
  """
  def tag(tag_name, attrs, state, content_fun \\ nil) do
    if content_fun do
      render_element(tag_name, attrs, state, content_fun)
    else
      render_element(tag_name, attrs, state, nil)
    end
  end

  @doc """
  Outputs CDATA section.

  ## Examples

      cdata(state, "<script>alert('test')</script>")
  """
  def cdata(%Phlex.SGML.State{} = state, content) when is_binary(content) do
    if State.should_render?(state) do
      escaped = String.replace(content, "]]>", "]]>]]<![CDATA[")
      State.append_buffer(state, ["<![CDATA[", escaped, "]]>"])
    else
      state
    end
  end

  def cdata(%Phlex.SGML.State{} = state, fun) when is_function(fun, 1) do
    if State.should_render?(state) do
      captured = State.capture(state, fun)
      escaped = String.replace(captured, "]]>", "]]>]]<![CDATA[")
      State.append_buffer(state, ["<![CDATA[", escaped, "]]>"])
    else
      state
    end
  end
end
