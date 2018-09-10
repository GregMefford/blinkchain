defmodule Blinkchain.Config.Strip do
  @moduledoc """
  Represents a linear strip of pixels.

  * `count`: The number of pixels. (default: `1`)
  * `direction`: The `t:direction/0` of the wiring connection.
    (default: `:right`)
  * `origin`: The top-left-most location in the strip, expressed as `{x, y}`.
    (default: `{0, 0}`)
  * `spacing`: How far each pixel is spaced from the next on the virtual canvas,
    along the `direction`. (default: `1`)
  """

  alias __MODULE__

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    count: Blinkchain.uint16(),
    direction: direction(),
    origin: {Blinkchain.uint16(), Blinkchain.uint16()},
    spacing: Blinkchain.uint16()
  }

  defstruct [
    count: 1,
    direction: :right,
    origin: {0, 0},
    spacing: 1
  ]

  @type direction :: :left | :right | :up | :down

  def new(%{type: :strip} = config) do
    sanitized_config = Map.take(config, [:origin, :count, :spacing, :direction])
    %Strip{}
    |> Map.merge(sanitized_config)
  end

end
