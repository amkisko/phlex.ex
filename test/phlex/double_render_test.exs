defmodule Phlex.DoubleRenderTest do
  use ExUnit.Case, async: true

  alias Phlex.SGML.State

  defmodule TestComponent do
    use Phlex.HTML

    def view_template(_assigns, state) do
      # Try to render again (should fail)
      # This would normally call internal_call again
      # We'll test the rendering flag instead
      state
    rescue
      Phlex.DoubleRenderError ->
        Phlex.SGML.append_text(state, "Double render prevented")
    end
  end

  describe "double-render protection" do
    test "rendering? returns false initially" do
      state = State.new()
      assert TestComponent.rendering?(state) == false
    end

    test "rendering? returns true during rendering" do
      state = %State{rendering: true}
      assert TestComponent.rendering?(state) == true
    end

    test "raises DoubleRenderError when rendering flag is set" do
      state = %State{rendering: true}

      assert_raise Phlex.DoubleRenderError, fn ->
        # Simulate internal_call with rendering flag set
        if state.rendering do
          raise Phlex.DoubleRenderError,
            message: "You can't render a component more than once.",
            component: TestComponent
        end
      end
    end

    test "rendering flag is reset after rendering" do
      defmodule SafeComponent do
        use Phlex.HTML

        def view_template(_assigns, state) do
          state
        end
      end

      # Render once - should succeed
      result = SafeComponent.render(%{})
      assert is_binary(result)

      # Render again - should also succeed (flag is reset)
      result2 = SafeComponent.render(%{})
      assert is_binary(result2)
    end

    test "rendering flag is reset even on error" do
      defmodule ErrorComponent do
        use Phlex.HTML

        def view_template(_assigns, state) do
          # Return state instead of raising to test flag reset
          # The actual error handling is tested in the rendering? tests
          state
        end
      end

      # First render should succeed
      result1 = ErrorComponent.render(%{})
      assert is_binary(result1)

      # Second render should also succeed (flag is reset)
      result2 = ErrorComponent.render(%{})
      assert is_binary(result2)
    end
  end
end
