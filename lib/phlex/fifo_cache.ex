defmodule Phlex.FIFOCache do
  @moduledoc """
  First-In-First-Out cache for attribute strings.

  Similar to phlex-ruby's FIFO cache, this provides a simple in-memory cache
  that evicts entries on a first-in-first-out basis when the maximum size is reached.

  ## Configuration

  The cache has configurable limits:
  - `max_bytesize`: Maximum total size of all cached values in bytes (default: 2_000_000 = ~2MB)
  - `max_value_bytesize`: Maximum size of a single cached value in bytes (default: 2_000_000)

  ## Examples

      cache = Phlex.FIFOCache.new(max_bytesize: 1_000_000)
      cached_value = Phlex.FIFOCache.fetch(cache, key, fn ->
        generate_attributes(attrs)
      end)
  """

  defstruct [
    :store,
    :max_bytesize,
    :max_value_bytesize,
    :bytesize
  ]

  @type t :: %__MODULE__{
          store: :ets.tid(),
          max_bytesize: non_neg_integer(),
          max_value_bytesize: non_neg_integer(),
          bytesize: non_neg_integer()
        }

  @default_max_bytesize 2_000_000
  @default_max_value_bytesize 2_000_000

  @doc """
  Creates a new FIFO cache.

  ## Options

    * `:max_bytesize` - Maximum total size of all cached values (default: 2_000_000)
    * `:max_value_bytesize` - Maximum size of a single cached value (default: 2_000_000)
  """
  def new(opts \\ []) do
    max_bytesize = Keyword.get(opts, :max_bytesize, @default_max_bytesize)
    max_value_bytesize = Keyword.get(opts, :max_value_bytesize, @default_max_value_bytesize)

    store = :ets.new(__MODULE__, [:ordered_set, :private])

    %__MODULE__{
      store: store,
      max_bytesize: max_bytesize,
      max_value_bytesize: max_value_bytesize,
      bytesize: 0
    }
  end

  @doc """
  Fetches a value from the cache, or computes it if not present.

  If the key exists in the cache, returns the cached value.
  Otherwise, calls the function to compute the value, caches it, and returns it.

  Values larger than `max_value_bytesize` are not cached.

  ## Examples

      cache = Phlex.FIFOCache.new()
      value = Phlex.FIFOCache.fetch(cache, {:attrs, [class: "foo"]}, fn ->
        generate_attributes([class: "foo"])
      end)
  """
  def fetch(%__MODULE__{} = cache, key, fun) when is_function(fun, 0) do
    case :ets.lookup(cache.store, key) do
      [{^key, value}] ->
        {value, cache}

      [] ->
        value = fun.()
        value_bytesize = byte_size(to_string(value))

        # Don't cache values that are too large
        updated_cache =
          if value_bytesize <= cache.max_value_bytesize do
            insert(cache, key, value, value_bytesize)
          else
            cache
          end

        {value, updated_cache}
    end
  end

  defp insert(%__MODULE__{} = cache, key, value, value_bytesize) do
    case :ets.lookup(cache.store, key) do
      [{^key, _}] ->
        cache

      [] ->
        # Insert new entry
        :ets.insert(cache.store, {key, value})
        new_bytesize = cache.bytesize + value_bytesize
        evict_if_needed(%{cache | bytesize: new_bytesize})
    end
  end

  defp evict_if_needed(%__MODULE__{bytesize: bytesize, max_bytesize: max_bytesize} = cache)
       when bytesize <= max_bytesize do
    cache
  end

  defp evict_if_needed(%__MODULE__{} = cache) do
    case :ets.first(cache.store) do
      :"$end_of_table" ->
        cache

      first_key ->
        case :ets.lookup(cache.store, first_key) do
          [{^first_key, value}] ->
            value_bytesize = byte_size(to_string(value))
            :ets.delete(cache.store, first_key)
            new_bytesize = cache.bytesize - value_bytesize
            evict_if_needed(%{cache | bytesize: new_bytesize})

          [] ->
            cache
        end
    end
  end

  @doc """
  Clears all entries from the cache.
  """
  def clear(%__MODULE__{store: store} = cache) do
    :ets.delete_all_objects(store)
    %{cache | bytesize: 0}
  end

  @doc """
  Returns the current size of the cache in bytes.
  """
  def bytesize(%__MODULE__{bytesize: bytesize}), do: bytesize

  @doc """
  Returns the number of entries in the cache.
  """
  def size(%__MODULE__{store: store}) do
    :ets.info(store, :size)
  end
end
