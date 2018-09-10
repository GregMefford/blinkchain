use Mix.Config

config :logger, level: :warn

config :blinkchain,
  canvas: {1, 1},
  channels: [:channel1]

config :blinkchain, :channel1,
  pin: 18,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 0},
      count: 1,
      direction: :right
    }
  ]
