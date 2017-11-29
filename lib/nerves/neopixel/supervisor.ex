defmodule Nerves.Neopixel.Supervisor do
  use Supervisor

  require Logger

  def start_link(opts) do
    Logger.debug("Nerves.Neopixel.Supervisor.start_link")
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Nerves.Neopixel.HAL
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def stop() do
    Supervisor.stop(__MODULE__)
  end

end
