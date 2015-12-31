defmodule Nerves.IO.Neopixel.Driver do

  use GenServer
  require Logger

  def start_link(settings, opts) do
    Logger.debug "#{__MODULE__} Starting"
    GenServer.start_link(__MODULE__, settings, opts)
  end

  def init(settings) do
    Logger.debug "#{__MODULE__} initializing: #{inspect settings}"
    pin   = settings[:pin]
    count = settings[:count]

    cmd = "#{:code.priv_dir(:nerves_io_neopixel)}/rpi_ws281x #{pin} #{count}"
    port = Port.open({:spawn, cmd}, [:binary])
    {:ok, port}
  end

  def handle_call({:render, pixel_data}, _from, port) do
    Logger.debug "#{__MODULE__} rendering: #{inspect pixel_data}"
    Port.command(port, pixel_data)
    {:reply, :ok, port}
  end

end

defmodule Nerves.IO.Neopixel do

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

  def render(pid, pixel_data) do
    Logger.debug "#{__MODULE__} (pid: #{inspect pid}) rendering: #{inspect pixel_data}"
    GenServer.call(:nerves_io_neopixel, {:render, pixel_data})
  end

end
