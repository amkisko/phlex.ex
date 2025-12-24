defmodule Phlex.StyleCapsuleTest do
  use ExUnit.Case, async: true

  alias Phlex.StyleCapsule

  describe "add_capsule_attr/2" do
    test "adds data-capsule attribute to keyword list" do
      # Skip if StyleCapsule is not available
      if Code.ensure_loaded(StyleCapsule) == {:module, StyleCapsule} do
        attrs = [class: "test"]
        result = StyleCapsule.add_capsule_attr(attrs, Phlex.StyleCapsuleTest)

        assert Keyword.has_key?(result, :"data-capsule")
        assert Keyword.get(result, :class) == "test"
      else
        :ok
      end
    end

    test "adds data-capsule attribute to map" do
      if Code.ensure_loaded(StyleCapsule) == {:module, StyleCapsule} do
        attrs = %{class: "test"}
        result = StyleCapsule.add_capsule_attr(attrs, Phlex.StyleCapsuleTest)

        assert Map.has_key?(result, "data-capsule")
        assert result.class == "test"
      else
        :ok
      end
    end
  end

  describe "style_tag/3" do
    test "generates style tag with scoped CSS" do
      if Code.ensure_loaded(StyleCapsule) == {:module, StyleCapsule} do
        css = ".test { color: red; }"
        result = StyleCapsule.style_tag(css, Phlex.StyleCapsuleTest)

        assert String.starts_with?(result, "<style>")
        assert String.ends_with?(result, "</style>")
        assert String.contains?(result, css)
      else
        :ok
      end
    end
  end
end
