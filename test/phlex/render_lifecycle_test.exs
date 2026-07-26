defmodule Phlex.RenderLifecycleTest do
  use ExUnit.Case, async: true

  alias Phlex.SGML.State

  defmodule Child do
    use Phlex.HTML

    def view_template(_assigns, state) do
      span(state, [], "child")
    end
  end

  defmodule Parent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      div(state, [class: "parent"], fn state ->
        render(state, Child)
      end)
    end
  end

  defmodule Hooked do
    use Phlex.HTML

    def before_template(_component, state) do
      append_text(state, "before:")
    end

    def around_template(_component, state, fun) do
      state
      |> append_text("around-start:")
      |> then(fun)
      |> append_text(":around-end")
    end

    def after_template(_component, state) do
      append_text(state, ":after")
    end

    def view_template(_assigns, state) do
      append_text(state, "body")
    end
  end

  defmodule Skipped do
    use Phlex.HTML

    def render?(_component, _state), do: false

    def view_template(_assigns, state) do
      append_text(state, "should-not-render")
    end
  end

  test "nested render shares parent buffer" do
    assert Parent.render() == ~s(<div class="parent"><span>child</span></div>)
  end

  test "render accepts component module with assigns" do
    state =
      State.new()
      |> Phlex.SGML.render(Child, assigns: %{})

    assert IO.iodata_to_binary(state.buffer) == "<span>child</span>"
  end

  test "render accepts binaries as plain text" do
    state = Phlex.SGML.render(State.new(), "<x>")
    assert IO.iodata_to_binary(state.buffer) == "&lt;x&gt;"
  end

  test "render accepts a list of renderables" do
    state = Phlex.SGML.render(State.new(), [Child, "!", Child])
    assert IO.iodata_to_binary(state.buffer) == "<span>child</span>!<span>child</span>"
  end

  test "render accepts a function" do
    state =
      Phlex.SGML.render(State.new(), fn state ->
        Phlex.SGML.append_text(state, "from-fun")
      end)

    assert IO.iodata_to_binary(state.buffer) == "from-fun"
  end

  test "lifecycle hooks run around view_template" do
    assert Hooked.render() == "before:around-start:body:around-end:after"
  end

  test "render? false skips view_template" do
    assert Skipped.render() == ""
  end
end
