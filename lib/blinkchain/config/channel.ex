defmodule Blinkchain.Config.Channel do
  @pwm_0_pins [12, 18, 40, 52]
  @pwm_1_pins [13, 19, 41, 45, 53]

  @valid_types [
    :rgb,
    :rbg,
    :grb,
    :gbr,
    :brg,
    :bgr,
    :rgbw,
    :rbgw,
    :grbw,
    :gbrw,
    :brgw,
    :bgrw
  ]

  @moduledoc """
  Represents a single "chain" of pixels of the same type, connected to the same I/O pin.

  * `arrangement`: The list of `t:Blinkchain.Config.Strip.t/0` structs that describe each straight section of pixels.
  * `brightness`: The scale factor used for all pixels in the channel (`0`-`255`, default: `255`).
  * `gamma`: A custom gamma curve to apply to the color of each pixel (default is linear).
    Specified as a list of 256 integer values between `0` and `255`, which will be indexed to transform each color channel
    from the canvas to the hardware pixels.
  * `invert`: Whether to invert the PWM signal sent to the I/O pin (required by some hardware types (default: `false`).
  * `number`: Which PWM block to use (must be `0` or `1`)
  * `pin`: The I/O pin number to use for this channel (default: `18`)
    Only certain I/O pins are supported and only one pin from each PWM hardware block can be used simultaneously.
    Reference the `BCM` pin numbers on https://pinout.xyz/ for physical pin locations.
    * Available pins for PWM block 0: `#{inspect(@pwm_0_pins)}`
    * Available pins for PWM block 1: `#{inspect(@pwm_1_pins)}`
  * `type`: The order of color channels to send to each pixel. (default: `:gbr`)
    You may have to experiment to determine the correct setting for your pixel hardware, for example, by setting a
    pixel to full-intensity for each color channel one-by-one and seeing which color actually lights up.

    Valid options: `#{inspect(@valid_types)}`
  """

  alias Blinkchain.Config.{
    Channel,
    Matrix,
    Strip
  }

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          arrangement: [Strip.t()],
          brightness: Blinkchain.uint8(),
          gamma: [Blinkchain.uint8()],
          invert: boolean(),
          number: Blinkchain.channel_number(),
          pin: non_neg_integer(),
          type: atom()
        }

  defstruct arrangement: [],
            brightness: 255,
            gamma: nil,
            invert: false,
            number: nil,
            pin: 0,
            type: :gbr

  @doc "Build a `t:Blinkchain.Config.Channel.t/0` struct from given configuration options"
  @spec new(Keyword.t(), Blinkchain.channel_number()) :: Channel.t()
  def new(nil, number) when number in [0, 1], do: %Channel{number: number}

  def new(channel_config, number) when number in [0, 1] do
    %Channel{number: number}
    |> set_arrangement(Keyword.get(channel_config, :arrangement))
    |> set_brightness(Keyword.get(channel_config, :brightness))
    |> set_gamma(Keyword.get(channel_config, :gamma))
    |> set_invert(Keyword.get(channel_config, :invert))
    |> set_pin(Keyword.get(channel_config, :pin))
    |> set_type(Keyword.get(channel_config, :type))
  end

  @doc "Return the hardware PWM channel for a `t:Channel.t/0` or I/O pin"
  @spec pwm_channel(Channel.t() | non_neg_integer()) :: 0 | 1 | nil
  def pwm_channel(%Channel{pin: pin}), do: pwm_channel(pin)
  def pwm_channel(pin) when pin in @pwm_0_pins, do: 0
  def pwm_channel(pin) when pin in @pwm_1_pins, do: 1
  def pwm_channel(_), do: nil

  @doc "Count the total number of pixels in the channel"
  @spec total_count(Channel.t()) :: non_neg_integer()
  def total_count(%Channel{arrangement: arrangement}) do
    Enum.reduce(arrangement, 0, fn %Strip{count: count}, acc -> acc + count end)
  end

  # Private Helpers

  defp set_arrangement(channel, sections) when is_list(sections) do
    strips =
      sections
      |> Enum.map(&load_section/1)
      |> List.flatten()

    %Channel{channel | arrangement: strips}
  end

  defp set_arrangement(_channel, _arrangement) do
    raise "You must configure the :arrangement of pixels in each channel as a list"
  end

  defp set_brightness(channel, nil), do: channel

  defp set_brightness(channel, brightness) when brightness in 0..255 do
    %Channel{channel | brightness: brightness}
  end

  defp set_brightness(_channel, _brightness) do
    raise "Channel :brightness must be in 0..255"
  end

  defp set_gamma(channel, nil), do: channel

  defp set_gamma(channel, gamma) when is_list(gamma) and length(gamma) == 256 do
    %Channel{channel | gamma: gamma}
  end

  defp set_gamma(_channel, _gamma) do
    raise "The :gamma on a :channel must be set as a list of 256 8-bit integers"
  end

  defp set_invert(channel, nil), do: channel

  defp set_invert(channel, invert) when invert in [true, false] do
    %Channel{channel | invert: invert}
  end

  defp set_invert(_channel, _invert) do
    raise "Channel :invert must be true or false"
  end

  defp set_pin(%Channel{number: 0} = channel, pin) do
    if pin in @pwm_0_pins do
      %Channel{channel | pin: pin}
    else
      raise "Channel 0 :pin must be in #{inspect(@pwm_0_pins)}"
    end
  end

  defp set_pin(%Channel{number: 1} = channel, pin) do
    if pin in @pwm_1_pins do
      %Channel{channel | pin: pin}
    else
      raise "Channel 1 :pin must be in #{inspect(@pwm_1_pins)}"
    end
  end

  defp set_type(channel, nil), do: channel
  defp set_type(channel, type) when type in @valid_types, do: %Channel{channel | type: type}
  defp set_type(_channel, _), do: raise("Channel :type must be one of #{inspect(@valid_types)}")

  defp load_section(%{type: :matrix} = matrix_config) do
    matrix_config
    |> Matrix.new()
    |> Matrix.to_strip_list()
  end

  defp load_section(%{type: :strip} = strip_config) do
    Strip.new(strip_config)
  end

  defp load_section(_section) do
    raise "The :arrangement configuration must be a list of %{type: :strip} or %{type: :matrix} maps"
  end
end
