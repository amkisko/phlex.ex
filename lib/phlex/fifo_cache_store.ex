defmodule Phlex.FIFOCacheStore do
  @moduledoc """
  An extremely fast in-memory cache store that evicts keys on a first-in-first-out basis.

  This cache store is useful for caching rendered component fragments and attribute strings
  to improve performance in production environments.

  ## Example

      defmodule MyComponent do
        use Phlex.HTML

        defp cache_store do
          Phlex.FIFOCacheStore.new(max_bytesize: 1_048_576) # 1MB
        end
      end
  """

  defstruct [:fifo_map, :fifo_order, :max_bytesize, bytesize: 0]

  @doc """
  Creates a new FIFO cache store.

  ## Options

  - `:max_bytesize` - Maximum total size in bytes (default: 1MB)
  """
  def new(opts \\ []) do
    max_bytesize = Keyword.get(opts, :max_bytesize, 1_048_576)
    %__MODULE__{fifo_map: %{}, fifo_order: [], max_bytesize: max_bytesize}
  end

  @doc """
  Fetches a value from the cache, or executes the function and caches the result.
  """
  def fetch(%__MODULE__{} = store, key, fun) when is_function(fun, 0) do
    normalized_key = map_key(key)

    case Map.get(store.fifo_map, normalized_key) do
      nil ->
        result = fun.()
        serialized = :erlang.term_to_binary(result)
        bytesize = byte_size(serialized)

        if bytesize < store.max_bytesize do
          new_store = add_to_cache(store, normalized_key, result, bytesize)
          {result, new_store}
        else
          {result, store}
        end

      cached_value ->
        {cached_value, store}
    end
  end

  @doc """
  Clears all entries from the cache.
  """
  def clear(%__MODULE__{} = store) do
    %{store | fifo_map: %{}, fifo_order: [], bytesize: 0}
  end

  @doc """
  Returns the current size of the cache in bytes.
  """
  def bytesize(%__MODULE__{} = store) do
    store.bytesize
  end

  @doc """
  Returns the number of entries in the cache.
  """
  def size(%__MODULE__{} = store) do
    length(store.fifo_order)
  end

  defp add_to_cache(store, key, value, bytesize) do
    new_bytesize = store.bytesize + bytesize

    {fifo_map, fifo_order, current_bytesize} =
      if new_bytesize > store.max_bytesize do
        needed_space = new_bytesize - store.max_bytesize
        evict_until_space_available(store.fifo_map, store.fifo_order, store.bytesize, needed_space)
      else
        {store.fifo_map, store.fifo_order, store.bytesize}
      end

    new_fifo_map = Map.put(fifo_map, key, value)
    new_fifo_order = fifo_order ++ [key]
    final_bytesize = current_bytesize + bytesize

    %{store | fifo_map: new_fifo_map, fifo_order: new_fifo_order, bytesize: final_bytesize}
  end

  defp evict_until_space_available(fifo_map, fifo_order, current_bytesize, needed_space)
       when current_bytesize <= needed_space do
    {fifo_map, fifo_order, current_bytesize}
  end

  defp evict_until_space_available(fifo_map, [oldest_key | rest_order], current_bytesize, needed_space) do
    case Map.get(fifo_map, oldest_key) do
      nil ->
        evict_until_space_available(fifo_map, rest_order, current_bytesize, needed_space)

      value ->
        evicted_bytesize = byte_size(:erlang.term_to_binary(value))
        new_fifo_map = Map.delete(fifo_map, oldest_key)
        new_bytesize = current_bytesize - evicted_bytesize

        if new_bytesize <= needed_space do
          {new_fifo_map, rest_order, new_bytesize}
        else
          evict_until_space_available(new_fifo_map, rest_order, new_bytesize, needed_space)
        end
    end
  end

  defp evict_until_space_available(fifo_map, [], current_bytesize, _needed_space) do
    {fifo_map, [], current_bytesize}
  end

  defp map_key(value) when is_list(value) do
    Enum.map(value, &map_key/1)
  end

  defp map_key(value) when is_map(value) do
    value
    |> Enum.map(fn {k, v} -> {map_key(k), map_key(v)} end)
    |> Map.new()
  end

  defp map_key(value)
       when is_binary(value) or is_atom(value) or is_integer(value) or is_float(value) or
              value == true or value == false or value == nil do
    value
  end

  defp map_key(value) do
    cond do
      function_exported?(value, :cache_key_with_version, 0) ->
        map_key(value.cache_key_with_version())

      function_exported?(value, :cache_key, 0) ->
        map_key(value.cache_key())

      true ->
        raise ArgumentError, "Invalid cache key: #{inspect(value.__struct__ || value.__MODULE__)}"
    end
  end
end
