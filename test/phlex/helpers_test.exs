defmodule Phlex.HelpersTest do
  use ExUnit.Case

  test "escape_html with binary string" do
    result = Phlex.Helpers.escape_html("<script>alert('xss')</script>")
    # Phoenix.HTML.html_escape returns iodata, convert to string for assertion
    result_str = IO.iodata_to_binary(result)
    assert result_str =~ "&lt;script&gt;"
    assert result_str =~ "&lt;/script&gt;"
  end

  test "escape_html with atom" do
    result = Phlex.Helpers.escape_html(:test_atom)
    result_str = IO.iodata_to_binary(result)
    assert result_str == "test_atom"
  end

  test "escape_html with number" do
    result = Phlex.Helpers.escape_html(123)
    result_str = IO.iodata_to_binary(result)
    assert result_str == "123"
  end

  test "escape_html with special characters" do
    result = Phlex.Helpers.escape_html("Say \"Hello\" & 'World'")
    result_str = IO.iodata_to_binary(result)
    assert result_str =~ "&quot;"
    assert result_str =~ "&amp;"
    assert result_str =~ "&#39;"
  end

  test "defcomponent macro creates component" do
    require Phlex.Helpers

    Phlex.Helpers.defcomponent TestCard do
      def view_template(_assigns, state) do
        div(state, [class: "card"], fn state ->
          Phlex.SGML.append_text(state, "Test")
        end)
      end
    end

    result = TestCard.render()
    assert result =~ "<div"
    assert result =~ "class=\"card\""
    assert result =~ "Test"
  end

  test "defsvg_component macro creates SVG component" do
    require Phlex.Helpers

    Phlex.Helpers.defsvg_component TestIcon do
      def view_template(_assigns, state) do
        svg(state, [viewBox: "0 0 24 24"], fn state ->
          circle(state, cx: "12", cy: "12", r: "10")
        end)
      end
    end

    result = TestIcon.render()
    assert result =~ "<svg"
    assert result =~ "viewBox=\"0 0 24 24\""
    assert result =~ "<circle"
  end
end
