defmodule Nerves.Neopixel.Application do
  use Application

  require Logger

  @moduledoc """
  # `Nerves.Neopixel.Application`
  """

  def start(_type, _args) do
    Logger.debug("Nerves.Neopixel.start")
    Nerves.Neopixel.Supervisor.start_link([])
  end
end
