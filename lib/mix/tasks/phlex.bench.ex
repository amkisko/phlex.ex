defmodule Mix.Tasks.Phlex.Bench do
  alias Phlex.SGML.Attributes

  @moduledoc """
  Run Phlex performance benchmarks.

  ## Examples

      mix phlex.bench
      mix phlex.bench html_rendering
      mix phlex.bench attributes
  """

  @compile {:no_warn_undefined, [Benchee, Benchee.Formatters.Console, Benchee.Formatters.HTML]}
  use Mix.Task

  @shortdoc "Run Phlex benchmarks"

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [] ->
        run_all_benchmarks()

      [benchmark] ->
        run_benchmark(benchmark)

      _ ->
        Mix.shell().error("Usage: mix phlex.bench [benchmark_name]")
        System.halt(1)
    end
  end

  defp run_all_benchmarks do
    benchmarks = ["html_rendering", "attributes"]

    Enum.each(benchmarks, fn benchmark ->
      Mix.shell().info("Running #{benchmark} benchmark...")
      run_benchmark(benchmark)
    end)
  end

  defp run_benchmark("html_rendering") do
    run_html_rendering_benchmark()
  end

  defp run_benchmark("attributes") do
    run_attributes_benchmark()
  end

  defp run_benchmark(name) do
    Mix.shell().error("Unknown benchmark: #{name}")
    Mix.shell().info("Available benchmarks: html_rendering, attributes")
    System.halt(1)
  end

  defp run_html_rendering_benchmark do
    defmodule SimpleComponent do
      @moduledoc false
      use Phlex.HTML

      def view_template(_assigns, state) do
        state
        |> div([class: "container"], fn state ->
          state
          |> h1([], fn state ->
            Phlex.SGML.append_text(state, "Hello, World!")
          end)
        end)
      end
    end

    defmodule ComplexComponent do
      @moduledoc false
      use Phlex.HTML

      def view_template(assigns, state) do
        assigns_map = Map.from_struct(assigns)
        id = Map.get(assigns_map, :id, 1)
        title = Map.get(assigns_map, :title, "")
        content = Map.get(assigns_map, :content, "")
        items = Map.get(assigns_map, :items, [])

        id_str = Integer.to_string(id)

        state
        |> div([class: "card", id: "card-1", data_id: id_str], fn state ->
          state
          |> header([class: "card-header"], fn state ->
            state
            |> h2([class: "title"], fn state ->
              Phlex.SGML.append_text(state, title)
            end)
          end)
          |> main([class: "card-body"], fn state ->
            state
            |> p([class: "content"], fn state ->
              Phlex.SGML.append_text(state, content)
            end)
            |> ul([class: "list"], fn state ->
              Enum.reduce(items, state, fn item, state ->
                state
                |> li([], fn state ->
                  Phlex.SGML.append_text(state, item)
                end)
              end)
            end)
          end)
          |> footer([class: "card-footer"], fn state ->
            state
            |> button([class: "btn", type: "button"], fn state ->
              Phlex.SGML.append_text(state, "Click me")
            end)
          end)
        end)
      end
    end

    if Code.ensure_loaded?(Benchee) do
      Benchee.run(
        %{
          "simple component" => fn ->
            SimpleComponent.render()
          end,
          "complex component" => fn ->
            ComplexComponent.render(%{
              id: 1,
              title: "Test Title",
              content: "Test content with some text",
              items: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
            })
          end
        },
        time: 5,
        memory_time: 2,
        formatters: [
          Benchee.Formatters.Console,
          {Benchee.Formatters.HTML, file: "benchmarks/output/html_rendering.html"}
        ]
      )
    else
      Mix.shell().error("Benchee is not available. Install it with: mix deps.get")
    end
  end

  defp run_attributes_benchmark do
    simple_attrs = [class: "foo", id: "bar", disabled: true]

    complex_attrs = [
      class: "container",
      id: "main",
      style: [color: "red", padding: "10px", margin: "20px"],
      data_foo: "bar",
      data_nested_baz: "qux",
      aria_label: "Main container",
      role: "main"
    ]

    if Code.ensure_loaded?(Benchee) do
      Benchee.run(
        %{
          "simple attributes" => fn ->
            Attributes.generate_attributes(simple_attrs)
          end,
          "complex attributes" => fn ->
            Attributes.generate_attributes(complex_attrs)
          end,
          "style map" => fn ->
            Attributes.generate_attributes(
              style: [color: "red", padding: "10px", margin: "20px", border: "1px solid black"]
            )
          end
        },
        time: 5,
        memory_time: 2,
        formatters: [
          Benchee.Formatters.Console,
          {Benchee.Formatters.HTML, file: "benchmarks/output/attributes.html"}
        ]
      )
    else
      Mix.shell().error("Benchee is not available. Install it with: mix deps.get")
    end
  end
end
