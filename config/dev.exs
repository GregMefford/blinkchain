use Mix.Config

config :logger, level: :debug

config :nerves_neopixel,
  canvas: {8, 4},
  channels: [:channel1]

config :nerves_neopixel, :channel1,
  pin: 18,
  arrangement: [
    %{
      type: :matrix,
      origin: {0, 0},
      count: {8, 4},
      direction: {:right, :down},
      progressive: true
    }
  ]
