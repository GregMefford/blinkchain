defmodule Nerves.Neopixel.Channel do
  alias Nerves.Neopixel.{
    Channel,
    Matrix,
    Strip
  }

  defstruct [
    pin: 0,
    brightness: 255,
    gamma: nil,
    invert: false,
    type: :gbr,
    arrangement: nil
  ]

  @valid_types [
    :rgb, :rbg, :grb, :gbr, :brg, :bgr,
    :rgbw, :rbgw, :grbw, :gbrw, :brgw, :bgrw
  ]

  def load_config(channel_config) do
    if is_nil(pwm_channel(channel_config[:pin])), do: raise "Each channel must specify a PWM-capable I/O :pin"

    %Channel{
      pin: channel_config[:pin],
      brightness: Keyword.get(channel_config, :brightness, 255),
      gamma: load_gamma(channel_config[:gamma]),
      invert: Keyword.get(channel_config, :invert, false),
      type: load_channel_type(channel_config[:type]),
      arrangement: load_arrangement(channel_config[:arrangement])
    }
  end

  def total_count(%Channel{arrangement: arrangement}) do
    Enum.reduce(arrangement, 0, fn (%Strip{count: count}, acc) -> acc + count end)
  end

  def pwm_channel(%Channel{pin: pin}), do: pwm_channel(pin)
  def pwm_channel(pin) when is_number(pin) and pin in [12, 18, 40, 52], do: 1
  def pwm_channel(pin) when is_number(pin) and pin in [13, 19, 41, 45, 53], do: 2
  def pwm_channel(_), do: nil

  defp load_gamma(nil), do: nil
  defp load_gamma(gamma_table) when is_list(gamma_table) and length(gamma_table) == 256 do
    gamma_table
  end
  defp load_gamma(_), do: raise "The :gamma on a :channel must be set as a list of 256 8-bit integers"

  defp load_channel_type(nil), do: :gbr
  defp load_channel_type(type) when type in @valid_types, do: type
  defp load_channel_type(_), do: raise "Channel :type must be one of #{inspect @valid_types}"

  defp load_arrangement(sections) when is_list(sections) do
    sections
    |> Enum.map(&load_section/1)
    |> List.flatten()
  end
  defp load_arrangement(_), do: raise "You must configure the :arrangement of pixels in each channel as a list"

  defp load_section(%{type: :matrix} = matrix_config) do
    matrix_config
    |> Matrix.load_config()
    |> Matrix.to_strip_list()
  end
  defp load_section(%{type: :strip} = strip_config) do
    strip_config
    |> Strip.load_config()
  end

end
