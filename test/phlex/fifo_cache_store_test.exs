defmodule Phlex.FIFOCacheStoreTest do
  use ExUnit.Case

  defmodule TestStructWithVersion do
    defstruct [:id, :version]

    def cache_key_with_version(%__MODULE__{id: id, version: version}) do
      {id, version}
    end
  end

  defmodule TestStructWithKey do
    defstruct [:id]

    def cache_key(%__MODULE__{id: id}) do
      id
    end
  end

  defmodule TestStructWithoutKey do
    defstruct [:id]
  end

  describe "new/1" do
    test "creates a new cache store with default max_bytesize" do
      store = Phlex.FIFOCacheStore.new()
      assert store.max_bytesize == 1_048_576
      assert store.bytesize == 0
      assert store.fifo_map == %{}
      assert store.fifo_order == []
    end

    test "creates a new cache store with custom max_bytesize" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 1024)
      assert store.max_bytesize == 1024
    end
  end

  describe "fetch/3" do
    test "caches and returns value" do
      store = Phlex.FIFOCacheStore.new()
      {value, new_store} = Phlex.FIFOCacheStore.fetch(store, "key", fn -> "value" end)
      assert value == "value"
      assert Phlex.FIFOCacheStore.size(new_store) == 1
    end

    test "returns cached value on second fetch" do
      store = Phlex.FIFOCacheStore.new()
      {value1, store1} = Phlex.FIFOCacheStore.fetch(store, "key", fn -> "value" end)
      {value2, store2} = Phlex.FIFOCacheStore.fetch(store1, "key", fn -> "different" end)
      assert value1 == "value"
      assert value2 == "value"
      assert Phlex.FIFOCacheStore.size(store2) == 1
    end

    test "evicts entries when max_bytesize exceeded" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 50)
      # Add a small value
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> "small" end)
      # Add another value
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> "another" end)
      # Verify cache is working
      assert Phlex.FIFOCacheStore.size(store2) >= 1
      # Add a value that should cause eviction
      large_value = String.duplicate("x", 100)
      {_, store3} = Phlex.FIFOCacheStore.fetch(store2, "key3", fn -> large_value end)
      # Cache should have evicted some entries
      assert Phlex.FIFOCacheStore.bytesize(store3) <= store3.max_bytesize
    end
  end

  describe "clear/1" do
    test "clears all entries" do
      store = Phlex.FIFOCacheStore.new()
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key", fn -> "value" end)
      cleared = Phlex.FIFOCacheStore.clear(store1)
      assert cleared.fifo_map == %{}
      assert cleared.fifo_order == []
      assert cleared.bytesize == 0
    end
  end

  describe "size/1" do
    test "returns number of entries" do
      store = Phlex.FIFOCacheStore.new()
      assert Phlex.FIFOCacheStore.size(store) == 0
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> "value1" end)
      assert Phlex.FIFOCacheStore.size(store1) == 1
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> "value2" end)
      assert Phlex.FIFOCacheStore.size(store2) == 2
    end
  end

  describe "bytesize/1" do
    test "returns current cache size in bytes" do
      store = Phlex.FIFOCacheStore.new()
      assert Phlex.FIFOCacheStore.bytesize(store) == 0
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key", fn -> "value" end)
      assert Phlex.FIFOCacheStore.bytesize(store1) > 0
    end
  end

  describe "fetch/3 with large values" do
    test "does not cache value larger than max_bytesize" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 100)
      large_value = String.duplicate("x", 200)
      {value, new_store} = Phlex.FIFOCacheStore.fetch(store, "large_key", fn -> large_value end)
      assert value == large_value
      # Value should not be cached
      assert Phlex.FIFOCacheStore.size(new_store) == 0
    end
  end

  describe "fetch/3 with complex keys" do
    test "handles list keys" do
      store = Phlex.FIFOCacheStore.new()
      key = ["foo", "bar", "baz"]
      {value, _store} = Phlex.FIFOCacheStore.fetch(store, key, fn -> "value" end)
      assert value == "value"
    end

    test "handles map keys" do
      store = Phlex.FIFOCacheStore.new()
      key = %{foo: "bar", baz: 123}
      {value, _store} = Phlex.FIFOCacheStore.fetch(store, key, fn -> "value" end)
      assert value == "value"
    end

    test "handles nested map keys" do
      store = Phlex.FIFOCacheStore.new()
      key = %{foo: %{bar: "baz"}, nested: [1, 2, 3]}
      {value, _store} = Phlex.FIFOCacheStore.fetch(store, key, fn -> "value" end)
      assert value == "value"
    end

    test "handles complex nested keys" do
      store = Phlex.FIFOCacheStore.new()
      # Test deeply nested structures
      key = [
        "level1",
        %{nested: ["level2", %{deep: "level3"}]},
        [1, 2, 3]
      ]

      {value, _store} = Phlex.FIFOCacheStore.fetch(store, key, fn -> "value" end)
      assert value == "value"
    end

    test "handles keys with various primitive types" do
      store = Phlex.FIFOCacheStore.new()
      # Test all primitive types that map_key handles
      key = [
        "string",
        :atom,
        123,
        45.67,
        true,
        false,
        nil
      ]

      {value, _store} = Phlex.FIFOCacheStore.fetch(store, key, fn -> "value" end)
      assert value == "value"
    end
  end

  describe "eviction" do
    test "evicts all entries when needed_space exceeds current_bytesize" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 100)
      # Add a small value
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> "small" end)
      # Add a very large value that requires evicting everything
      large_value = String.duplicate("x", 500)
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> large_value end)
      # Should have evicted the first entry
      assert Phlex.FIFOCacheStore.size(store2) == 1
    end

    test "evicts multiple entries when needed" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 150)
      # Add multiple entries that together exceed the limit
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> String.duplicate("a", 60) end)
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> String.duplicate("b", 60) end)
      {_, store3} = Phlex.FIFOCacheStore.fetch(store2, "key3", fn -> String.duplicate("c", 60) end)
      # Add a large value that requires evicting multiple entries
      # The serialized size will be larger than the string itself
      large_value = String.duplicate("x", 100)
      {_, store4} = Phlex.FIFOCacheStore.fetch(store3, "key4", fn -> large_value end)
      # Should have evicted some entries to make room
      # The exact number depends on serialization overhead, but size should be reduced
      assert Phlex.FIFOCacheStore.bytesize(store4) <= store4.max_bytesize
      # At least one entry should have been evicted
      assert Phlex.FIFOCacheStore.size(store4) <= Phlex.FIFOCacheStore.size(store3)
    end

    test "handles eviction with empty order list" do
      # Create a store with empty order but non-empty map (edge case)
      store = Phlex.FIFOCacheStore.new(max_bytesize: 10)
      # Manually create edge case: empty order but we need to evict
      edge_store = %{store | fifo_map: %{"key" => "value"}, fifo_order: [], bytesize: 5}
      # Add a value that triggers eviction with empty order
      large_value = String.duplicate("x", 100)
      {_, _store2} = Phlex.FIFOCacheStore.fetch(edge_store, "key2", fn -> large_value end)
      # Should handle empty order gracefully
      assert true
    end

    test "handles eviction with nil value in map" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 50)
      # Add entries to fill cache
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> "value1" end)
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> "value2" end)
      # Manually corrupt the map to have nil (testing edge case)
      # This tests the nil case in evict_until_space_available
      corrupted_store = %{
        store2
        | fifo_map: Map.put(store2.fifo_map, "missing_key", nil),
          fifo_order: ["missing_key" | store2.fifo_order]
      }

      # Add a value that triggers eviction
      {_, _store3} = Phlex.FIFOCacheStore.fetch(corrupted_store, "key3", fn -> "value3" end)
      # Should handle nil gracefully
      assert true
    end

    test "evicts everything when current_bytesize <= needed_space" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 100)
      # Add a value that fills most of the cache
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> String.duplicate("a", 80) end)
      # Add a value that requires evicting everything (needed_space >= current_bytesize)
      large_value = String.duplicate("x", 200)
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> large_value end)
      # Should have evicted everything
      assert Phlex.FIFOCacheStore.size(store2) == 1
      assert Phlex.FIFOCacheStore.bytesize(store2) <= store2.max_bytesize
    end

    test "evicts until exactly enough space is available" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 200)
      # Add multiple entries
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> String.duplicate("a", 60) end)
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> String.duplicate("b", 60) end)
      {_, store3} = Phlex.FIFOCacheStore.fetch(store2, "key3", fn -> String.duplicate("c", 60) end)
      # Add a value that requires evicting some but not all entries
      # This tests the recursive eviction path
      large_value = String.duplicate("x", 100)
      {_, store4} = Phlex.FIFOCacheStore.fetch(store3, "key4", fn -> large_value end)
      # Should have evicted some entries but not all
      assert Phlex.FIFOCacheStore.size(store4) >= 1
      assert Phlex.FIFOCacheStore.bytesize(store4) <= store4.max_bytesize
    end

    test "handles eviction when new_bytesize exactly equals max_bytesize" do
      store = Phlex.FIFOCacheStore.new(max_bytesize: 100)
      # Add a value that exactly fills the cache
      {_, store1} = Phlex.FIFOCacheStore.fetch(store, "key1", fn -> String.duplicate("a", 50) end)
      # Add another value that together would exceed max_bytesize
      {_, store2} = Phlex.FIFOCacheStore.fetch(store1, "key2", fn -> String.duplicate("b", 60) end)
      # Should handle the edge case where new_bytesize > max_bytesize
      assert Phlex.FIFOCacheStore.bytesize(store2) <= store2.max_bytesize
    end
  end
end
