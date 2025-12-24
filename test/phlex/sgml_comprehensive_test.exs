defmodule Phlex.SGMLComprehensiveTest do
  use ExUnit.Case

  alias Phlex.SGML

  defmodule SimpleComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      state
      |> div([class: "container"], fn state ->
        SGML.append_text(state, "Hello")
      end)
    end
  end

  defmodule NestedComponent do
    use Phlex.HTML

    def view_template(assigns, state) do
      # Access original assigns from _assigns field
      original_assigns = Map.get(assigns, :_assigns, %{})
      title = Map.get(original_assigns, :title, "Default")
      content = Map.get(original_assigns, :content, "")

      state
      |> div([], fn state ->
        state
        |> h1([], fn state ->
          SGML.append_text(state, title)
        end)
        |> p([], fn state ->
          SGML.append_text(state, content)
        end)
      end)
    end
  end

  defmodule ComponentWithAttributes do
    use Phlex.HTML

    def view_template(assigns, state) do
      # Access original assigns from _assigns field
      original_assigns = Map.get(assigns, :_assigns, %{})
      id = Map.get(original_assigns, :id, "default")

      attrs = [
        class: "card",
        id: id,
        data_test: "value",
        style: [color: "red", padding: "10px"]
      ]

      state
      |> div(attrs, fn state ->
        SGML.append_text(state, "Content")
      end)
    end
  end

  test "renders simple component" do
    result = SimpleComponent.render()
    assert result =~ "<div"
    assert result =~ "class=\"container\""
    assert result =~ "Hello"
  end

  test "renders nested components" do
    # Test with assigns
    result = NestedComponent.render(%{title: "Test", content: "Body"})
    assert result =~ "<h1>Test</h1>"
    assert result =~ "<p>Body</p>"

    # Verify it works
    assert result =~ "<div>"
  end

  test "renders component with complex attributes" do
    result = ComponentWithAttributes.render(%{id: "card-1"})
    assert result =~ "class=\"card\""
    assert result =~ "id=\"card-1\""
    assert result =~ "data-test=\"value\""
    assert result =~ "style="
    assert result =~ "color: red"
    assert result =~ "padding: 10px"
  end

  test "renders component with default id" do
    result = ComponentWithAttributes.render(%{})
    assert result =~ "id=\"default\""
  end

  test "renders component with default values" do
    result = NestedComponent.render(%{})
    assert result =~ "<h1>Default</h1>"
  end

  test "append_raw works for trusted content" do
    state = SGML.State.new()
    state = SGML.append_raw(state, "<strong>Bold</strong>")
    result = IO.iodata_to_binary(state.buffer)
    assert result == "<strong>Bold</strong>"
  end

  test "append_text escapes HTML" do
    state = SGML.State.new()
    state = SGML.append_text(state, "<script>alert('xss')</script>")
    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "&lt;script&gt;"
    # Single quote is escaped as &#39;
    assert result =~ "&#39;"
    assert result =~ "&lt;/script&gt;"
  end

  test "render_component renders another component" do
    defmodule WrapperComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        state
        |> div([], fn state ->
          SGML.render_component(state, SimpleComponent, %{})
        end)
      end
    end

    result = WrapperComponent.render()
    assert result =~ "<div"
    assert result =~ "Hello"
  end

  test "generate_attributes creates proper attribute string" do
    attrs = [class: "foo", id: "bar", disabled: true]
    result = SGML.generate_attributes(attrs)
    assert result =~ "class=\"foo\""
    assert result =~ "id=\"bar\""
    assert result =~ "disabled"
  end
end
