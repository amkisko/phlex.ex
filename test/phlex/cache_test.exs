defmodule Phlex.CacheTest do
  alias Phlex.SGML.State
  use ExUnit.Case

  defmodule TestComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      # Use explicit state passing (cache and other SGML functions still need it)
      div(state, [], fn state ->
        cache(state, [:test_key], fn state ->
          h1(state, [], "Cached Content")
        end)
      end)
    end
  end

  test "cache function executes block" do
    result = TestComponent.render()
    assert result =~ "Cached Content"
    assert result =~ "<h1>"
  end

  test "capture function captures output" do
    state = State.new()

    captured =
      Phlex.SGML.capture(state, fn state ->
        state
        |> Phlex.SGML.append_text("Hello")
        |> Phlex.SGML.append_text(" World")
      end)

    assert captured == "Hello World"
  end
end
