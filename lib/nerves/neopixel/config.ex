defmodule Nerves.Neopixel.Config do
  alias Nerves.Neopixel.{
    Canvas,
    Channel,
    Config
  }

  defstruct [
    :canvas,
    :channels
  ]

  def load(), do: load(Application.get_all_env(:nerves_neopixel))
  def load(config) do
    canvas =
      config
      |> Keyword.get(:canvas)
      |> Canvas.load_config()

    channels =
      config
      |> Keyword.get(:channels)
      |> Enum.map(fn name -> Keyword.get(config, name) end)
      |> Enum.map(& Channel.load_config/1)

    %Config{
      canvas: canvas,
      channels: validate_channels(channels),
    }
  end

  defp validate_channels(channels) when is_list(channels) do
    pwm_channels = Enum.map(channels, & Channel.pwm_channel/1)
    if (Enum.dedup(pwm_channels) != pwm_channels) do
      raise "Each channel must have a :pin from a different hardware PWM channel"
    end
    channels
  end
  defp validate_channels(_), do: raise "You must configure a list of :channels for :nerves_neopixel"
end
