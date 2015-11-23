defmodule Blinker do
  require Gpio
  use GenServer

  def start_link(pin, opts) do
    {:ok, pid} = Gpio.start_link(pin, :output)
    GenServer.start_link(__MODULE__, pid, opts)
  end

  def handle_call(:on,  _from, pid), do: {:reply, Gpio.write(pid, 1)}
  def handle_call(:off, _from, pid), do: {:reply, Gpio.write(pid, 0)}

  def blink_forever(pid) do
    Gpio.write(pid, 1)

    :timer.sleep 1000

    Gpio.write(pid, 0)

    :timer.sleep 1000

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

  def start(_type, _args) do
    Neopixel.Supervisor.start_link
  end

end
