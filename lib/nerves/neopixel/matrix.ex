defmodule Nerves.Neopixel.Matrix do
  @moduledoc """
  Represents a contiguous matrix of pixels, composed of liner strips with a
  regular spacing and orientation pattern.

  * `count`: The number of pixels in each axis, expressed as `{x, y}`.
    (default: `{1, 1}`)
  * `direction`: The `t:Strip.direction/0` of the wiring connection along each axis,
    expressed as `{major, minor}`. (default: `{:right, :down}`)
  * `origin`: The top-left-most location in the matrix, expressed as `{x, y}`.
    (default: `{0, 0}`)
  * `progressive`: Whether the wiring `t:Strip.direction/0` of each successive
    strip is reversed on the major axis. (default: `false`)
  * `spacing`: How far each row and column are spaced on the virtual canvas,
    expressed as `{x, y}`. (default: `{1, 1}`)
  """

  alias Nerves.Neopixel.{
    Matrix,
    Strip
  }

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    count: {Neopixel.uint16(), Neopixel.uint16()},
    direction: {Strip.direction(), Strip.direction()},
    origin: {Neopixel.uint16(), Neopixel.uint16()},
    progressive: boolean(),
    spacing: {Neopixel.uint16(), Neopixel.uint16()}
  }

  defstruct [
    count: {1, 1},
    direction: {:right, :down},
    origin: {0, 0},
    progressive: false,
    spacing: {1, 1}
  ]

  def new(%{type: :matrix} = config) do
    sanitized_config = Map.take(config, [:origin, :count, :direction, :spacing, :progressive])
    %Matrix{}
    |> Map.merge(sanitized_config)
  end

  def to_strip_list(%Matrix{} = matrix) do
    %Matrix{
      origin: {x, y},
      count: {width, height},
      direction: {major, minor},
      spacing: {x_spacing, y_spacing},
      progressive: progressive
    } = matrix

    head = %Strip{
      origin: {x, y},
      count: component_for_direction({width, height}, major),
      direction: major,
      spacing: component_for_direction({x_spacing, y_spacing}, major),
    }

    remaining = component_for_direction({width, height}, minor) - 1
    minor_spacing = component_for_direction({x_spacing, y_spacing}, minor)
    [head | next_strips(remaining, head, minor, minor_spacing, progressive)]
  end

  # Private Helpers

  defp next_strips(0, _, _, _, _), do: []
  defp next_strips(remaining, prev_strip, minor, minor_spacing, progressive) do
    strip =
      prev_strip
      |> Map.put(:origin, next_progressive_origin(prev_strip.origin, minor, minor_spacing))
      |> flip_if_not_progressive(progressive)
    [strip | next_strips(remaining - 1, strip, minor, minor_spacing, progressive)]
  end

  defp next_progressive_origin({x, y}, :right, spacing), do: {x + spacing, y}
  defp next_progressive_origin({x, y}, :left, spacing), do: {x - spacing, y}
  defp next_progressive_origin({x, y}, :down, spacing), do: {x, y + spacing}
  defp next_progressive_origin({x, y}, :up, spacing), do: {x, y - spacing}

  defp flip_if_not_progressive(%Strip{} = strip, true), do: strip
  defp flip_if_not_progressive(%Strip{direction: direction} = strip, false) do
    %Strip{strip | origin: tail_coordinates(strip), direction: opposite(direction)}
  end

  defp tail_coordinates(%Strip{origin: {x, y}, direction: :right, count: count, spacing: spacing}) do
    {x + ((count - 1) * spacing), y}
  end
  defp tail_coordinates(%Strip{origin: {x, y}, direction: :left, count: count, spacing: spacing}) do
    {x - ((count - 1) * spacing), y}
  end
  defp tail_coordinates(%Strip{origin: {x, y}, direction: :down, count: count, spacing: spacing}) do
    {x, y + ((count - 1) * spacing)}
  end
  defp tail_coordinates(%Strip{origin: {x, y}, direction: :up, count: count, spacing: spacing}) do
    {x, y- ((count - 1) * spacing)}
  end

  defp opposite(:right), do: :left
  defp opposite(:left), do: :right
  defp opposite(:down), do: :up
  defp opposite(:up), do: :down

  defp component_for_direction({x, _y}, :right), do: x
  defp component_for_direction({x, _y}, :left), do: x
  defp component_for_direction({_x, y}, :down), do: y
  defp component_for_direction({_x, y}, :up), do: y

end
