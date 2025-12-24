defmodule Phlex.PhoenixTest do
  use ExUnit.Case, async: true

  alias Phlex.Phoenix

  describe "to_rendered/2" do
    test "converts HTML string to Phoenix.LiveView.Rendered struct" do
      html = "<div>Hello, World!</div>"
      rendered = Phoenix.to_rendered(html)

      # Check that it's a struct with the expected fields
      assert is_map(rendered)
      assert Map.has_key?(rendered, :__struct__)
      assert rendered.static == ["", ""]
      assert rendered.root == false
      assert rendered.fingerprint == 0
      assert is_function(rendered.dynamic, 1)
      assert rendered.dynamic.(false) == [html]
    end

    test "accepts fingerprint option" do
      html = "<div>Test</div>"
      rendered = Phoenix.to_rendered(html, fingerprint: 123)

      assert rendered.fingerprint == 123
    end

    test "accepts root option" do
      html = "<div>Test</div>"
      rendered = Phoenix.to_rendered(html, root: true)

      assert rendered.root == true
    end

    test "returns iodata in dynamic function" do
      html = "<div>Test</div>"
      rendered = Phoenix.to_rendered(html)

      result = rendered.dynamic.(false)
      assert is_list(result)
      assert result == [html]
    end
  end
end
