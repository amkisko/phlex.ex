defmodule Phlex.SGMLTest do
  use ExUnit.Case

  alias Phlex.SGML.State

  doctest Phlex.SGML

  test "State creation and buffer management" do
    state = State.new()
    assert state.buffer == []
    assert state.should_render == true

    state = State.append_buffer(state, "test")
    result = IO.iodata_to_binary(state.buffer)
    assert byte_size(result) > 0
    assert result == "test"
  end

  test "should_render? works correctly" do
    state = State.new()
    assert State.should_render?(state) == true

    state = %{state | fragments: MapSet.new([:foo])}
    assert State.should_render?(state) == false

    state = %{state | fragment_depth: 1}
    assert State.should_render?(state) == true
  end

  test "append_text escapes HTML with binary" do
    state = State.new()
    state = Phlex.SGML.append_text(state, "<script>alert('xss')</script>")
    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "&lt;script&gt;"
    # Single quote is escaped as &#39;
    assert result =~ "&#39;"
  end

  test "append_text with atom" do
    state = State.new()
    state = Phlex.SGML.append_text(state, :test_atom)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "test_atom"
  end

  test "append_text with number" do
    state = State.new()
    state = Phlex.SGML.append_text(state, 123)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "123"
  end

  test "append_text with float" do
    state = State.new()
    state = Phlex.SGML.append_text(state, 123.45)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "123.45"
  end

  test "append_text with nil" do
    state = State.new()
    state = Phlex.SGML.append_text(state, nil)
    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "append_text with other type converts to string" do
    state = State.new()
    # Use a tuple which gets converted to string representation
    state = Phlex.SGML.append_text(state, {1, 2, 3})
    result = IO.iodata_to_binary(state.buffer)
    # Tuple converted to string
    assert result =~ "{"
    assert result =~ "1"
    assert result =~ "2"
    assert result =~ "3"
  end

  test "append_text skips when should_render is false" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:foo])}
    state = Phlex.SGML.append_text(state, "test")
    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "append_raw with binary" do
    state = State.new()
    state = Phlex.SGML.append_raw(state, "<script>alert('xss')</script>")
    result = IO.iodata_to_binary(state.buffer)
    assert result == "<script>alert('xss')</script>"
    refute result =~ "&lt;"
  end

  test "append_raw with other type converts to string" do
    state = State.new()
    state = Phlex.SGML.append_raw(state, 123)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "123"
  end

  test "render_component renders a component" do
    defmodule TestComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        Phlex.SGML.append_text(state, "Hello")
      end
    end

    state = State.new()
    state = Phlex.SGML.render_component(state, TestComponent, %{})
    result = IO.iodata_to_binary(state.buffer)
    assert result == "Hello"
  end

  test "render_component raises error for non-existent component" do
    state = State.new()

    assert_raise ArgumentError, ~r/does not implement render\/2/, fn ->
      Phlex.SGML.render_component(state, NonExistentModule, %{})
    end
  end

  test "append_attributes appends attributes" do
    state = State.new()
    state = Phlex.SGML.append_attributes(state, class: "foo", id: "bar")
    result = IO.iodata_to_binary(state.buffer)
    assert result =~ ~r/class="foo"/
    assert result =~ ~r/id="bar"/
  end

  test "append_attributes skips when should_render is false" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:foo])}
    state = Phlex.SGML.append_attributes(state, class: "foo")
    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "generate_attributes generates attribute string" do
    result = Phlex.SGML.generate_attributes(class: "foo", id: "bar")
    assert result =~ ~r/class="foo"/
    assert result =~ ~r/id="bar"/
  end

  test "capture captures output" do
    state = State.new()

    captured =
      Phlex.SGML.capture(state, fn state ->
        state
        |> Phlex.SGML.append_text("Hello")
        |> Phlex.SGML.append_text(" World")
      end)

    assert captured == "Hello World"
  end

  test "cache executes function" do
    state = State.new()

    state =
      Phlex.SGML.cache(state, [:test_key], fn state ->
        Phlex.SGML.append_text(state, "Cached content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == "Cached content"
  end

  test "low_level_cache executes function" do
    state = State.new()

    state =
      Phlex.SGML.low_level_cache(state, [:test_key], :cache_store, fn state ->
        Phlex.SGML.append_text(state, "Cached content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == "Cached content"
  end

  test "fragment renders when in fragments set" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:content])}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == "Fragment content"
  end

  test "fragment skips when not in fragments set" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:other])}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "fragment renders when fragments is nil" do
    state = State.new()
    state = %{state | fragments: nil}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == "Fragment content"
  end

  test "fragment with binary fragment_id" do
    state = State.new()
    state = %{state | fragments: MapSet.new(["content"])}

    state =
      Phlex.SGML.fragment(state, "content", fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == "Fragment content"
  end

  test "fragment removes itself from fragments set after rendering" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:content, :other])}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    # Fragment should be removed from set
    assert MapSet.size(state.fragments) == 1
    assert MapSet.member?(state.fragments, :other)
    refute MapSet.member?(state.fragments, :content)
  end

  test "fragment increments and decrements fragment_depth" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:content])}

    initial_depth = state.fragment_depth

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        # Inside fragment, depth should be incremented
        assert state.fragment_depth == initial_depth + 1
        state
      end)

    # After fragment, depth should be back to initial
    assert state.fragment_depth == initial_depth
  end

  test "fragment skips when fragments set is empty" do
    state = State.new()
    state = %{state | fragments: MapSet.new()}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Fragment content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "append_text with empty string" do
    state = State.new()
    state = Phlex.SGML.append_text(state, "")
    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "append_text with boolean true" do
    state = State.new()
    # Booleans should be converted to string
    state = Phlex.SGML.append_text(state, true)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "true"
  end

  test "append_text with boolean false" do
    state = State.new()
    state = Phlex.SGML.append_text(state, false)
    result = IO.iodata_to_binary(state.buffer)
    assert result == "false"
  end

  test "append_raw with empty string" do
    state = State.new()
    state = Phlex.SGML.append_raw(state, "")
    result = IO.iodata_to_binary(state.buffer)
    assert result == ""
  end

  test "append_raw with HTML content" do
    state = State.new()
    state = Phlex.SGML.append_raw(state, "<script>alert('test')</script>")
    result = IO.iodata_to_binary(state.buffer)
    assert result == "<script>alert('test')</script>"
  end

  test "fragment with matching fragment name" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:header])}

    state =
      Phlex.SGML.fragment(state, :header, fn state ->
        Phlex.SGML.append_text(state, "Header content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "Header content"
  end

  test "fragment with multiple matching fragments" do
    state = State.new()
    state = %{state | fragments: MapSet.new([:header, :footer])}

    state =
      Phlex.SGML.fragment(state, :header, fn state ->
        Phlex.SGML.append_text(state, "Header")
      end)

    state =
      Phlex.SGML.fragment(state, :footer, fn state ->
        Phlex.SGML.append_text(state, "Footer")
      end)

    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "Header"
    assert result =~ "Footer"
  end

  test "fragment with nil fragments" do
    state = State.new()
    state = %{state | fragments: nil}

    state =
      Phlex.SGML.fragment(state, :content, fn state ->
        Phlex.SGML.append_text(state, "Content")
      end)

    result = IO.iodata_to_binary(state.buffer)
    # When fragments is nil, all fragments are rendered
    assert result =~ "Content"
  end

  test "cache with function that returns value" do
    state = State.new()

    state =
      Phlex.SGML.cache(state, ["test_key"], fn state ->
        Phlex.SGML.append_text(state, "cached_value")
      end)

    # Cache should execute the function
    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "cached_value"
  end

  test "low_level_cache with function" do
    state = State.new()

    state =
      Phlex.SGML.low_level_cache(state, "test_key", :memory, fn state ->
        Phlex.SGML.append_text(state, "low_level_cached")
      end)

    # Cache should execute the function
    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "low_level_cached"
  end

  test "capture with function that returns content" do
    state = State.new(fragments: nil)

    captured =
      Phlex.SGML.capture(state, fn state ->
        # Ensure should_render? returns true by checking fragments
        state = Phlex.SGML.append_text(state, "Captured content")
        state
      end)

    assert captured =~ "Captured content"
  end

  test "capture with empty function" do
    state = State.new()

    captured =
      Phlex.SGML.capture(state, fn state ->
        state
      end)

    assert captured == ""
  end

  test "render_component with simple component" do
    defmodule SimpleTestComponent do
      use Phlex.HTML

      def view_template(_assigns, state) do
        div(state, [class: "test"], fn state ->
          Phlex.SGML.append_text(state, "Test")
        end)
      end
    end

    state = State.new()
    state = Phlex.SGML.render_component(state, SimpleTestComponent, %{})

    result = IO.iodata_to_binary(state.buffer)
    assert result =~ "<div"
    assert result =~ "Test"
  end

  test "render_component with assigns" do
    defmodule AssignsTestComponent do
      use Phlex.HTML

      def view_template(assigns, state) do
        div(state, [class: assigns._assigns.class], fn state ->
          Phlex.SGML.append_text(state, assigns._assigns.content)
        end)
      end
    end

    state = State.new()
    state = Phlex.SGML.render_component(state, AssignsTestComponent, %{class: "foo", content: "Bar"})

    result = IO.iodata_to_binary(state.buffer)
    assert result =~ ~r/class="foo"/
    assert result =~ "Bar"
  end
end
