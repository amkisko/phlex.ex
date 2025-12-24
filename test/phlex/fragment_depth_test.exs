defmodule Phlex.FragmentDepthTest do
  use ExUnit.Case, async: true

  alias Phlex.SGML.State

  describe "fragment depth tracking" do
    test "begin_fragment increments depth" do
      state = State.new()
      assert state.fragment_depth == 0

      state = State.begin_fragment(state)
      assert state.fragment_depth == 1

      state = State.begin_fragment(state)
      assert state.fragment_depth == 2
    end

    test "end_fragment decrements depth" do
      state = State.new()
      state = State.begin_fragment(state)
      state = State.begin_fragment(state)
      assert state.fragment_depth == 2

      state = State.end_fragment(state)
      assert state.fragment_depth == 1

      state = State.end_fragment(state)
      assert state.fragment_depth == 0
    end

    test "end_fragment does not go below zero" do
      state = State.new()
      assert state.fragment_depth == 0

      state = State.end_fragment(state)
      assert state.fragment_depth == 0
    end

    test "should_render? respects fragment depth" do
      # No fragments - should render
      state = State.new()
      assert State.should_render?(state) == true

      # With fragments but depth > 0 - should render
      state = %{state | fragments: MapSet.new([:fragment1])}
      state = State.begin_fragment(state)
      assert State.should_render?(state) == true

      # With fragments and depth == 0 - should not render unless fragment is in set
      state = State.new(fragments: MapSet.new([:fragment1]))
      assert State.should_render?(state) == false

      # Fragment in set - should render
      state = State.begin_fragment(state)
      assert State.should_render?(state) == true
    end

    test "nested fragment tracking" do
      state = State.new(fragments: MapSet.new([:outer, :inner]))

      # Start outer fragment
      state = State.begin_fragment(state)
      assert state.fragment_depth == 1
      assert State.should_render?(state) == true

      # Start inner fragment
      state = State.begin_fragment(state)
      assert state.fragment_depth == 2
      assert State.should_render?(state) == true

      # End inner fragment
      state = State.end_fragment(state)
      assert state.fragment_depth == 1
      assert State.should_render?(state) == true

      # End outer fragment
      state = State.end_fragment(state)
      assert state.fragment_depth == 0
      assert State.should_render?(state) == false
    end
  end
end
