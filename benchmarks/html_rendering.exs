# Benchmark HTML rendering performance

Mix.install([
  {:phlex, path: Path.expand("../../", __DIR__)},
  {:benchee, "~> 1.0"}
])

defmodule SimpleComponent do
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
  use Phlex.HTML

  def view_template(assigns, state) do
    state
    |> div([class: "card", id: "card-1", data_id: assigns.id], fn state ->
      state
      |> header([class: "card-header"], fn state ->
        state
        |> h2([class: "title"], fn state ->
          Phlex.SGML.append_text(state, assigns.title)
        end)
      end)
      |> main([class: "card-body"], fn state ->
        state
        |> p([class: "content"], fn state ->
          Phlex.SGML.append_text(state, assigns.content)
        end)
        |> ul([class: "list"], fn state ->
          Enum.reduce(assigns.items, state, fn item, state ->
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

Benchee.run(
  %{
    "simple component" => fn ->
      SimpleComponent.render()
    end,
    "complex component" => fn ->
      ComplexComponent.render(
        id: 1,
        title: "Test Title",
        content: "Test content with some text",
        items: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
      )
    end,
    "nested components" => fn ->
      defmodule NestedComponent do
        use Phlex.HTML

        def view_template(_assigns, state) do
          state
          |> div([], fn state ->
            Enum.reduce(1..10, state, fn i, state ->
              state
              |> SimpleComponent.render()
            end)
          end)
        end
      end

      NestedComponent.render()
    end
  },
  time: 5,
  memory_time: 2,
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.HTML, file: "benchmarks/output/html_rendering.html"}
  ]
)
