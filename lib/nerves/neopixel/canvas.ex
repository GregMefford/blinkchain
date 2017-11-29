defmodule Nerves.Neopixel.Canvas do
  alias Nerves.Neopixel.Canvas

  defstruct [
    :width,
    :height,
  ]

  def load_config({width, height}), do: %Canvas{width: width, height: height}
  def load_config(_), do: raise "You must specify :canvas dimensions as {width, height} for :nerves_neopixel"
end
