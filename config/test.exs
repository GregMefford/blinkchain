use Mix.Config

log_level = System.get_env("LOG_LEVEL")

config :logger, level: String.to_atom(log_level || "warn")

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
