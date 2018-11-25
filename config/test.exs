use Mix.Config

config :logger, level: :warn

config :blinkchain,
  canvas: {1, 1}

config :blinkchain, :channel0,
  pin: 18,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 0},
      count: 1,
      direction: :right
    }
  ]
