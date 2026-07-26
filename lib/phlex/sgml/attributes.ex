defmodule Phlex.SGML.Attributes do
  @moduledoc """
  Attribute generation and escaping for Phlex components.

  Handles attribute name normalization, value escaping, and security validation
  aligned with Phlex Ruby 2.4.1.
  """

  alias Phlex.SGML.SafeObject
  alias Phlex.SGML.SafeValue

  @unsafe_attributes MapSet.new(["srcdoc", "sandbox", "http-equiv"])
  @ref_attributes MapSet.new([
                    "href",
                    "src",
                    "action",
                    "formaction",
                    "lowsrc",
                    "dynsrc",
                    "background",
                    "ping",
                    "xlinkhref"
                  ])

  @named_character_references %{
    "colon" => ":",
    "tab" => "\t",
    "newline" => "\n"
  }

  @unsafe_attribute_name_chars ~r/[<>&"'\/=\s\x00]/

  @doc """
  Generates HTML attributes from a keyword list or map.

  ## Examples

      iex> Phlex.SGML.Attributes.generate_attributes([class: "foo", id: "bar"])
      " class=\\"foo\\" id=\\"bar\\""

      iex> Phlex.SGML.Attributes.generate_attributes([disabled: true])
      " disabled"

      iex> Phlex.SGML.Attributes.generate_attributes([style: [color: "red", padding: "10px"]])
      " style=\\"color: red; padding: 10px;\\""
  """
  def generate_attributes(attributes, buffer \\ "")

  def generate_attributes(attributes, buffer) when is_list(attributes) do
    buffer = normalize_attribute_buffer(buffer)

    if buffer == "" do
      Phlex.fetch_attributes(attributes, fn ->
        reduce_attributes(attributes, "")
      end)
    else
      reduce_attributes(attributes, buffer)
    end
  end

  def generate_attributes(attributes, buffer) when is_map(attributes) do
    attributes
    |> Enum.to_list()
    |> generate_attributes(buffer)
  end

  defp normalize_attribute_buffer(buffer) when is_binary(buffer), do: buffer
  defp normalize_attribute_buffer(buffer), do: IO.iodata_to_binary(List.wrap(buffer))

  defp reduce_attributes(attributes, buffer) do
    Enum.reduce(attributes, buffer, fn {key, value}, acc ->
      generate_attribute(key, value, acc)
    end)
  end

  @doc """
  Decodes HTML character references used to obfuscate javascript: URLs.
  """
  def decode_html_character_references(value) when is_binary(value) do
    value
    |> decode_hex_character_references()
    |> decode_decimal_character_references()
    |> decode_named_character_references()
  end

  defp generate_attribute(_key, nil, buffer), do: buffer
  defp generate_attribute(_key, false, buffer), do: buffer

  defp generate_attribute(key, value, buffer) do
    name = normalize_attribute_name(key)

    case serialize_attribute_value(key, name, value, buffer) do
      {:nested, nested_buffer} ->
        nested_buffer

      {:value, serialized} ->
        validate_attribute_name!(name, key)
        maybe_emit_attribute(key, name, value, serialized, buffer)
    end
  end

  defp serialize_attribute_value(key, name, value, buffer) do
    case value do
      true ->
        {:value, :boolean}

      %SafeValue{} = safe_value ->
        {:value, escape_attribute_value(SafeObject.to_safe_string(safe_value))}

      str when is_binary(str) ->
        {:value, escape_attribute_value(str)}

      atom when is_atom(atom) ->
        {:value, escape_attribute_value(String.replace(Atom.to_string(atom), "_", "-"))}

      num when is_number(num) ->
        {:value, to_string(num)}

      map when is_map(map) ->
        serialize_map_attribute(key, name, map, buffer)

      list when is_list(list) ->
        serialize_list_attribute(key, name, list, buffer)

      other ->
        if safe_object?(other) do
          {:value, escape_attribute_value(SafeObject.to_safe_string(other))}
        else
          raise ArgumentError, "Invalid attribute value for #{inspect(key)}: #{inspect(other)}"
        end
    end
  end

  defp serialize_map_attribute(:style, _name, map, _buffer) do
    {:value, escape_attribute_value(generate_styles(map))}
  end

  defp serialize_map_attribute(_key, name, map, buffer) do
    {:nested, generate_nested_attributes(map, "#{name}-", buffer)}
  end

  defp serialize_list_attribute(:style, _name, list, _buffer) do
    styles =
      if Keyword.keyword?(list) do
        generate_styles_from_pairs(list)
      else
        generate_styles(list)
      end

    {:value, escape_attribute_value(styles)}
  end

  defp serialize_list_attribute(_key, name, list, buffer) do
    if Keyword.keyword?(list) do
      {:nested, generate_nested_attributes(list, "#{name}-", buffer)}
    else
      case generate_nested_tokens(list) do
        nil -> {:nested, buffer}
        tokens -> {:value, tokens}
      end
    end
  end

  defp maybe_emit_attribute(key, name, original_value, serialized, buffer) do
    if skip_ref_javascript?(name, original_value, serialized) do
      buffer
    else
      unless safe_object?(original_value) do
        validate_attribute_security!(name, key)
      end

      validate_attribute_name!(name, key)
      validate_id_key!(key, name)

      case serialized do
        :boolean -> buffer <> " " <> name
        str when is_binary(str) -> buffer <> " " <> name <> "=\"" <> str <> "\""
      end
    end
  end

  defp skip_ref_javascript?(name, original_value, serialized) do
    if safe_object?(original_value) do
      false
    else
      normalized = normalize_security_name(name)

      MapSet.member?(@ref_attributes, normalized) and is_binary(serialized) and
        javascript_url?(serialized)
    end
  end

  defp javascript_url?(value) do
    value
    |> decode_html_character_references()
    |> String.downcase()
    |> String.replace(~r/[^a-z:]/, "")
    |> String.starts_with?("javascript:")
  end

  defp normalize_attribute_name(key) when is_binary(key), do: key

  defp normalize_attribute_name(key) when is_atom(key) do
    String.replace(Atom.to_string(key), "_", "-")
  end

  defp normalize_attribute_name(key) do
    raise ArgumentError, "Attribute keys should be Strings or Symbols, got: #{inspect(key)}"
  end

  defp validate_attribute_name!(name, key) do
    if Regex.match?(@unsafe_attribute_name_chars, name) do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(key)}"
    end
  end

  defp validate_attribute_security!(name, key) do
    normalized = normalize_security_name(name)

    if MapSet.member?(@unsafe_attributes, normalized) do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(key)}"
    end

    if byte_size(normalized) > 2 and String.starts_with?(normalized, "on") and
         not String.contains?(normalized, "-") do
      raise ArgumentError, "Unsafe attribute name detected: #{inspect(key)}"
    end

    :ok
  end

  defp validate_id_key!(key, name) do
    if String.downcase(name) == "id" and key != :id do
      raise ArgumentError, ":id attribute should only be passed as a lowercase symbol"
    end
  end

  defp normalize_security_name(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z-]/, "")
  end

  defp escape_attribute_value(value) when is_binary(value) do
    String.replace(value, "\"", "&quot;")
  end

  defp generate_nested_attributes(attributes, base_name, buffer) when is_map(attributes) do
    attributes
    |> Enum.to_list()
    |> generate_nested_attributes(base_name, buffer)
  end

  defp generate_nested_attributes(attributes, base_name, buffer) when is_list(attributes) do
    Enum.reduce(attributes, buffer, fn {key, value}, acc ->
      generate_nested_attribute(key, value, base_name, acc)
    end)
  end

  defp generate_nested_attribute(_key, nil, _base_name, buffer), do: buffer
  defp generate_nested_attribute(_key, false, _base_name, buffer), do: buffer

  defp generate_nested_attribute(key, value, base_name, buffer) do
    {name, final_base} =
      case key do
        :_ ->
          {"", String.replace_suffix(base_name, "-", "")}

        _ ->
          nested_name = normalize_attribute_name(key)
          validate_attribute_name!(nested_name, key)
          {nested_name, base_name}
      end

    case value do
      true ->
        buffer <> " " <> final_base <> name

      str when is_binary(str) ->
        buffer <> " " <> final_base <> name <> "=\"" <> escape_attribute_value(str) <> "\""

      atom when is_atom(atom) ->
        atom_value = String.replace(Atom.to_string(atom), "_", "-")
        buffer <> " " <> final_base <> name <> "=\"" <> escape_attribute_value(atom_value) <> "\""

      num when is_number(num) ->
        buffer <> " " <> final_base <> name <> "=\"" <> to_string(num) <> "\""

      map when is_map(map) ->
        generate_nested_attributes(map, "#{final_base}#{name}-", buffer)

      list when is_list(list) ->
        if Keyword.keyword?(list) do
          generate_nested_attributes(list, "#{final_base}#{name}-", buffer)
        else
          case generate_nested_tokens(list) do
            nil -> buffer
            tokens -> buffer <> " " <> final_base <> name <> "=\"" <> tokens <> "\""
          end
        end

      other ->
        if safe_object?(other) do
          safe = escape_attribute_value(SafeObject.to_safe_string(other))
          buffer <> " " <> final_base <> name <> "=\"" <> safe <> "\""
        else
          raise ArgumentError, "Invalid attribute value #{inspect(other)}"
        end
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
        %SafeValue{} = safe -> SafeObject.to_safe_string(safe)
        nil -> nil
        false -> nil
        other -> raise ArgumentError, "Invalid token type: #{inspect(other)}"
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join(sep)

    if result == "", do: nil, else: escape_attribute_value(result)
  end

  defp generate_styles(styles) when is_list(styles) do
    styles
    |> Enum.map(fn
      str when is_binary(str) ->
        if str == "" or String.ends_with?(str, ";"), do: str, else: "#{str};"

      %SafeValue{} = safe ->
        value = SafeObject.to_safe_string(safe)
        if String.ends_with?(value, ";"), do: value, else: "#{value};"

      map when is_map(map) ->
        generate_styles(map)

      nil ->
        nil

      other ->
        raise ArgumentError, "Invalid style: #{inspect(other)}"
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp generate_styles(styles) when is_map(styles) do
    styles
    |> Enum.to_list()
    |> generate_styles_from_pairs()
  end

  defp generate_styles_from_pairs(pairs) when is_list(pairs) do
    pairs
    |> Enum.map(fn {key, value} ->
      prop = normalize_attribute_name(key)

      rendered =
        case value do
          str when is_binary(str) -> str
          atom when is_atom(atom) -> String.replace(Atom.to_string(atom), "_", "-")
          num when is_number(num) -> to_string(num)
          %SafeValue{} = safe -> SafeObject.to_safe_string(safe)
          nil -> nil
          other -> raise ArgumentError, "Invalid style value: #{inspect(other)}"
        end

      if rendered, do: "#{prop}: #{rendered};", else: nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp safe_object?(value) do
    case SafeObject.to_safe_string(value) do
      _ -> true
    end
  rescue
    Protocol.UndefinedError -> false
  end

  defp decode_hex_character_references(value) do
    Regex.replace(~r/&#x([0-9a-f]+);?/i, value, fn _, hex ->
      with {codepoint, ""} <- Integer.parse(hex, 16),
           {:ok, char} <- codepoint_to_string(codepoint) do
        char
      else
        _ -> ""
      end
    end)
  end

  defp decode_decimal_character_references(value) do
    Regex.replace(~r/&#(\d+);?/, value, fn _, digits ->
      with {codepoint, ""} <- Integer.parse(digits),
           {:ok, char} <- codepoint_to_string(codepoint) do
        char
      else
        _ -> ""
      end
    end)
  end

  defp codepoint_to_string(codepoint) when is_integer(codepoint) and codepoint >= 0 do
    {:ok, <<codepoint::utf8>>}
  rescue
    ArgumentError -> :error
  end

  defp decode_named_character_references(value) do
    Regex.replace(~r/&([a-z][a-z0-9]+);?/i, value, fn _, name ->
      Map.get(@named_character_references, String.downcase(name), "")
    end)
  end
end
