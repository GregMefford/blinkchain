defmodule Nerves.IO.Neopixel.Driver do
  @moduledoc false

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
