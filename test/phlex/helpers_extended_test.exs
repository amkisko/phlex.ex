defmodule Phlex.HelpersExtendedTest do
  use ExUnit.Case

  describe "mix/2" do
    test "merges simple attributes" do
      result = Phlex.Helpers.mix([class: "foo"], id: "bar")
      assert result[:class] == "foo"
      assert result[:id] == "bar"
    end

    test "merges string attributes by concatenating" do
      result = Phlex.Helpers.mix([class: "foo"], class: "bar")
      assert result[:class] == "foo bar"
    end

    test "merges list attributes by concatenating" do
      result = Phlex.Helpers.mix([class: ["a", "b"]], class: ["c"])
      assert result[:class] == ["a", "b", "c"]
    end

    test "merges map attributes recursively" do
      result = Phlex.Helpers.mix([data: %{foo: "bar"}], data: %{baz: "qux"})
      assert result[:data] == %{foo: "bar", baz: "qux"}
    end

    test "works with maps" do
      result = Phlex.Helpers.mix(%{class: "foo"}, %{id: "bar"})
      assert result[:class] == "foo"
      assert result[:id] == "bar"
    end
  end

  describe "grab/1" do
    test "returns single value for one binding" do
      result = Phlex.Helpers.grab(foo: "bar")
      assert result == "bar"
    end

    test "returns tuple for multiple bindings" do
      result = Phlex.Helpers.grab(foo: "bar", baz: "qux")
      assert result == {"bar", "qux"}
    end

    test "works with maps" do
      result = Phlex.Helpers.grab(%{foo: "bar", baz: "qux"})
      assert result == {"bar", "qux"}
    end
  end
end
