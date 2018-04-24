defmodule Nerves.Neopixel.Application do
  @moduledoc """
  # `Nerves.Neopixel.Application`
  """

  use Application

  require Logger

  def start(_type, _args) do
    Logger.debug("Nerves.Neopixel.start")
    Nerves.Neopixel.Supervisor.start_link([])
  end
end
