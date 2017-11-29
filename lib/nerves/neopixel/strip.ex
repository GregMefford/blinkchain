defmodule Nerves.Neopixel.Strip do
  alias Nerves.Neopixel.Strip

  defstruct [
    origin: {0, 0},
    count: 1,
    spacing: 1,
    direction: :right,
  ]

  def load_config(%{type: :strip} = config) do
    sanitized_config = Map.take(config, [:origin, :count, :spacing, :direction])
    %Strip{}
    |> Map.merge(sanitized_config)
  end

end
