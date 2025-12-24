defmodule Phlex.SGML.Attributes do
  @moduledoc """
  Attribute generation and escaping for Phlex components.

  Handles attribute name normalization, value escaping, and security validation.
  """

  @unsafe_attributes MapSet.new(["srcdoc", "sandbox", "http-equiv"])
  @ref_attributes MapSet.new(["href", "src", "action", "formaction", "lowsrc", "dynsrc", "background", "ping"])

  @doc """
  Generates HTML attributes from a keyword list or map.

  Uses caching for performance optimization when the same attributes are reused.

  ## Examples

      iex> Phlex.SGML.Attributes.generate_attributes([class: "foo", id: "bar"])
      " class=\\"foo\\" id=\\"bar\\""

      iex> Phlex.SGML.Attributes.generate_attributes([disabled: true])
      " disabled"

      iex> Phlex.SGML.Attributes.generate_attributes([style: [color: "red", padding: "10px"]])
      " style=\\"color: red; padding: 10px;\\""
  """
  def generate_attributes(attributes, buffer \\ [])

  def generate_attributes(attributes, buffer) when is_list(attributes) do
    # Use cache for common attribute patterns via Phlex.fetch_attributes
    Phlex.fetch_attributes(attributes, fn ->
      Enum.reduce(attributes, buffer, fn {k, v}, acc ->
        generate_attribute(k, v, acc)
      end)
      |> IO.iodata_to_binary()
    end)
  end

  def generate_attributes(attributes, buffer) when is_map(attributes) do
    attributes
    |> Enum.to_list()
    |> generate_attributes(buffer)
  end

  defp generate_attribute(_k, nil, buffer), do: buffer

  defp generate_attribute(k, v, buffer) do
    name = normalize_attribute_name(k)
    validate_attribute_name(name, k)

    value =
      case v do
        true ->
          :boolean

        str when is_binary(str) ->
          escape_attribute_value(str)

        atom when is_atom(atom) ->
          escape_attribute_value(Atom.to_string(atom))

        num when is_number(num) ->
          to_string(num)

        map when is_map(map) ->
          case k do
            :style ->
              generate_styles(map) |> escape_attribute_value()

            _ ->
              generate_nested_attributes(map, "#{name}-", [])
              |> IO.iodata_to_binary()
              |> escape_attribute_value()
          end

        list when is_list(list) ->
          case k do
            :style ->
              if Keyword.keyword?(list) do
                generate_styles(Map.new(list)) |> escape_attribute_value()
              else
                generate_styles(list) |> escape_attribute_value()
              end

            _ ->
              if Keyword.keyword?(list) do
                generate_nested_attributes(Map.new(list), "#{name}-", [])
                |> IO.iodata_to_binary()
                |> escape_attribute_value()
              else
                generate_nested_tokens(list)
                |> escape_attribute_value()
              end
          end

        _ ->
          raise ArgumentError, "Invalid attribute value for #{k}: #{inspect(v)}"
      end

    validate_attribute_security(name, k, value)

    case value do
      :boolean ->
        [buffer | [" ", name]]

      str when is_binary(str) ->
        [buffer | [" ", name, "=\"", str, "\""]]
    end
  end

  defp normalize_attribute_name(k) when is_binary(k), do: k
  defp normalize_attribute_name(k) when is_atom(k), do: String.replace(Atom.to_string(k), "_", "-")

  defp validate_attribute_name(name, k) do
    if String.contains?(name, ["<", ">", "&", "\"", "'"]) do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(k)}"
    end
  end

  defp validate_attribute_security(lower_name, k, value) do
    normalized = String.downcase(lower_name) |> String.replace(~r/[^a-z-]/, "")

    if MapSet.member?(@unsafe_attributes, normalized) do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(k)}"
    end

    if String.length(normalized) > 2 and String.starts_with?(normalized, "on") and
         not String.contains?(normalized, "-") do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(k)}"
    end

    if MapSet.member?(@ref_attributes, normalized) and is_binary(value) do
      normalized_value = String.downcase(value) |> String.replace(~r/[^a-z:]/, "")

      if String.starts_with?(normalized_value, "javascript:") do
        :ok
      end
    end

    :ok
  end

  defp escape_attribute_value(value) when is_binary(value) do
    value
    |> String.replace("\"", "&quot;")
  end

  defp escape_attribute_value(value), do: value

  defp generate_nested_attributes(attributes, base_name, buffer) when is_map(attributes) do
    Enum.reduce(attributes, buffer, fn {k, v}, acc ->
      generate_nested_attribute(k, v, base_name, acc)
    end)
  end

  defp generate_nested_attribute(_k, nil, _base_name, buffer), do: buffer

  defp generate_nested_attribute(k, v, base_name, buffer) do
    {name, final_base} =
      case k do
        :_ ->
          {"", String.replace_suffix(base_name, "-", "")}

        _ ->
          name = normalize_attribute_name(k)

          if String.contains?(name, ["<", ">", "&", "\"", "'"]) do
            raise ArgumentError, "Unsafe attribute name detected: #{inspect(k)}"
          end

          {name, base_name}
      end

    value =
      case v do
        true ->
          :boolean

        str when is_binary(str) ->
          escape_attribute_value(str)

        atom when is_atom(atom) ->
          escape_attribute_value(String.replace(Atom.to_string(atom), "_", "-"))

        num when is_number(num) ->
          to_string(num)

        map when is_map(map) ->
          generate_nested_attributes(map, "#{final_base}#{name}-", [])
          |> IO.iodata_to_binary()
          |> escape_attribute_value()

        list when is_list(list) ->
          if Keyword.keyword?(list) do
            generate_nested_attributes(Map.new(list), "#{final_base}#{name}-", [])
            |> IO.iodata_to_binary()
            |> escape_attribute_value()
          else
            case generate_nested_tokens(list) do
              nil -> nil
              tokens -> escape_attribute_value(tokens)
            end
          end

        _ ->
          raise ArgumentError, "Invalid attribute value #{inspect(v)}"
      end

    case value do
      nil ->
        buffer

      :boolean ->
        [buffer | [" ", final_base, name]]

      str when is_binary(str) ->
        [buffer | [" ", final_base, name, "=\"", str, "\""]]
    end
  end

  defp generate_nested_tokens(tokens, sep \\ " ") do
    result =
      tokens
      |> Enum.map(fn
        str when is_binary(str) -> str
        atom when is_atom(atom) -> String.replace(Atom.to_string(atom), "_", "-")
        num when is_number(num) -> to_string(num)
        list when is_list(list) -> generate_nested_tokens(list, sep)
        nil -> nil
        other -> raise ArgumentError, "Invalid token type: #{inspect(other)}"
      end)
      |> Enum.filter(&(&1 != nil))
      |> Enum.join(sep)

    if result == "", do: nil, else: escape_attribute_value(result)
  end

  defp generate_styles(styles) when is_list(styles) do
    styles
    |> Enum.map(fn
      str when is_binary(str) ->
        if str == "" or String.ends_with?(str, ";"), do: str, else: "#{str};"

      map when is_map(map) ->
        generate_styles(map)

      nil ->
        nil

      other ->
        raise ArgumentError, "Invalid style: #{inspect(other)}"
    end)
    |> Enum.filter(&(&1 != nil))
    |> Enum.join(" ")
  end

  defp generate_styles(styles) when is_map(styles) do
    styles
    |> Enum.map(fn {k, v} ->
      prop = normalize_attribute_name(k)

      value =
        case v do
          str when is_binary(str) -> str
          atom when is_atom(atom) -> String.replace(Atom.to_string(atom), "_", "-")
          num when is_number(num) -> to_string(num)
          nil -> nil
          other -> raise ArgumentError, "Invalid style value: #{inspect(other)}"
        end

      if value, do: "#{prop}: #{value};", else: nil
    end)
    |> Enum.filter(&(&1 != nil))
    |> Enum.join(" ")
  end
end
