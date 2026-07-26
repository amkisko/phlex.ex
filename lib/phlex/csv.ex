defmodule Phlex.CSV do
  @moduledoc """
  Object-oriented CSV views aligned with Phlex Ruby 2.4.1.

  Subclass by `use Phlex.CSV` and implement `row_template/1` (or multi-arity via
  `around_row/1`). You must define `escape_csv_injection?/0` — there is no default.
  """

  @undefined :__phlex_csv_injection_undefined__

  @formula_prefix_bytes MapSet.new([?=, ?+, ?-, ?@, ?\t, ?\r])

  defmacro __using__(_opts) do
    quote do
      import Phlex.CSV, only: [column: 2]

      defstruct [:collection]

      def new(collection), do: %__MODULE__{collection: collection}

      def call(%__MODULE__{} = csv, opts \\ []) when is_list(opts) do
        Phlex.CSV.call(csv, __MODULE__, opts)
      end

      def content_type, do: "text/csv"
      def filename, do: nil
      def delimiter, do: ","

      def around_row(record) do
        row_template(record)
        Phlex.CSV.flush_row()
      end

      def render_headers?, do: true
      def trim_whitespace?, do: false
      def escape_csv_injection?, do: unquote(@undefined)

      defoverridable content_type: 0,
                     filename: 0,
                     delimiter: 0,
                     around_row: 1,
                     render_headers?: 0,
                     trim_whitespace?: 0,
                     escape_csv_injection?: 0
    end
  end

  @doc """
  Renders a CSV view into a binary (or into an iodata collector when provided).
  """
  def call(csv, view_module, opts \\ [])

  def call(%{collection: collection} = _csv, view_module, opts) when is_atom(view_module) and is_list(opts) do
    ensure_escape_csv_injection_configured!(view_module)

    delimiter = Keyword.get(opts, :delimiter, view_module.delimiter())
    buffer = Keyword.get(opts, :buffer, "")

    if not is_binary(delimiter) or byte_size(delimiter) != 1 do
      raise Phlex.ArgumentError, message: "Delimiter must be a single character"
    end

    strip_whitespace? = view_module.trim_whitespace?()
    escape_csv_injection? = view_module.escape_csv_injection?()
    render_headers? = view_module.render_headers?()
    escape_regex = escape_regex(delimiter, strip_whitespace?)

    context = %{
      buffer: buffer,
      delimiter: delimiter,
      strip_whitespace?: strip_whitespace?,
      escape_csv_injection?: escape_csv_injection?,
      escape_regex: escape_regex,
      render_headers?: render_headers?,
      headers: [],
      first_row?: true,
      row_buffer: [],
      view_module: view_module
    }

    Process.put(:phlex_csv_context, context)

    try do
      Enum.each(collection, fn record ->
        view_module.around_row(record)
      end)

      %{buffer: buffer} = Process.get(:phlex_csv_context)
      buffer
    after
      Process.delete(:phlex_csv_context)
    end
  end

  @doc """
  Appends a column to the current row. Only valid inside `row_template/1`.
  """
  def column(header, value) do
    context = Process.get(:phlex_csv_context)

    if is_nil(context) do
      raise Phlex.RuntimeError, message: "column/2 can only be called while rendering a Phlex.CSV view"
    end

    Process.put(:phlex_csv_context, %{context | row_buffer: context.row_buffer ++ [{header, value}]})
  end

  @doc false
  def flush_row do
    context = Process.get(:phlex_csv_context)
    context = append_row(context)
    Process.put(:phlex_csv_context, %{context | row_buffer: []})
  end

  defp append_row(%{row_buffer: row_buffer} = context) do
    context =
      if context.first_row? do
        headers = Enum.map(row_buffer, fn {header, _} -> header end)

        context =
          if context.render_headers? do
            buffer =
              headers
              |> Enum.with_index()
              |> Enum.reduce(context.buffer, fn {header, index}, buffer ->
                buffer = if index == 0, do: buffer, else: buffer <> context.delimiter
                buffer <> escape_value(header, context)
              end)

            %{context | buffer: buffer <> "\n", headers: headers, first_row?: false}
          else
            %{context | headers: headers, first_row?: false}
          end

        context
      else
        context
      end

    buffer =
      row_buffer
      |> Enum.with_index()
      |> Enum.reduce(context.buffer, fn {{header, value}, index}, buffer ->
        expected = Enum.at(context.headers, index)

        if expected != header do
          raise Phlex.RuntimeError,
            message: "Header mismatch at index #{index}: expected #{inspect(expected)}, got #{inspect(header)}."
        end

        buffer = if index == 0, do: buffer, else: buffer <> context.delimiter
        buffer <> escape_value(value, context)
      end)

    %{context | buffer: buffer <> "\n"}
  end

  defp escape_value(value, context) do
    value = stringify(value)

    if context.strip_whitespace? do
      value = String.trim(value)
      escape_stripped(value, context)
    else
      escape_raw(value, context)
    end
  end

  defp escape_stripped(value, %{escape_csv_injection?: true} = context) do
    cond do
      value == "" ->
        value

      formula_prefix?(value) ->
        quoted_with_injection_prefix(value)

      Regex.match?(context.escape_regex, value) ->
        quote_value(value)

      true ->
        value
    end
  end

  defp escape_stripped(value, _context), do: value

  defp escape_raw(value, %{escape_csv_injection?: true} = context) do
    cond do
      value == "" ->
        "\"\""

      formula_prefix?(value) ->
        quoted_with_injection_prefix(value)

      Regex.match?(context.escape_regex, value) ->
        quote_value(value)

      true ->
        value
    end
  end

  defp escape_raw(value, context) do
    cond do
      value == "" ->
        "\"\""

      Regex.match?(context.escape_regex, value) ->
        quote_value(value)

      true ->
        value
    end
  end

  defp quoted_with_injection_prefix(value) do
    "\"'" <> String.replace(value, "\"", "\"\"") <> "\""
  end

  defp quote_value(value) do
    "\"" <> String.replace(value, "\"", "\"\"") <> "\""
  end

  defp formula_prefix?(""), do: false

  defp formula_prefix?(value) do
    <<first, _rest::binary>> = value
    MapSet.member?(@formula_prefix_bytes, first)
  end

  defp stringify(nil), do: ""
  defp stringify(value) when is_binary(value), do: value
  defp stringify(value) when is_atom(value), do: Atom.to_string(value)
  defp stringify(value), do: to_string(value)

  defp escape_regex(delimiter, true) do
    {:ok, regex} = Regex.compile("[\\n\"#{Regex.escape(delimiter)}]")
    regex
  end

  defp escape_regex(delimiter, false) do
    {:ok, regex} = Regex.compile("^\\s|\\s$|[\\n\"#{Regex.escape(delimiter)}]")
    regex
  end

  defp ensure_escape_csv_injection_configured!(mod) do
    if mod.escape_csv_injection?() == @undefined do
      raise """
      You need to define `escape_csv_injection?/0` in #{inspect(mod)}.

      CSV injection is a security vulnerability where malicious spreadsheet
      formulae are used to execute code or exfiltrate data when a CSV is opened
      in a spreadsheet program such as Microsoft Excel or Google Sheets.

      For more information, see https://owasp.org/www-community/attacks/CSV_Injection

      If you’re sure this CSV will never be opened in a spreadsheet program,
      you can *disable* CSV injection escapes:

        def escape_csv_injection?, do: false

      This is useful when using CSVs for byte-for-byte data exchange between secure systems.

      Alternatively, you can *enable* CSV injection escapes at the cost of data integrity:

        def escape_csv_injection?, do: true

      Enabling the CSV injection escapes will prefix with a single quote `'` any
      values that start with: `=`, `+`, `-`, `@`, `\\t`, `\\r`

      Unfortunately, there is no one-size-fits-all solution to CSV injection.

      You need to decide based on your specific use case.
      """
    end
  end
end
