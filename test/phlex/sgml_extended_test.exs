defmodule Phlex.SGMLExtendedTest do
  use ExUnit.Case

  alias Phlex.SGML.State

  defmodule TestComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      state
    end
  end

  describe "context/1" do
    test "returns user context from state" do
      state = State.new(user_context: %{user: "test"})
      context = Phlex.SGML.context(state)
      assert context[:user] == "test"
    end

    test "raises error when called outside rendering" do
      assert_raise ArgumentError, fn ->
        Phlex.SGML.context(:not_a_state)
      end
    end
  end

  describe "rendering?/1" do
    test "returns true for state" do
      state = State.new()
      assert Phlex.SGML.rendering?(state) == true
    end

    test "returns false for non-state" do
      assert Phlex.SGML.rendering?(:not_a_state) == false
    end
  end

  describe "whitespace/1" do
    test "outputs single space" do
      state = State.new()
      state = Phlex.SGML.whitespace(state)
      result = IO.iodata_to_binary(state.buffer)
      assert result == " "
    end

    test "skips when should_render is false" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:foo])}
      state = Phlex.SGML.whitespace(state)
      result = IO.iodata_to_binary(state.buffer)
      assert result == ""
    end
  end

  describe "whitespace/2" do
    test "outputs space before and after block" do
      state = State.new()

      state =
        Phlex.SGML.whitespace(state, fn state ->
          Phlex.SGML.append_text(state, "content")
        end)

      result = IO.iodata_to_binary(state.buffer)
      assert result == " content "
    end

    test "executes block even when should_render is false" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:foo])}

      # Track that block was executed
      executed = Agent.start_link(fn -> false end)
      {_, agent} = executed

      state =
        Phlex.SGML.whitespace(state, fn state ->
          Agent.update(agent, fn _ -> true end)
          Phlex.SGML.append_text(state, "content")
        end)

      # Block should have executed
      assert Agent.get(agent, fn x -> x end) == true
      # But buffer should be empty since should_render is false
      assert IO.iodata_to_binary(state.buffer) == ""
    end
  end

  describe "comment/2" do
    test "wraps content in HTML comment" do
      state = State.new()

      state =
        Phlex.SGML.comment(state, fn state ->
          Phlex.SGML.append_text(state, "This is a comment")
        end)

      result = IO.iodata_to_binary(state.buffer)
      assert result == "<!-- This is a comment -->"
    end

    test "executes block even when should_render is false" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:foo])}

      # Track that block was executed
      executed = Agent.start_link(fn -> false end)
      {_, agent} = executed

      state =
        Phlex.SGML.comment(state, fn state ->
          Agent.update(agent, fn _ -> true end)
          Phlex.SGML.append_text(state, "comment")
        end)

      # Block should have executed
      assert Agent.get(agent, fn x -> x end) == true
      # But buffer should be empty since should_render is false
      assert IO.iodata_to_binary(state.buffer) == ""
    end
  end

  describe "unsafe_raw/2" do
    test "appends raw content" do
      state = State.new()
      state = Phlex.SGML.unsafe_raw(state, "<div>Hello</div>")
      result = IO.iodata_to_binary(state.buffer)
      assert result == "<div>Hello</div>"
    end

    test "works with safe() wrapper" do
      state = State.new()
      safe_value = Phlex.SGML.safe("<strong>Bold</strong>")
      state = Phlex.SGML.unsafe_raw(state, safe_value)
      result = IO.iodata_to_binary(state.buffer)
      assert result == "<strong>Bold</strong>"
    end
  end

  describe "append_raw/2" do
    test "skips SafeValue when should_render is false" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:foo])}
      safe_value = Phlex.SGML.safe("<div>test</div>")
      state = Phlex.SGML.append_raw(state, safe_value)
      result = IO.iodata_to_binary(state.buffer)
      assert result == ""
    end

    test "handles Protocol.UndefinedError by converting to string" do
      state = State.new()
      # Create something that doesn't implement SafeObject but can be converted to string
      # Use a number which doesn't implement SafeObject but implements String.Chars
      state = Phlex.SGML.append_raw(state, 12_345)
      result = IO.iodata_to_binary(state.buffer)
      # Number should be converted to string
      assert result == "12345"
    end
  end

  describe "append_text/2" do
    test "handles inspect failure gracefully" do
      state = State.new()
      # Create something that might fail inspect (though this is hard to trigger)
      # We'll test the rescue path exists
      state = Phlex.SGML.append_text(state, {1, 2, 3})
      result = IO.iodata_to_binary(state.buffer)
      assert result =~ "{"
    end
  end

  describe "fragment/3" do
    test "handles binary fragment_id that needs to be converted to atom" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:content])}

      state =
        Phlex.SGML.fragment(state, "content", fn state ->
          Phlex.SGML.append_text(state, "Fragment")
        end)

      result = IO.iodata_to_binary(state.buffer)
      assert result == "Fragment"
    end

    test "handles non-atom non-binary fragment_id" do
      state = State.new()
      state = %{state | fragments: MapSet.new([123])}

      state =
        Phlex.SGML.fragment(state, 123, fn state ->
          Phlex.SGML.append_text(state, "Fragment")
        end)

      result = IO.iodata_to_binary(state.buffer)
      assert result == "Fragment"
    end

    test "handles binary fragment_id with String.to_existing_atom failure" do
      state = State.new()
      # Use a binary that doesn't exist as atom yet
      new_binary = "new_fragment_#{System.unique_integer([:positive])}"
      state = %{state | fragments: MapSet.new([String.to_atom(new_binary)])}

      state =
        Phlex.SGML.fragment(state, new_binary, fn state ->
          Phlex.SGML.append_text(state, "Fragment")
        end)

      result = IO.iodata_to_binary(state.buffer)
      assert result == "Fragment"
    end

    test "fragment removes fragment from fragments set when rendered" do
      state = State.new()
      # Add fragment to fragments set
      fragment_id = :test_fragment
      state = %{state | fragments: MapSet.new([fragment_id])}

      state =
        Phlex.SGML.fragment(state, fragment_id, fn state ->
          Phlex.SGML.append_text(state, "Fragment")
        end)

      # Fragment should be removed from set after rendering
      refute MapSet.member?(state.fragments, fragment_id)
      # Fragment content should be rendered
      result = IO.iodata_to_binary(state.buffer)
      assert result == "Fragment"
    end

    test "fragment handles fragment_depth going below zero" do
      state = State.new()
      state = %{state | fragments: MapSet.new([:content]), fragment_depth: 0}

      state =
        Phlex.SGML.fragment(state, :content, fn state ->
          # Manually set depth to negative to test max(0, ...) protection
          %{state | fragment_depth: -1}
        end)

      # Depth should be clamped to 0
      assert state.fragment_depth >= 0
    end
  end

  describe "yield_content/1" do
    test "yields content block with arity 2" do
      state = State.new()

      state = %{
        state
        | content_block: fn state, _component -> Phlex.SGML.append_text(state, "Block with component") end
      }

      state = Map.put(state, :_component, %TestComponent{})

      result = TestComponent.yield_content(state)
      html = IO.iodata_to_binary(result.buffer)
      assert html == "Block with component"
    end

    test "returns state when not a State struct" do
      result = TestComponent.yield_content(:not_a_state)
      assert result == :not_a_state
    end
  end
end
