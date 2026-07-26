defmodule Phlex.SelectiveRenderingFromCacheTest do
  use ExUnit.Case, async: false

  defmodule CacheTest do
    use Phlex.HTML

    def view_template(assigns, state) do
      page_id = assigns._assigns.page_id

      cache(state, page_id, fn state ->
        state
        |> h1([], fn state ->
          Phlex.SGML.append_text(state, "Page #{page_id}")
        end)
        |> fragment("outer", fn state ->
          div(state, [id: "page"], fn state ->
            cache(state, fn state ->
              section(state, [], fn state ->
                fragment(state, "list", fn state ->
                  ul(state, [], fn state ->
                    state
                    |> fragment("foo", fn state ->
                      li(state, [], fn state ->
                        Phlex.SGML.append_text(state, "1")
                      end)
                    end)
                    |> li([], "2")
                    |> li([], "3")
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end
  end

  setup do
    store = Phlex.FIFOCacheStore.new()
    Process.put(:phlex_component_cache_store, store)
    :ok
  end

  test "renders caches and fragments fully" do
    output = CacheTest.render(%{page_id: 1})

    assert output ==
             ~s(<h1>Page 1</h1><div id="page"><section><ul><li>1</li><li>2</li><li>3</li></ul></section></div>)

    output = CacheTest.render(%{page_id: 1})

    assert output ==
             ~s(<h1>Page 1</h1><div id="page"><section><ul><li>1</li><li>2</li><li>3</li></ul></section></div>)
  end

  test "different cache keys produce different outer content" do
    assert CacheTest.render(%{page_id: 1}) =~ "Page 1"
    assert CacheTest.render(%{page_id: 2}) =~ "Page 2"
  end

  test "renders a specific fragment from within a cache" do
    Enum.each(1..2, fn _ ->
      output = CacheTest.render(%{page_id: 2}, fragments: ["list"])
      assert output == "<ul><li>1</li><li>2</li><li>3</li></ul>"
    end)
  end

  test "renders a nested fragment from within a cache" do
    output = CacheTest.render(%{page_id: 1}, fragments: ["foo"])
    assert output == "<li>1</li>"
  end

  test "renders multiple fragments from within a cache" do
    output = CacheTest.render(%{page_id: 1}, fragments: ["list", "foo"])
    assert output == "<ul><li>1</li><li>2</li><li>3</li></ul>"
  end

  test "renders multiple fragments out of request order from within a cache" do
    output = CacheTest.render(%{page_id: 1}, fragments: ["foo", "list"])
    assert output == "<ul><li>1</li><li>2</li><li>3</li></ul>"
  end

  test "cache contains full value if initially rendered as a fragment" do
    assert CacheTest.render(%{page_id: 1}, fragments: ["foo"]) == "<li>1</li>"

    assert CacheTest.render(%{page_id: 1}) ==
             ~s(<h1>Page 1</h1><div id="page"><section><ul><li>1</li><li>2</li><li>3</li></ul></section></div>)
  end

  test "fetches a nested fragment from a previously warmed cache" do
    CacheTest.render(%{page_id: 1})
    assert CacheTest.render(%{page_id: 2}, fragments: ["foo"]) == "<li>1</li>"
  end
end
