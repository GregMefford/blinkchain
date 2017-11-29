defmodule Nerves.Neopixel do
  alias Nerves.Neopixel.HAL

  require Logger

  @moduledoc """
  # `Nerves.Neopixel`
  """

  def set_brightness(channel, brightness) do
    GenServer.cast(HAL, {:set_brightness, channel, brightness})
  end

  def set_gamma(channel, gamma) do
    GenServer.cast(HAL, {:set_gamma, channel, gamma})
  end

  def set_pixel({x, y}, {r, g, b}) do
    GenServer.cast(HAL, {:set_pixel, {x, y}, {r, g, b, 0}})
  end
  def set_pixel({x, y}, {r, g, b, w}) do
    GenServer.cast(HAL, {:set_pixel, {x, y}, {r, g, b, w}})
  end

  def fill({x, y}, width, height, {r, g, b}) do
    GenServer.cast(HAL, {:fill, {x, y}, width, height, {r, g, b, 0}})
  end
  def fill({x, y}, width, height, {r, g, b, w}) do
    GenServer.cast(HAL, {:fill, {x, y}, width, height, {r, g, b, w}})
  end

  def copy({xs, ys}, {xd, yd}, width, height) do
    GenServer.cast(HAL, {:copy, {xs, ys}, {xd, yd}, width, height})
  end

  def copy_blit({xs, ys}, {xd, yd}, width, height) do
    GenServer.cast(HAL, {:copy_blit, {xs, ys}, {xd, yd}, width, height})
  end

  def blit({x, y}, width, height, data) do
    GenServer.cast(HAL, {:blit, {x, y}, width, height, data})
  end

  def render, do: GenServer.cast(HAL, :render)
end
