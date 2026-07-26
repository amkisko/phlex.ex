defmodule Phlex.KitTest do
  use ExUnit.Case, async: true

  defmodule Components do
    use Phlex.Kit

    defmodule Article do
      use Phlex.HTML

      def view_template(_assigns, state) do
        article(state, [], &yield_content/1)
      end
    end

    defmodule SayHi do
      use Phlex.HTML

      def view_template(assigns, state) do
        name = assigns._assigns.name
        times = Map.get(assigns._assigns, :times, 1)
        outer_content = state.content_block

        state
        |> Map.put(:content_block, fn state ->
          state =
            Enum.reduce(1..times, state, fn _, state ->
              h1(state, [], fn state ->
                Phlex.SGML.append_text(state, "Hi #{name}")
              end)
            end)

          if is_function(outer_content, 1), do: outer_content.(state), else: state
        end)
        |> then(&Components.article(&1, %{}))
      end
    end

    kit_component(Article)
    kit_component(SayHi)

    defmodule Foo do
      use Phlex.Kit

      defmodule Bar do
        use Phlex.HTML

        def view_template(_assigns, state) do
          h1(state, [], "Bar")
        end
      end

      kit_component(Bar)
    end
  end

  defmodule Example do
    use Phlex.HTML
    import Components

    def view_template(_assigns, state) do
      state
      |> say_hi(%{name: "Joel", times: 2},
        content_block: fn state ->
          Phlex.SGML.append_text(state, "Inside")
        end
      )
      |> Components.say_hi(%{name: "Will", times: 1},
        content_block: fn state ->
          Phlex.SGML.append_text(state, "Inside")
        end
      )
    end
  end

  defmodule NestedCaller do
    use Phlex.HTML

    def view_template(_assigns, state) do
      Components.Foo.bar(state)
    end
  end

  test "raises when you try to render a component outside of a rendering context" do
    assert_raise RuntimeError, "You can't call `SayHi' outside of a Phlex rendering context.", fn ->
      Components.say_hi(%{name: "Joel"})
    end
  end

  test "defines methods for its components" do
    assert Example.render() ==
             "<article><h1>Hi Joel</h1><h1>Hi Joel</h1>Inside</article><article><h1>Hi Will</h1>Inside</article>"
  end

  test "nested kits" do
    assert NestedCaller.render() == "<h1>Bar</h1>"
  end
end
