# Nerves-Neopixel



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add neopixel to your list of dependencies in `mix.exs`:

        def deps do
          [{:neopixel, "~> 0.0.1"}]
        end

  2. Ensure neopixel is started before your application:

        def application do
          [applications: [:neopixel]]
        end
