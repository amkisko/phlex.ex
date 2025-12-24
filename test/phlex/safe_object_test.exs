defmodule SafeObjectTest do
  use ExUnit.Case

  alias Phlex.SGML.{SafeObject, SafeValue, State}

  describe "SafeValue" do
    test "creates a SafeValue from a string" do
      safe_value = SafeValue.new("<strong>Hello</strong>")
      assert %SafeValue{content: "<strong>Hello</strong>"} = safe_value
    end

    test "raises error for non-string" do
      assert_raise ArgumentError, fn ->
        SafeValue.new(123)
      end
    end

    test "implements SafeObject protocol" do
      safe_value = SafeValue.new("<strong>Hello</strong>")
      result = SafeObject.to_safe_string(safe_value)
      assert result == "<strong>Hello</strong>"
    end
  end

  describe "safe/1" do
    test "creates SafeValue from string" do
      safe_value = Phlex.SGML.safe("<strong>Hello</strong>")
      assert %SafeValue{} = safe_value
      assert SafeObject.to_safe_string(safe_value) == "<strong>Hello</strong>"
    end

    test "raises error for non-string" do
      assert_raise ArgumentError, fn ->
        Phlex.SGML.safe(123)
      end
    end
  end

  describe "append_raw with SafeValue" do
    test "appends SafeValue content" do
      state = State.new()
      safe_value = Phlex.SGML.safe("<strong>Hello</strong>")
      state = Phlex.SGML.append_raw(state, safe_value)
      result = IO.iodata_to_binary(state.buffer)
      assert result == "<strong>Hello</strong>"
    end
  end
end
