defmodule Nerves.Neopixel.Point do
  @moduledoc """
  Represents a point on the virtual drawing canvas with x and y coordinates.
  """

  alias Nerves.Neopixel

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    x: Neopixel.uint16,
    y: Neopixel.uint16
  }

  defstruct x: 0, y: 0

end
