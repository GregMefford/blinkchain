defmodule Blinkchain do
  alias Blinkchain.{
    Color,
    HAL,
    Point
  }

  require Logger

  @moduledoc """
  # `Blinkchian`

  This module defines the canvas-based drawing API for controlling one or more
  strips or arrays of NeoPixel-compatible RGB or RGBW LEDs. The virtual drawing
  surface consists of a single rectangular plane where each NeoPixel can be
  mapped onto particular coordinates on the surface. These assignments can be
  "sparse" such that not every location on the virtual surface is associated
  with a physical NeoPixel.

  > NOTE: In the current implementation, when drawing to points on the virtual
  > canvas that do not have physical NeoPixels assigned, the data is lost, such
  > that subsequent calls to `copy/4` or `copy_blit/4` will result in these
  > pixels behaving as if they had all color components set to `0`. This may
  > change in a future release, such that the virtual drawing surface would be
  > persistent, even if the given pixels are not associated with physical
  > NeoPixels, to allow for "off-screen" sprite maps for use with
  > `copy_blit/4`. In the meantime, this could be accomplished by configuring
  > some extra pixels at the end of the chain or on a second channel that don't
  > actually exist.

  The Raspberry Pi supports two simultaneous Pulse-Width Modulation (PWM)
  channels, which are used by `Blinkchain` to drive an arbitrary-length
  chain of NeoPixels. Each chain must consist of a single type of device (i.e.
  all devices in the chain must have the same number and order of color
  components). Some drawing commands operate on the entire channel (e.g.
  `set_brightness/2` and `set_gamma/2`), but otherwise, the position of the
  pixels within the drawing surface is independent of the channel they're
  driven by. A single drawing command can apply to one or both channels,
  depending on how the channel topology has been mapped to the virtual
  drawing surface.
  """

  @typedoc "which PWM channel to use (0 or 1)"
  @type channel_number :: 0 | 1

  @typedoc "unsigned 8-bit integer"
  @type uint8 :: 0..255

  @typedoc "unsigned 16-bit integer"
  @type uint16 :: 0..65535

  @doc """
  This is used to scale the intensity of all pixels in a given channel by
  `brightness/255`.
  """
  @spec set_brightness(channel_number(), uint8()) ::
    :ok |
    {:error, :invalid, :channel} |
    {:error, :invalid, :brightness}
  def set_brightness(channel, brightness) do
    with \
      :ok <- validate_channel_number(channel),
      :ok <- validate_uint8(brightness, :brightness),
    do: GenServer.cast(HAL, {:set_brightness, channel, brightness})
  end

  @doc """
  Set the gamma curve to be used for the channel.

  `gamma` is a list of 255 8-bit unsigned integers, which will be used as a
  look-up table to transform the value of each color component for each pixel.
  """
  @spec set_gamma(channel_number(), [uint8()]) ::
    :ok |
    {:error, :invalid, :channel} |
    {:error, :invalid, :gamma}
  def set_gamma(channel, gamma) do
    with \
      :ok <- validate_channel_number(channel),
      :ok <- validate_gamma(gamma),
    do: GenServer.cast(HAL, {:set_gamma, channel, gamma})
  end

  @doc """
  Set the color of the pixel at a given point on the virtual canvas.
  """
  @spec set_pixel(
    Point.t() | {uint16(), uint16()},
    Color.t() | {uint8(), uint8(), uint8()} | {uint8(), uint8(), uint8(), uint8()}
  ) ::
    :ok |
    {:error, :invalid, :point} |
    {:error, :invalid, :color}
  def set_pixel(%Point{} = point, %Color{} = color) do
    with \
      :ok <- validate_point(point),
      :ok <- validate_color(color),
    do: GenServer.cast(HAL, {:set_pixel, point, color})
  end
  def set_pixel({x, y}, color), do: set_pixel(%Point{x: x, y: y}, color)
  def set_pixel(point, {r, g, b}), do: set_pixel(point, %Color{r: r, g: g, b: b})
  def set_pixel(point, {r, g, b, w}), do: set_pixel(point, %Color{r: r, g: g, b: b, w: w})

  @doc """
  Fill the region with `color`, starting at `origin` and extending to the right
  by `width` pixels and down by `height` pixels.
  """
  @spec fill(
    Point.t() | {uint16(), uint16()},
    uint16(),
    uint16(),
    Color.t() | {uint8(), uint8(), uint8()} | {uint8(), uint8(), uint8(), uint8()}
  ) ::
    :ok |
    {:error, :invalid, :origin} |
    {:error, :invalid, :width} |
    {:error, :invalid, :height} |
    {:error, :invalid, :color}
  def fill(%Point{} = origin, width, height, %Color{} = color) do
    with \
      :ok <- validate_point(origin, :origin),
      :ok <- validate_uint16(width, :width),
      :ok <- validate_uint16(height, :height),
      :ok <- validate_color(color),
    do: GenServer.cast(HAL, {:fill, origin, width, height, color})
  end
  def fill({x, y}, width, height, color), do: fill(%Point{x: x, y: y}, width, height, color)
  def fill(origin, width, height, {r, g, b}), do: fill(origin, width, height, %Color{r: r, g: g, b: b})
  def fill(origin, width, height, {r, g, b, w}), do: fill(origin, width, height, %Color{r: r, g: g, b: b, w: w})

  @doc """
  Copy the region of size `width` by `height` from `source` to `destination`.
  """
  @spec copy(
    Point.t() | {uint16(), uint16()},
    Point.t() | {uint16(), uint16()},
    uint16(),
    uint16()
  ) ::
    :ok |
    {:error, :invalid, :source} |
    {:error, :invalid, :destination} |
    {:error, :invalid, :width} |
    {:error, :invalid, :height}
  def copy(%Point{} = source, %Point{} = destination, width, height) do
    with \
      :ok <- validate_point(source, :source),
      :ok <- validate_point(destination, :destination),
      :ok <- validate_uint16(width, :width),
      :ok <- validate_uint16(height, :height),
    do: GenServer.cast(HAL, {:copy, source, destination, width, height})
  end
  def copy({x, y}, destination, width, height), do: copy(%Point{x: x, y: y}, destination, width, height)
  def copy(source, {x, y}, width, height), do: copy(source, %Point{x: x, y: y}, width, height)

  @doc """
  Copy the region of size `width` by `height` from `source` to `destination`,
  ignoring pixels whose color components are all zero.

  > Note: This is different than `f:copy/4` because it allows a simple
  > transparency mask to be created by setting all of the color components to
  > zero for the pixels that are intended to be transparent.
  """
  @spec copy_blit(
    Point.t() | {uint16(), uint16()},
    Point.t() | {uint16(), uint16()},
    uint16(),
    uint16()
  ) ::
    :ok |
    {:error, :invalid, :source} |
    {:error, :invalid, :destination} |
    {:error, :invalid, :width} |
    {:error, :invalid, :height}
  def copy_blit(%Point{} = source, %Point{} = destination, width, height) do
    with \
      :ok <- validate_point(source, :source),
      :ok <- validate_point(destination, :destination),
      :ok <- validate_uint16(width, :width),
      :ok <- validate_uint16(height, :height),
    do: GenServer.cast(HAL, {:copy_blit, source, destination, width, height})
  end
  def copy_blit({x, y}, destination, width, height), do: copy_blit(%Point{x: x, y: y}, destination, width, height)
  def copy_blit(source, {x, y}, width, height), do: copy_blit(source, %Point{x: x, y: y}, width, height)

  @doc """
  Copy the elements from the `data` list as pixel data, copying it to the
  region of size `width` by `height` and origin of `destination`, ignoring
  pixels whose color components are all zero.

  `data` must be a list of `width` x `height` elements, where each element is
  a `t:Color.t/0`

  > Note: Similar to `f:copy_blit/4`, this allows a simple transparency mask to
  > be created by setting all of the color components to zero for the pixels
  > that are intended to be transparent.
  """
  @spec blit(
    Point.t() | {uint16(), uint16()},
    uint16(),
    uint16(),
    [
      Color.t() | {uint8(), uint8(), uint8()} | {uint8(), uint8(), uint8(), uint8()}
    ]
  ) ::
    :ok |
    {:error, :invalid, :destination} |
    {:error, :invalid, :width} |
    {:error, :invalid, :height} |
    {:error, :invalid, :data}
  def blit(%Point{} = destination, width, height, data) do
    with \
      :ok <- validate_point(destination, :destination),
      :ok <- validate_uint16(width, :width),
      :ok <- validate_uint16(height, :height),
      :ok <- validate_data(data, width * height),
    do: GenServer.cast(HAL, {:blit, destination, width, height, normalize_data(data)})
  end
  def blit({x, y}, width, height, data), do: blit(%Point{x: x, y: y}, width, height, data)

  @doc """
  Render the current canvas state to the physical NeoPixels according to their
  configured locations in the virtual canvas.
  """
  @spec render() :: :ok
  def render, do: GenServer.cast(HAL, :render)

  # Helpers

  defp normalize_data(data) when is_binary(data), do: data
  defp normalize_data(colors) when is_list(colors) do
    colors
    |> Enum.reduce(<<>>, fn color, acc -> acc <> normalize_color(color) end)
  end

  defp normalize_color(%Color{r: r, g: g, b: b, w: w}), do: <<r, g, b, w>>
  defp normalize_color({r, g, b}), do: <<r, g, b, 0>>
  defp normalize_color({r, g, b, w}), do: <<r, g, b, w>>

  defp validate_uint8(val, tag) do
    val
    |> validate_uint8()
    |> case do
      :ok -> :ok
      :error -> {:error, :invalid, tag}
    end
  end

  defp validate_uint16(val, tag) do
    val
    |> validate_uint16()
    |> case do
      :ok -> :ok
      :error -> {:error, :invalid, tag}
    end
  end

  defp validate_uint8(val) when val in 0..255, do: :ok
  defp validate_uint8(_), do: :error

  defp validate_uint16(val) when val in 0..65535, do: :ok
  defp validate_uint16(_), do: :error

  defp validate_channel_number(val) when val in 0..1, do: :ok
  defp validate_channel_number(_), do: {:error, :invalid, :channel}

  defp validate_gamma(gamma) when is_list(gamma) and length(gamma) == 255 do
    gamma
    |> Enum.all?(& validate_uint8(&1) == :ok)
    |> case do
      true -> :ok
      false -> {:error, :invalid, :gamma}
    end
  end
  defp validate_gamma(_), do: {:error, :invalid, :gamma}

  defp validate_point(point, tag \\ :point)
  defp validate_point(%Point{x: x, y: y}, _tag) when x in 0..65535 and y in 0..65535, do: :ok
  defp validate_point(_point, tag), do: {:error, :invalid, tag}

  defp validate_color(%Color{r: r, g: g, b: b, w: w}) when r in 0..255 and g in 0..255 and b in 0..255 and w in 0..255, do: :ok
  defp validate_color(_), do: {:error, :invalid, :color}

  defp validate_data(data, expected_length) when is_list(data) and length(data) == expected_length do
    data
    |> Enum.all?(& validate_color(&1) == :ok)
    |> case do
      true -> :ok
      false -> {:error, :invalid, :data}
    end
  end
  defp validate_data(data, expected_length) when is_binary(data) and byte_size(data) == expected_length * 4, do: :ok
  defp validate_data(_, _), do: {:error, :invalid, :data}

end
