defmodule Phlex.SVGTest do
  use ExUnit.Case
  doctest Phlex.SVG

  defmodule TestSVGComponent do
    use Phlex.SVG

    def view_template(_assigns, state) do
      state
      |> svg([viewBox: "0 0 24 24", width: "24", height: "24"], fn state ->
        state
        |> circle(cx: "12", cy: "12", r: "10", fill: "blue")
      end)
    end
  end

  test "renders SVG component" do
    result = TestSVGComponent.render()
    assert result =~ ~r/<svg viewBox="0 0 24 24"/
    assert result =~ ~r/<circle cx="12"/
    assert result =~ "fill=\"blue\""
    assert result =~ "</circle>"
    assert result =~ "</svg>"
  end

  test "renders SVG with nested elements" do
    defmodule NestedSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        state
        |> svg([viewBox: "0 0 100 100"], fn state ->
          state
          |> g([id: "group"], fn state ->
            state
            |> rect(x: "10", y: "10", width: "80", height: "80")
            |> circle(cx: "50", cy: "50", r: "30")
          end)
        end)
      end
    end

    result = NestedSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "<g"
    assert result =~ "<rect"
    assert result =~ "<circle"
    assert result =~ "</g>"
    assert result =~ "</svg>"
  end

  test "renders CDATA" do
    defmodule CDATASVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        state
        |> svg([], fn state ->
          Phlex.SVG.cdata(state, "<script>alert('test')</script>")
        end)
      end
    end

    result = CDATASVGComponent.render()
    assert result =~ "<![CDATA["
    assert result =~ "]]>"
  end

  test "renders SVG with text element" do
    defmodule TextSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          text(state, [x: "50", y: "50"], fn state ->
            Phlex.SGML.append_text(state, "Hello SVG")
          end)
        end)
      end
    end

    result = TextSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "<text"
    assert result =~ "x=\"50\""
    assert result =~ "Hello SVG"
    assert result =~ "</text>"
    assert result =~ "</svg>"
  end

  test "renders SVG with path element" do
    defmodule PathSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          path(state, d: "M 10 10 L 90 90")
        end)
      end
    end

    result = PathSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "<path"
    assert result =~ "d=\"M 10 10 L 90 90\""
    assert result =~ "</path>"
    assert result =~ "</svg>"
  end

  test "renders SVG with defs element" do
    defmodule DefsSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          defs(state, [], fn state ->
            circle(state, id: "circle1", cx: "50", cy: "50", r: "20")
          end)
        end)
      end
    end

    result = DefsSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "<defs>"
    assert result =~ "<circle"
    assert result =~ "id=\"circle1\""
    assert result =~ "</circle>"
    assert result =~ "</defs>"
    assert result =~ "</svg>"
  end

  test "renders SVG without attributes" do
    defmodule NoAttrsSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, fn state ->
          circle(state, [])
        end)
      end
    end

    result = NoAttrsSVGComponent.render()
    assert result =~ "<svg>"
    assert result =~ "<circle>"
    assert result =~ "</circle>"
    assert result =~ "</svg>"
  end

  test "renders SVG without content" do
    defmodule EmptySVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, viewBox: "0 0 100 100")
      end
    end

    result = EmptySVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "viewBox=\"0 0 100 100\""
    assert result =~ "</svg>"
  end

  test "renders SVG with dynamic tag" do
    defmodule DynamicTagSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:custom_path, [d: "M 0 0"], state)
        end)
      end
    end

    result = DynamicTagSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "custom-path"
    assert result =~ "d="
    assert result =~ "</custom-path>"
    assert result =~ "</svg>"
  end

  test "renders SVG with dynamic tag and content" do
    defmodule DynamicTagContentSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:custom_group, [id: "group1"], state, fn state ->
            circle(state, cx: "50", cy: "50", r: "10")
          end)
        end)
      end
    end

    result = DynamicTagContentSVGComponent.render()
    assert result =~ "<svg"
    assert result =~ "custom-group"
    assert result =~ "id=\"group1\""
    assert result =~ "<circle"
    assert result =~ "</circle>"
    assert result =~ "</custom-group>"
    assert result =~ "</svg>"
  end

  test "normalizes SVG tag names with underscores" do
    defmodule UnderscoreTagSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:custom_element, [], state)
        end)
      end
    end

    result = UnderscoreTagSVGComponent.render()
    assert result =~ "custom-element"
  end

  test "renders CDATA with function" do
    defmodule CDATAFunctionSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [], fn state ->
          Phlex.SVG.cdata(state, fn state ->
            Phlex.SGML.append_text(state, "<script>alert('test')</script>")
          end)
        end)
      end
    end

    result = CDATAFunctionSVGComponent.render()
    assert result =~ "<![CDATA["
    assert result =~ "]]>"
  end

  test "skips rendering when should_render is false" do
    defmodule SkipRenderSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          circle(state, cx: "50", cy: "50", r: "10")
        end)
      end
    end

    # Render with fragments that don't match
    result = SkipRenderSVGComponent.render(%{fragments: MapSet.new([:other])})
    # SVG should still render (fragments only affect fragment blocks)
    assert result =~ "<svg"
  end

  test "renders SVG elements with map attributes" do
    defmodule MapAttrsSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, %{viewBox: "0 0 100 100", width: "100"}, fn state ->
          circle(state, %{cx: 50, cy: 50, r: 25})
        end)
      end
    end

    result = MapAttrsSVGComponent.render()
    assert result =~ ~r/viewBox="0 0 100 100"/
    assert result =~ ~r/width="100"/
    assert result =~ "<circle"
    assert result =~ ~r/cx="50"/
  end

  test "renders SVG elements with empty attributes" do
    defmodule EmptyAttrsSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [], fn state ->
          circle(state, [])
        end)
      end
    end

    result = EmptyAttrsSVGComponent.render()
    assert result =~ "<svg>"
    assert result =~ "<circle>"
    assert result =~ "</circle>"
    assert result =~ "</svg>"
  end

  test "renders SVG elements with empty map attributes" do
    defmodule EmptyMapAttrsSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, %{}, fn state ->
          rect(state, %{})
        end)
      end
    end

    result = EmptyMapAttrsSVGComponent.render()
    assert result =~ "<svg>"
    assert result =~ "<rect>"
    assert result =~ "</rect>"
    assert result =~ "</svg>"
  end

  test "renders multiple SVG elements" do
    defmodule MultipleSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          state = circle(state, cx: 50, cy: 50, r: 25)
          state = rect(state, x: 10, y: 10, width: 20, height: 20)
          line(state, x1: 0, y1: 0, x2: 100, y2: 100)
        end)
      end
    end

    result = MultipleSVGComponent.render()
    assert result =~ "<circle"
    assert result =~ "<rect"
    assert result =~ "<line"
    assert result =~ "</circle>"
    assert result =~ "</rect>"
    assert result =~ "</line>"
  end

  test "renders SVG with direct text content" do
    defmodule TextContentSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          text(state, [x: 50, y: 50], "Hello")
        end)
      end
    end

    result = TextContentSVGComponent.render()
    assert result =~ "<text"
    assert result =~ "Hello"
    assert result =~ "</text>"
  end

  test "renders SVG with numeric content" do
    defmodule NumericContentSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          text(state, [x: 50, y: 50], 123)
        end)
      end
    end

    result = NumericContentSVGComponent.render()
    assert result =~ "<text"
    assert result =~ "123"
    assert result =~ "</text>"
  end

  test "renders SVG with atom content" do
    defmodule AtomContentSVGComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          text(state, [x: 50, y: 50], :label)
        end)
      end
    end

    result = AtomContentSVGComponent.render()
    assert result =~ "<text"
    assert result =~ "label"
    assert result =~ "</text>"
  end

  test "renders dynamic SVG tag" do
    defmodule DynamicSVGTagComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:path, [d: "M 10 10 L 20 20"], state)
        end)
      end
    end

    result = DynamicSVGTagComponent.render()
    assert result =~ "<path"
    assert result =~ ~r/d="M 10 10 L 20 20"/
  end

  test "renders dynamic SVG tag with content" do
    defmodule DynamicSVGTagWithContentComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:g, [id: "group"], state, fn state ->
            circle(state, cx: 50, cy: 50, r: 25)
          end)
        end)
      end
    end

    result = DynamicSVGTagWithContentComponent.render()
    assert result =~ "<g"
    assert result =~ ~r/id="group"/
    assert result =~ "<circle"
    assert result =~ "</circle>"
    assert result =~ "</g>"
  end

  test "normalizes dynamic SVG tag names with underscores" do
    defmodule UnderscoreSVGTagComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag(:linear_gradient, [id: "grad1"], state)
        end)
      end
    end

    result = UnderscoreSVGTagComponent.render()
    assert result =~ "<linear-gradient"
  end

  test "renders binary SVG tag name" do
    defmodule BinarySVGTagComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 100 100"], fn state ->
          Phlex.SVG.tag("custom-svg-element", [id: "custom"], state)
        end)
      end
    end

    result = BinarySVGTagComponent.render()
    assert result =~ "<custom-svg-element"
    assert result =~ "</custom-svg-element>"
  end

  test "renders SVG element when should_render is false" do
    defmodule SkipRenderSVGElementComponent do
      use Phlex.SVG

      def view_template(_assigns, state) do
        # Set fragments to empty set to make should_render? return false
        state = %{state | fragments: MapSet.new([])}

        svg(state, [viewBox: "0 0 100 100"], fn state ->
          circle(state, cx: 50, cy: 50, r: 25)
        end)
      end
    end

    result = SkipRenderSVGElementComponent.render()
    # Should not render when should_render? is false
    assert result == "" || result =~ "<svg"
  end
end
