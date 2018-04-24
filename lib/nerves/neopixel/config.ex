defmodule Nerves.Neopixel.Config do
  @moduledoc """
  Represents the placement of the NeoPixel devices on the virtual drawing canvas.
  """

  alias Nerves.Neopixel.{
    Canvas,
    Channel,
    Config
  }

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    canvas: Canvas.t(),
    channels: [Channel.t()]
  }

  defstruct [
    :canvas,
    :channels
  ]

  @doc """
  Build a `t:Nerves.Neopixel.Config.t/0` struct based on Application configuration.
  """
  @spec load(Keyword.t() | nil) :: Config.t()
  def load(nil) do
    :nerves_neopixel
    |> Application.get_all_env()
    |> load()
  end
  def load(config) when is_list(config) do
    canvas =
      config
      |> Keyword.get(:canvas)
      |> load_canvas_config()

    channels =
      config
      |> Keyword.get(:channels)
      |> load_channels_config(config)
      |> validate_channels()

    %Config{
      canvas: canvas,
      channels: channels,
    }
  end

  # Private Helpers

  defp load_canvas_config({width, height}), do: Canvas.new(width, height)
  defp load_canvas_config(_), do: raise ":nerves_neopixel :canvas dimensions must be configured as {width, height}"

  defp load_channels_config(channel_names, config) when is_list(channel_names) do
    Enum.map(channel_names, & load_channel_config(config, &1))
  end
  defp load_channels_config(_, _) do
    raise "You must configure a list of :channels for :nerves_neopixel"
  end

  defp load_channel_config(config, name) do
    config
    |> Keyword.get(name)
    |> case do
      nil -> raise "Missing configuration for channel #{name}"
      channel_config -> Channel.new(channel_config)
    end
  end

  defp validate_channels(channels) do
    pwm_channels = Enum.map(channels, & Channel.pwm_channel/1)
    if (Enum.dedup(pwm_channels) != pwm_channels) do
      raise "Each channel must have a :pin from a different hardware PWM channel"
    end
    channels
  end
end
