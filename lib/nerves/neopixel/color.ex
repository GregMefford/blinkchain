defmodule Nerves.Neopixel.Color do
  @moduledoc """
  Represents a color with red, green, blue, and (optionally) white components.
  """

  alias Nerves.Neopixel
  alias __MODULE__

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    r: Neopixel.uint8,
    g: Neopixel.uint8,
    b: Neopixel.uint8,
    w: Neopixel.uint8
  }

  defstruct r: 0, g: 0, b: 0, w: 0

  @doc """
  Parse a `t:Color.t/0` from an HTML-style hex code, formatted as:
  * `"#RRGGBB"` for RGB, or
  * `"#RRGGBBWW"` for RGBW.
  """
  def parse(<< "#", r :: 2-bytes, g :: 2-bytes, b :: 2-bytes>>) do
    %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16)
    }
  end
  def parse(<< "#", r :: 2-bytes, g :: 2-bytes, b :: 2-bytes, w :: 2-bytes>>) do
    %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16),
      w: String.to_integer(w, 16)
    }
  end

end
