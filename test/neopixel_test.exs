defmodule Nerves.IO.Neopixel.Test do

  use ExUnit.Case
  doctest Nerves.IO.Neopixel

  alias Nerves.IO.Neopixel

  test "configuring a Neopixel interface" do
    {:ok, pid} = Neopixel.setup pin: "18", count: "5"
    assert is_pid(pid)
  end

  test "rendering a pixel" do
    {:ok, pid} = Neopixel.setup pin: "18", count: "5"
    assert is_pid(pid)
    assert Neopixel.render(pid, <<255, 0, 16>>) == :ok
  end
end
