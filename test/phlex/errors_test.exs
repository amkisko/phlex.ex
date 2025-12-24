defmodule Phlex.ErrorsTest do
  use ExUnit.Case

  describe "Phlex.ArgumentError" do
    test "can be raised with binary message" do
      assert_raise Phlex.ArgumentError, "Invalid argument", fn ->
        raise Phlex.ArgumentError, "Invalid argument"
      end
    end

    test "can be raised with list opts" do
      assert_raise Phlex.ArgumentError, "Custom error message", fn ->
        raise Phlex.ArgumentError, message: "Custom error message"
      end
    end

    test "uses default message when no message provided in opts" do
      error = Phlex.ArgumentError.exception([])
      assert error.message == "Invalid argument"
    end

    test "exception struct has message field" do
      error = Phlex.ArgumentError.exception("Test message")
      assert %Phlex.ArgumentError{message: "Test message"} = error
    end
  end

  describe "Phlex.DoubleRenderError" do
    test "can be raised with message in opts" do
      assert_raise Phlex.DoubleRenderError, "Test message", fn ->
        raise Phlex.DoubleRenderError, message: "Test message"
      end
    end

    test "can be raised with component in opts" do
      assert_raise Phlex.DoubleRenderError, ~r/You can't render a.*more than once/, fn ->
        raise Phlex.DoubleRenderError, component: "MyComponent"
      end
    end

    test "uses default message when component is nil" do
      error = Phlex.DoubleRenderError.exception(component: nil)
      assert error.message == "You can't render a nil more than once."
    end

    test "exception struct has message and component fields" do
      error = Phlex.DoubleRenderError.exception(message: "Test message", component: "MyComponent")
      assert %Phlex.DoubleRenderError{message: "Test message", component: "MyComponent"} = error
    end
  end

  describe "Phlex.RuntimeError" do
    test "can be raised with binary message" do
      assert_raise Phlex.RuntimeError, "Something went wrong", fn ->
        raise Phlex.RuntimeError, "Something went wrong"
      end
    end

    test "can be raised with list opts" do
      assert_raise Phlex.RuntimeError, "Custom runtime error", fn ->
        raise Phlex.RuntimeError, message: "Custom runtime error"
      end
    end

    test "uses default message when no message provided in opts" do
      error = Phlex.RuntimeError.exception([])
      assert error.message == "Runtime error"
    end

    test "exception struct has message field" do
      error = Phlex.RuntimeError.exception("Test message")
      assert %Phlex.RuntimeError{message: "Test message"} = error
    end
  end
end
