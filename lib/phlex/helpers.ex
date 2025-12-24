defmodule Phlex.Helpers do
  @moduledoc """
  Helper functions and macros for Phlex components.

  This module provides convenience macros and functions to make
  component definition easier and more idiomatic.
  """

  @doc """
  Escapes HTML entities in a string.
  """
  def escape_html(string) when is_binary(string) do
    {:safe, escaped} = Phoenix.HTML.html_escape(string)
    escaped
  end

  def escape_html(atom) when is_atom(atom) do
    {:safe, escaped} = Phoenix.HTML.html_escape(Atom.to_string(atom))
    escaped
  end

  def escape_html(other) do
    {:safe, escaped} = Phoenix.HTML.html_escape(to_string(other))
    escaped
  end

  @doc """
  Macro to define a component with a simpler API.

  ## Example

      defcomponent Card do
        def view_template(assigns, state) do
          state
          |> div([class: "card"], fn state ->
            Phlex.SGML.append_text(state, assigns.title)
          end)
        end
      end

  This is equivalent to:

      defmodule Card do
        use Phlex.HTML

        def view_template(assigns, state) do
          # ...
        end
      end
  """
  defmacro defcomponent(name, do: block) do
    quote do
      defmodule unquote(name) do
        use Phlex.HTML

        unquote(block)
      end
    end
  end

  @doc """
  Macro to define an SVG component with a simpler API.
  """
  defmacro defsvg_component(name, do: block) do
    quote do
      defmodule unquote(name) do
        use Phlex.SVG

        unquote(block)
      end
    end
  end

  @doc """
  Merges attributes intelligently, handling arrays, sets, hashes, and strings.

  ## Example

      mix([class: "foo"], [class: "bar"])
      # => [class: "foo bar"]

      mix([class: ["a", "b"]], [class: ["c"]])
      # => [class: ["a", "b", "c"]]
  """
  def mix(attrs1, attrs2) when is_list(attrs1) and is_list(attrs2) do
    Keyword.merge(attrs1, attrs2, fn
      _key, val1, val2 when is_list(val1) and is_list(val2) ->
        val1 ++ val2

      _key, val1, val2 when is_binary(val1) and is_binary(val2) ->
        "#{val1} #{val2}"

      _key, val1, val2 when is_map(val1) and is_map(val2) ->
        Map.merge(val1, val2, fn _k, v1, v2 -> mix([v1], [v2]) end)

      _key, _val1, val2 ->
        val2
    end)
  end

  def mix(attrs1, attrs2) when is_map(attrs1) and is_map(attrs2) do
    Map.merge(attrs1, attrs2, fn
      _key, val1, val2 when is_list(val1) and is_list(val2) ->
        val1 ++ val2

      _key, val1, val2 when is_binary(val1) and is_binary(val2) ->
        "#{val1} #{val2}"

      _key, val1, val2 when is_map(val1) and is_map(val2) ->
        mix(val1, val2)

      _key, _val1, val2 ->
        val2
    end)
  end

  def mix(attrs1, attrs2) do
    # Convert to lists and merge
    list1 = if is_map(attrs1), do: Map.to_list(attrs1), else: attrs1
    list2 = if is_map(attrs2), do: Map.to_list(attrs2), else: attrs2
    mix(list1, list2)
  end

  @doc """
  Extracts bindings from keyword list or map.

  ## Example

      grab(foo: foo, bar: bar)
      # => {foo, bar} if multiple, or single value if one
  """
  def grab(bindings) when is_list(bindings) or is_map(bindings) do
    values = if is_list(bindings), do: Keyword.values(bindings), else: Map.values(bindings)

    case length(values) do
      1 -> List.first(values)
      _ -> List.to_tuple(values)
    end
  end
end
