use Mix.Config

config :logger, level: :debug

config :blinkchain,
  canvas: {8, 4},
  channels: [:channel1]

config :blinkchain, :channel1,
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
