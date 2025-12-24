defmodule PhoenixDemoWeb.Components.TextFormattingDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    state
    |> p([], fn state ->
      state
      |> Phlex.SGML.append_text("Normal text with ")
      |> strong([], "bold")
      |> Phlex.SGML.append_text(", ")
      |> em([], "italic")
      |> Phlex.SGML.append_text(", and ")
      |> code([], "code")
    end)
    |> p([], fn state ->
      state
      |> Phlex.SGML.append_text("Small text: ")
      |> small([], "This is small")
    end)
    |> p([], fn state ->
      state
      |> Phlex.SGML.append_text("Subscript: H")
      |> sub([], "2")
      |> Phlex.SGML.append_text("O, Superscript: E=mc")
      |> sup([], "2")
    end)
  end
end

