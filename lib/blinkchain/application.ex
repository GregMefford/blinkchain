defmodule Blinkchain.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.debug("Blinkchain Application starting")
    children = [
      Blinkchain.HAL
    ]

    opts = [strategy: :one_for_one, name: Blinkchain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    Logger.debug("Blinkchain Application starting")
  end
end
