defmodule Nerves.Neopixel.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Nerves.Neopixel.HAL
    ]
    opts = [strategy: :one_for_one, name: Nerves.Neopixel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
