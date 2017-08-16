defmodule Nerves.Neopixel.Test do

  use ExUnit.Case
  doctest Nerves.Neopixel

  alias Nerves.Neopixel

  test "configuring a Neopixel interface" do
    ch0_config = [pin: 18, count: 3]
    ch1_config = [pin: 19, count: 3]
    {:ok, pid} = Neopixel.start_link(ch0_config, ch1_config)
    assert is_pid(pid)
  end

  test "rendering a pixel" do
    ch0_config = [pin: 18, count: 3]
    ch1_config = [pin: 19, count: 3]
    {:ok, pid} = Neopixel.start_link(ch0_config, ch1_config)
    assert is_pid(pid)

    channel = 0
    intensity = 127
    data = [
      {255, 0, 0},
      {0, 255, 0},
      {0, 0, 255},
    ]
    assert Neopixel.render(channel, {intensity, data}) == :ok
  end
end
