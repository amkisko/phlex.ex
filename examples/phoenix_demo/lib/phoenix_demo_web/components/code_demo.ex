defmodule PhoenixDemoWeb.Components.CodeDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    state
    |> p([], fn state ->
      state
      |> Phlex.SGML.append_text("Inline code: ")
      |> code([], "defmodule MyApp")
    end)
    |> pre([], fn state ->
      code(state, [], """
      def hello do
        IO.puts("Hello, World!")
      end
      """)
    end)
  end
end

