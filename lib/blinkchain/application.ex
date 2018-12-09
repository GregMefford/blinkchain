defmodule Blinkchain.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.debug("Blinkchain Application starting")
    children = [
      Blinkchain.HAL
    ]

    opts = [
      name: Blinkchain.Supervisor,
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 1
    ]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    Logger.debug("Blinkchain Application starting")
  end
end
