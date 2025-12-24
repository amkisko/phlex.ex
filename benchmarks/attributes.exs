# Benchmark attribute generation performance

Mix.install([
  {:phlex, path: Path.expand("../../", __DIR__)},
  {:benchee, "~> 1.0"}
])

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

Benchee.run(
  %{
    "simple attributes" => fn ->
      Phlex.SGML.Attributes.generate_attributes(simple_attrs)
    end,
    "complex attributes" => fn ->
      Phlex.SGML.Attributes.generate_attributes(complex_attrs)
    end,
    "style map" => fn ->
      Phlex.SGML.Attributes.generate_attributes([
        style: [color: "red", padding: "10px", margin: "20px", border: "1px solid black"]
      ])
    end
  },
  time: 5,
  memory_time: 2,
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.HTML, file: "benchmarks/output/attributes.html"}
  ]
)
