defmodule PhlexTest do
  use ExUnit.Case
  doctest Phlex

  test "version/0 returns the version" do
    assert Phlex.version() == "0.3.0"
  end
end
