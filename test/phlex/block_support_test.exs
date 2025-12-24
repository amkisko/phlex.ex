defmodule Phlex.BlockSupportTest do
  use ExUnit.Case, async: true

  alias Phlex.SGML.State

  defmodule ComponentWithBlock do
    use Phlex.HTML

    def view_template(_assigns, state) do
      state
      |> div([], fn state ->
        if state.content_block do
          # yield_content is available via Phlex.SGML.__using__
          yield_content(state)
        else
          Phlex.SGML.append_text(state, "Default content")
        end
      end)
    end
  end

  describe "block support" do
    test "renders default content when no block provided" do
      html = ComponentWithBlock.render(%{})
      assert html =~ "Default content"
    end

    test "yield_content calls block function" do
      # Test yield_content directly with a block
      state =
        State.new(
          content_block: fn state ->
            Phlex.SGML.append_text(state, "Custom block content")
          end
        )

      result = ComponentWithBlock.yield_content(state)
      # The block should have been called and appended text
      assert result.buffer != []
      html = IO.iodata_to_binary(result.buffer)
      assert html =~ "Custom block content"
    end

    test "yields content block with arity 2" do
      state =
        State.new(
          content_block: fn state, _component ->
            Phlex.SGML.append_text(state, "Block with component")
          end
        )

      # Set component in state
      state = Map.put(state, :_component, %ComponentWithBlock{})

      result = ComponentWithBlock.yield_content(state)
      html = IO.iodata_to_binary(result.buffer)
      assert html =~ "Block with component"
    end

    test "yield_content returns state when no block" do
      state = State.new()
      result = ComponentWithBlock.yield_content(state)
      assert result == state
    end

    test "yield_content handles nil block" do
      state = %State{content_block: nil}
      result = ComponentWithBlock.yield_content(state)
      assert result == state
    end
  end
end
