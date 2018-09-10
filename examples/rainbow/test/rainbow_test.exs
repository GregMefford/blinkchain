defmodule RainbowTest do
  use ExUnit.Case
  doctest Rainbow

  test "greets the world" do
    assert Rainbow.hello() == :world
  end
end
