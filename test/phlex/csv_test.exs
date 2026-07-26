defmodule Phlex.CSVTest.Product do
  defstruct [:name, :price]
end

defmodule Phlex.CSVTest do
  use ExUnit.Case, async: true

  alias Phlex.CSVTest.Product

  defmodule Base do
    use Phlex.CSV

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule UnescapedRaw do
    use Phlex.CSV
    def escape_csv_injection?, do: false
    def trim_whitespace?, do: false

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule UnescapedTrimmed do
    use Phlex.CSV
    def escape_csv_injection?, do: false
    def trim_whitespace?, do: true

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule EscapedRaw do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def trim_whitespace?, do: false

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule EscapedTrimmed do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def trim_whitespace?, do: true

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule NoHeaders do
    use Phlex.CSV
    def render_headers?, do: false
    def escape_csv_injection?, do: false

    def row_template(product) do
      column("name", product.name)
      column("price", product.price)
    end
  end

  defmodule CustomAround do
    use Phlex.CSV
    def escape_csv_injection?, do: true

    def around_row(item) do
      row_template(item.name, item.price)
      Phlex.CSV.flush_row()
    end

    def row_template(name, price) do
      column("Name", name)
      column("Price", price)
    end
  end

  defmodule DoubleAround do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def trim_whitespace?, do: false

    def around_row(item) do
      row_template(item.name, item.price)
      Phlex.CSV.flush_row()
      row_template(item.name, item.price)
      Phlex.CSV.flush_row()
    end

    def row_template(name, price) do
      column("Name", name)
      column("Price", price)
    end
  end

  defmodule SemicolonDelimiter do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def trim_whitespace?, do: true
    def delimiter, do: ";"

    def row_template(product) do
      column("Name", product.name)
      column("Price", product.price)
    end
  end

  defmodule ArgDelimiter do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def trim_whitespace?, do: true

    def row_template(product) do
      column("Name", product.name)
      column("Price", product.price)
    end
  end

  defmodule InvalidDelimiter do
    use Phlex.CSV
    def escape_csv_injection?, do: true
    def row_template(_product), do: :ok
  end

  @products [
    %Product{name: "Apple", price: 1.0},
    %Product{name: " Banana ", price: 2.0},
    %Product{name: :strawberry, price: "Three pounds"},
    %Product{name: "=SUM(A1:B1)", price: "=SUM(A1:B1)"},
    %Product{name: "Abc, \"def\"", price: "Foo\nbar \"baz\""},
    %Product{name: "", price: ""},
    %Product{name: nil, price: nil}
  ]

  defp csv(rows), do: Enum.join(rows, "\n") <> "\n"

  test "don’t escape csv injection or trim whitespace" do
    assert UnescapedRaw.new(@products) |> UnescapedRaw.call() ==
             csv([
               "name,price",
               "Apple,1.0",
               "\" Banana \",2.0",
               "strawberry,Three pounds",
               "=SUM(A1:B1),=SUM(A1:B1)",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"\",\"\"",
               "\"\",\"\""
             ])
  end

  test "don’t escape csv injection, but do trim whitespace" do
    assert UnescapedTrimmed.new(@products) |> UnescapedTrimmed.call() ==
             csv([
               "name,price",
               "Apple,1.0",
               "Banana,2.0",
               "strawberry,Three pounds",
               "=SUM(A1:B1),=SUM(A1:B1)",
               "Abc, \"def\",Foo\nbar \"baz\"",
               ",",
               ","
             ])
  end

  test "escape csv injection, but don’t trim whitespace" do
    assert EscapedRaw.new(@products) |> EscapedRaw.call() ==
             csv([
               "name,price",
               "Apple,1.0",
               "\" Banana \",2.0",
               "strawberry,Three pounds",
               "\"'=SUM(A1:B1)\",\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"\",\"\"",
               "\"\",\"\""
             ])
  end

  test "escape csv injection and trim whitespace" do
    assert EscapedTrimmed.new(@products) |> EscapedTrimmed.call() ==
             csv([
               "name,price",
               "Apple,1.0",
               "Banana,2.0",
               "strawberry,Three pounds",
               "\"'=SUM(A1:B1)\",\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               ",",
               ","
             ])
  end

  test "no headers" do
    assert NoHeaders.new(@products) |> NoHeaders.call() ==
             csv([
               "Apple,1.0",
               "\" Banana \",2.0",
               "strawberry,Three pounds",
               "=SUM(A1:B1),=SUM(A1:B1)",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"\",\"\"",
               "\"\",\"\""
             ])
  end

  test "with a custom around_row" do
    assert CustomAround.new(@products) |> CustomAround.call() ==
             csv([
               "Name,Price",
               "Apple,1.0",
               "\" Banana \",2.0",
               "strawberry,Three pounds",
               "\"'=SUM(A1:B1)\",\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"\",\"\"",
               "\"\",\"\""
             ])
  end

  test "with an around_row that flushes more than once" do
    assert DoubleAround.new(@products) |> DoubleAround.call() ==
             csv([
               "Name,Price",
               "Apple,1.0",
               "Apple,1.0",
               "\" Banana \",2.0",
               "\" Banana \",2.0",
               "strawberry,Three pounds",
               "strawberry,Three pounds",
               "\"'=SUM(A1:B1)\",\"'=SUM(A1:B1)\"",
               "\"'=SUM(A1:B1)\",\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"Abc, \"\"def\"\"\",\"Foo\nbar \"\"baz\"\"\"",
               "\"\",\"\"",
               "\"\",\"\"",
               "\"\",\"\"",
               "\"\",\"\""
             ])
  end

  test "with a custom delimiter defined as a method" do
    assert SemicolonDelimiter.new(@products) |> SemicolonDelimiter.call() ==
             csv([
               "Name;Price",
               "Apple;1.0",
               "Banana;2.0",
               "strawberry;Three pounds",
               "\"'=SUM(A1:B1)\";\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\";\"Foo\nbar \"\"baz\"\"\"",
               ";",
               ";"
             ])
  end

  test "with a custom delimiter passed in as an argument" do
    assert ArgDelimiter.new(@products) |> ArgDelimiter.call(delimiter: ";") ==
             csv([
               "Name;Price",
               "Apple;1.0",
               "Banana;2.0",
               "strawberry;Three pounds",
               "\"'=SUM(A1:B1)\";\"'=SUM(A1:B1)\"",
               "\"Abc, \"\"def\"\"\";\"Foo\nbar \"\"baz\"\"\"",
               ";",
               ";"
             ])
  end

  test "with an invalid custom delimiter" do
    assert_raise Phlex.ArgumentError, "Delimiter must be a single character", fn ->
      InvalidDelimiter.new([]) |> InvalidDelimiter.call(delimiter: "invalid")
    end
  end

  test "content type and filename defaults" do
    assert Base.content_type() == "text/csv"
    assert Base.filename() == nil
  end

  test "raises an error if there's no escape plan" do
    error =
      assert_raise RuntimeError, fn ->
        Base.new([]) |> Base.call()
      end

    assert error.message =~ "escape_csv_injection?"
  end
end
