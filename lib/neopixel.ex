defmodule Blinker do
  use GenServer

  def start_link(pin, opts) do
    {:ok, pid} = Gpio.start_link(pin, :output)
    GenServer.start_link(__MODULE__, pid, opts)
    blink_forever(pid)
  end

  def handle_call(:on,  _from, pid), do: {:reply, Gpio.write(pid, 1)}
  def handle_call(:off, _from, pid), do: {:reply, Gpio.write(pid, 0)}

  def blink_forever(pid) do
    # Turn on the green LED and sleep for 1000ms
    #Logger.debug "Turning ON green"
    Gpio.write(pid, 1)

    :timer.sleep 1000

    # Turn off the green LED and sleep for 1000ms
    #Logger.debug "Turning OFF green"
    Gpio.write(pid, 0)

    :timer.sleep 1000

    # Blink again
    blink_forever(pid)
  end

end

defmodule Neopixel.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Blinker, [18, [name: :blinker]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

defmodule Neopixel do
  use Application
  require Logger
  require Gpio

  def start(_type, _args) do
    Neopixel.Supervisor.start_link
  end

end
