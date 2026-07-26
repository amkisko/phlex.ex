defmodule Phlex.CacheTest do
  alias Phlex.SGML.State
  use ExUnit.Case

  defmodule TestComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      div(state, [], fn state ->
        cache(state, [:test_key], fn state ->
          h1(state, [], "Cached Content")
        end)
      end)
    end
  end

  defmodule CountingCacheComponent do
    use Phlex.HTML

    def view_template(assigns, state) do
      original_assigns = Map.fetch!(assigns, :_assigns)

      cache(state, [:counting, Map.fetch!(original_assigns, :token)], fn state ->
        send(Map.fetch!(original_assigns, :test_pid), :cache_miss)
        h1(state, [], "Cached Content")
      end)
    end
  end

  test "cache function executes block" do
    result = TestComponent.render()
    assert result =~ "Cached Content"
    assert result =~ "<h1>"
  end

  test "cache reuses stored markup on second render" do
    Process.delete(:phlex_component_cache_store)
    test_pid = self()

    assert CountingCacheComponent.render(%{token: "a", test_pid: test_pid}) =~ "Cached Content"
    assert_received :cache_miss

    assert CountingCacheComponent.render(%{token: "a", test_pid: test_pid}) =~ "Cached Content"
    refute_received :cache_miss
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
