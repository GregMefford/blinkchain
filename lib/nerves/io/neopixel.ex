defmodule Nerves.IO.Neopixel do
  @moduledoc false

  use Application
  require Logger

  alias Nerves.IO.Neopixel

  def start(_type, _args) do
    Logger.debug "#{__MODULE__} Starting"
    {:ok, self}
  end

  def setup(settings \\ [pin: 18, count: 1]) do
    Logger.debug "#{__MODULE__} Setup(#{inspect settings})"

    import Supervisor.Spec

    children = [
      worker(Neopixel.Driver, [settings, [name: :nerves_io_neopixel]])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def render(_pid, pixel_data) do
    Logger.debug "#{__MODULE__} (pid: #{inspect _pid}) rendering: #{inspect pixel_data}"
    GenServer.call(:nerves_io_neopixel, {:render, pixel_data})
  end

end
