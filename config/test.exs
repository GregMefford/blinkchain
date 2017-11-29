use Mix.Config

config :logger, level: :warn

config :nerves_neopixel,
  canvas: {1, 1},
  channels: [:channel1]

config :nerves_neopixel, :channel1,
  pin: 18,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 0},
      count: 1,
      direction: :right
    }
  ]
