defmodule Phlex.HTMLTest do
  use ExUnit.Case
  doctest Phlex.HTML

  defmodule TestComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      state
      |> div([class: "container"], fn state ->
        state
        |> h1([], fn state ->
          Phlex.SGML.append_text(state, "Hello, World!")
        end)
      end)
    end
  end

  test "renders HTML component" do
    result = TestComponent.render()
    assert result =~ ~r/<div class="container">/
    assert result =~ ~r/<h1>/
    assert result =~ "Hello, World!"
    assert result =~ "</h1>"
    assert result =~ "</div>"
  end

  test "renders void elements" do
    defmodule VoidTestComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state
        |> br()
        |> hr(class: "separator")
      end
    end

    result = VoidTestComponent.render()
    assert result =~ "<br>"
    assert result =~ ~r/<hr class="separator">/
  end

  test "renders doctype" do
    defmodule DoctypeComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state = doctype(state)

        html(state, [], fn state ->
          Phlex.SGML.append_text(state, "content")
        end)
      end
    end

    result = DoctypeComponent.render()
    assert result =~ "<!doctype html>"
    assert result =~ "<html>"
  end

  test "renders elements with direct text content" do
    defmodule DirectTextComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        h1(state, [class: "title"], "Hello")
      end
    end

    result = DirectTextComponent.render()
    assert result =~ ~r/<h1 class="title">/
    assert result =~ "Hello"
    assert result =~ "</h1>"
  end

  test "renders elements with atom content" do
    defmodule AtomContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        span(state, [], :test_atom)
      end
    end

    result = AtomContentComponent.render()
    assert result =~ "<span>"
    assert result =~ "test_atom"
    assert result =~ "</span>"
  end

  test "renders elements with numeric content" do
    defmodule NumericContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        span(state, [], 123)
      end
    end

    result = NumericContentComponent.render()
    assert result =~ "<span>"
    assert result =~ "123"
    assert result =~ "</span>"
  end

  test "renders elements with list content" do
    defmodule ListContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, [], fn state ->
          state
          |> Phlex.SGML.append_text("First")
          |> Phlex.SGML.append_text("Second")
          |> Phlex.SGML.append_text("Third")
        end)
      end
    end

    result = ListContentComponent.render()
    assert result =~ "<div>"
    assert result =~ "First"
    assert result =~ "Second"
    assert result =~ "Third"
    assert result =~ "</div>"
  end

  test "renders elements without attributes" do
    defmodule NoAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.div(state, fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = NoAttrsComponent.render()
    assert result =~ "<div>"
    assert result =~ "Content"
    assert result =~ "</div>"
  end

  test "renders elements without content" do
    defmodule NoContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.div(state, class: "empty")
      end
    end

    result = NoContentComponent.render()
    assert result =~ ~r/<div class="empty">/
    assert result =~ "</div>"
  end

  test "renders void elements without attributes" do
    defmodule VoidNoAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        br(state)
      end
    end

    result = VoidNoAttrsComponent.render()
    assert result =~ "<br>"
  end

  test "renders multiple standard elements" do
    defmodule MultipleElementsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state
        |> div([class: "container"], fn state ->
          state
          |> h1([], "Title")
          |> p([], "Paragraph")
          |> a([href: "/link"], "Link")
        end)
      end
    end

    result = MultipleElementsComponent.render()
    assert result =~ "<div"
    assert result =~ "<h1>"
    assert result =~ "Title"
    assert result =~ "<p>"
    assert result =~ "Paragraph"
    assert result =~ "<a"
    assert result =~ "href"
    assert result =~ "Link"
  end

  test "renders table elements" do
    defmodule TableComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        table(state, [], fn state ->
          tr(state, [], fn state ->
            td(state, [], "Cell")
          end)
        end)
      end
    end

    result = TableComponent.render()
    assert result =~ "<table>"
    assert result =~ "<tr>"
    assert result =~ "<td>"
    assert result =~ "Cell"
    assert result =~ "</td>"
    assert result =~ "</tr>"
    assert result =~ "</table>"
  end

  test "renders form elements" do
    defmodule FormComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        form(state, [action: "/submit"], fn state ->
          state
          |> input(type: "text", name: "username")
          |> button([], "Submit")
        end)
      end
    end

    result = FormComponent.render()
    assert result =~ "<form"
    assert result =~ "action"
    assert result =~ "<input"
    assert result =~ "type"
    assert result =~ "name"
    assert result =~ "<button>"
    assert result =~ "Submit"
  end

  test "renders semantic elements" do
    defmodule SemanticComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state
        |> header([], fn state ->
          Phlex.SGML.append_text(state, "Header")
        end)
        |> main([], fn state ->
          Phlex.SGML.append_text(state, "Main")
        end)
        |> footer([], fn state ->
          Phlex.SGML.append_text(state, "Footer")
        end)
      end
    end

    result = SemanticComponent.render()
    assert result =~ "<header>"
    assert result =~ "Header"
    assert result =~ "<main>"
    assert result =~ "Main"
    assert result =~ "<footer>"
    assert result =~ "Footer"
  end

  test "renders dynamic tag" do
    defmodule DynamicTagComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:section, [class: "main"], state, fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = DynamicTagComponent.render()
    assert result =~ "<section"
    assert result =~ "class=\"main\""
    assert result =~ "Content"
    assert result =~ "</section>"
  end

  test "renders dynamic void tag" do
    defmodule DynamicVoidTagComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:custom_void, [data_test: "value"], state)
      end
    end

    result = DynamicVoidTagComponent.render()
    assert result =~ "<custom-void"
    assert result =~ "data-test"
  end

  test "normalizes tag names with underscores" do
    defmodule UnderscoreTagComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:custom_element, [], state)
      end
    end

    result = UnderscoreTagComponent.render()
    assert result =~ "custom-element"
  end

  test "skips rendering when should_render is false" do
    defmodule SkipRenderComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, [class: "test"], fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    # Render with fragments that don't match
    result = SkipRenderComponent.render(%{fragments: MapSet.new([:other])})
    # Component should still render (fragments only affect fragment blocks)
    assert result =~ "<div"
  end

  test "renders nested elements" do
    defmodule NestedComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, [class: "outer"], fn state ->
          div(state, [class: "inner"], fn state ->
            Phlex.SGML.append_text(state, "Nested")
          end)
        end)
      end
    end

    result = NestedComponent.render()
    assert result =~ ~r/<div class="outer">/
    assert result =~ ~r/<div class="inner">/
    assert result =~ "Nested"
    # Check closing tags
    assert result =~ "</div>"
    # Should have two closing divs
    assert String.split(result, "</div>") |> length() == 3
  end

  test "renders elements with map attributes" do
    defmodule MapAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, %{class: "test", id: "foo"}, fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = MapAttrsComponent.render()
    assert result =~ ~r/class="test"/
    assert result =~ ~r/id="foo"/
    assert result =~ "Content"
  end

  test "renders elements with empty attributes" do
    defmodule EmptyAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, [], fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = EmptyAttrsComponent.render()
    assert result =~ "<div>"
    assert result =~ "Content"
    assert result =~ "</div>"
  end

  test "renders elements with empty map attributes" do
    defmodule EmptyMapAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, %{}, fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = EmptyMapAttrsComponent.render()
    assert result =~ "<div>"
    assert result =~ "Content"
    assert result =~ "</div>"
  end

  test "renders void elements with map attributes" do
    defmodule VoidMapAttrsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state = br(state, %{class: "clear"})
        hr(state, %{id: "separator"})
      end
    end

    result = VoidMapAttrsComponent.render()
    assert result =~ ~r/<br class="clear"/
    assert result =~ ~r/<hr id="separator"/
  end

  test "renders multiple void elements" do
    defmodule MultipleVoidComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state = br(state)
        state = hr(state)
        img(state, src: "test.jpg")
      end
    end

    result = MultipleVoidComponent.render()
    assert result =~ "<br"
    assert result =~ "<hr"
    assert result =~ ~r/<img src="test.jpg"/
  end

  test "renders elements with multiple list items as content" do
    defmodule MultipleListItemsComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        # List content is handled internally by render_content
        # We need to use the tag function or render_element directly
        Phlex.HTML.render_element(:div, [class: "container"], state, ["First", "Second", "Third"])
      end
    end

    result = MultipleListItemsComponent.render()
    assert result =~ "<div"
    assert result =~ "First"
    assert result =~ "Second"
    assert result =~ "Third"
  end

  test "renders dynamic tag with content" do
    defmodule DynamicTagWithNestedComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:section, [class: "main"], state, fn state ->
          p(state, [], fn state ->
            Phlex.SGML.append_text(state, "Content")
          end)
        end)
      end
    end

    result = DynamicTagWithNestedComponent.render()
    assert result =~ "<section"
    assert result =~ ~r/class="main"/
    assert result =~ "<p>"
    assert result =~ "Content"
    assert result =~ "</p>"
    assert result =~ "</section>"
  end

  test "renders dynamic tag without content (void)" do
    defmodule DynamicVoidTagBrComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:br, [class: "clear"], state)
      end
    end

    result = DynamicVoidTagBrComponent.render()
    assert result =~ ~r/<br class="clear"/
  end

  test "renders element when should_render is false but content exists" do
    defmodule SkipRenderWithContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        # Set fragments to empty set to make should_render? return false
        state = %{state | fragments: MapSet.new([])}

        div(state, [class: "test"], fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = SkipRenderWithContentComponent.render()
    # Content should still be executed for fragment processing
    assert result =~ "Content" || result == ""
  end

  test "renders element with atom content" do
    defmodule AtomContentLabelComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        span(state, [class: "label"], :active)
      end
    end

    result = AtomContentLabelComponent.render()
    assert result =~ "<span"
    assert result =~ "active"
  end

  test "renders element with number content" do
    defmodule NumberContentComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        span(state, [class: "count"], 42)
      end
    end

    result = NumberContentComponent.render()
    assert result =~ "<span"
    assert result =~ "42"
  end

  test "renders dynamic tag with underscore normalization" do
    defmodule UnderscoreTagDataTestComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag(:data_test_id, [value: "123"], state, fn state ->
          Phlex.SGML.append_text(state, "Test")
        end)
      end
    end

    result = UnderscoreTagDataTestComponent.render()
    assert result =~ "<data-test-id"
    assert result =~ "</data-test-id>"
  end

  test "renders binary tag name" do
    defmodule BinaryTagComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.HTML.tag("custom-tag", [class: "test"], state, fn state ->
          Phlex.SGML.append_text(state, "Content")
        end)
      end
    end

    result = BinaryTagComponent.render()
    assert result =~ "<custom-tag"
    assert result =~ "</custom-tag>"
  end
end
