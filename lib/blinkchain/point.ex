defmodule Blinkchain.Point do
  @moduledoc """
  Represents a point on the virtual drawing canvas with x and y coordinates.
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    x: Blinkchain.uint16,
    y: Blinkchain.uint16
  }

  defstruct x: 0, y: 0

end
