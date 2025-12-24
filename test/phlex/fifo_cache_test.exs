defmodule Phlex.FIFOCacheTest do
  use ExUnit.Case, async: true

  alias Phlex.FIFOCache
  alias Phlex.SGML.Attributes

  describe "FIFOCache" do
    test "creates new cache with defaults" do
      cache = FIFOCache.new()
      assert %FIFOCache{} = cache
      assert cache.max_bytesize == 2_000_000
      assert cache.max_value_bytesize == 2_000_000
      assert FIFOCache.bytesize(cache) == 0
      assert FIFOCache.size(cache) == 0
    end

    test "creates cache with custom limits" do
      cache = FIFOCache.new(max_bytesize: 1_000, max_value_bytesize: 500)
      assert cache.max_bytesize == 1_000
      assert cache.max_value_bytesize == 500
    end

    test "fetches and caches values" do
      cache = FIFOCache.new()
      key = {:test, 1}

      # First call should compute
      {value1, cache} = FIFOCache.fetch(cache, key, fn -> "computed value" end)
      assert value1 == "computed value"

      # Second call should use cache
      {value2, cache} = FIFOCache.fetch(cache, key, fn -> "should not be called" end)
      assert value2 == "computed value"
      assert FIFOCache.size(cache) == 1
    end

    test "does not cache values larger than max_value_bytesize" do
      cache = FIFOCache.new(max_value_bytesize: 10)
      large_value = String.duplicate("a", 100)

      {value, cache} = FIFOCache.fetch(cache, {:large, 1}, fn -> large_value end)
      assert value == large_value
      # Should not be cached
      assert FIFOCache.size(cache) == 0
    end

    test "evicts oldest entries when max_bytesize exceeded" do
      cache = FIFOCache.new(max_bytesize: 100, max_value_bytesize: 50)

      # Add entries that will exceed max_bytesize
      {_, cache} = FIFOCache.fetch(cache, {:key, 1}, fn -> String.duplicate("a", 30) end)
      {_, cache} = FIFOCache.fetch(cache, {:key, 2}, fn -> String.duplicate("b", 30) end)
      {_, cache} = FIFOCache.fetch(cache, {:key, 3}, fn -> String.duplicate("c", 30) end)
      {_, cache} = FIFOCache.fetch(cache, {:key, 4}, fn -> String.duplicate("d", 30) end)

      # Should have evicted some entries
      size = FIFOCache.size(cache)
      assert size < 4

      # First entry should be evicted (FIFO)
      {result, _cache} = FIFOCache.fetch(cache, {:key, 1}, fn -> "new value" end)
      # Was evicted, so recomputed
      assert result == "new value"
    end

    test "clears all entries" do
      cache = FIFOCache.new()
      {_, cache} = FIFOCache.fetch(cache, {:key, 1}, fn -> "value1" end)
      {_, cache} = FIFOCache.fetch(cache, {:key, 2}, fn -> "value2" end)

      assert FIFOCache.size(cache) == 2

      cleared = FIFOCache.clear(cache)
      assert FIFOCache.size(cleared) == 0
      assert FIFOCache.bytesize(cleared) == 0
    end

    test "tracks bytesize correctly" do
      cache = FIFOCache.new()
      value = "test value"
      expected_bytesize = byte_size(value)

      {_, cache} = FIFOCache.fetch(cache, {:key, 1}, fn -> value end)

      assert FIFOCache.bytesize(cache) == expected_bytesize
    end
  end

  describe "attribute caching integration" do
    test "Phlex.fetch_attributes uses FIFO cache" do
      attrs = [class: "test", id: "my-id"]

      # First call
      result1 =
        Phlex.fetch_attributes(attrs, fn ->
          Attributes.generate_attributes(attrs, [])
        end)

      # Second call should use cache
      result2 =
        Phlex.fetch_attributes(attrs, fn ->
          raise "Should not be called"
        end)

      assert result1 == result2
    end
  end
end
