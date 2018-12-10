use Mix.Config

log_level = System.get_env("LOG_LEVEL")

config :logger, level: String.to_atom(log_level || "debug")

config :blinkchain,
  canvas: {8, 4}

config :blinkchain, :channel0,
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
