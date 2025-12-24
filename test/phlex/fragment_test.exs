defmodule Phlex.FragmentTest do
  use ExUnit.Case

  @moduletag :fragment

  defmodule ComponentWithFragments do
    use Phlex.HTML

    def view_template(_assigns, state) do
      state
      |> div([], fn state ->
        state
        |> h1([], fn state ->
          Phlex.SGML.append_text(state, "Header")
        end)
        |> Phlex.SGML.fragment("content", fn state ->
          state
          |> p([], fn state ->
            Phlex.SGML.append_text(state, "This is a fragment")
          end)
        end)
        |> Phlex.SGML.fragment("footer", fn state ->
          state
          |> footer([], fn state ->
            Phlex.SGML.append_text(state, "Footer content")
          end)
        end)
      end)
    end
  end

  test "renders all content when no fragments specified" do
    result = ComponentWithFragments.render()
    assert result =~ "Header"
    assert result =~ "This is a fragment"
    assert result =~ "Footer content"
  end

  test "renders only specified fragment" do
    result = ComponentWithFragments.render(%{}, fragments: MapSet.new(["content"]))
    assert result =~ "This is a fragment"
    assert result =~ "<p>"
    # Should not contain header or footer
    refute result =~ "Header"
    refute result =~ "Footer content"
  end

  test "renders multiple fragments" do
    result = ComponentWithFragments.render(%{}, fragments: MapSet.new(["content", "footer"]))
    assert result =~ "This is a fragment"
    assert result =~ "Footer content"
    refute result =~ "Header"
  end
end
