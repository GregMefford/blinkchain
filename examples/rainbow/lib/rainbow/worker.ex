defmodule Rainbow.Worker do
  use GenServer

  # Arrangement looks like this:
  # Y  X: 0  1  2  3  4  5  6  7
  # 0  [  0  1  2  3  4  5  6  7 ] <- Adafruit NeoPixel Stick on Channel 1 (pin 13)
  #    |-------------------------|
  # 1  |  0  1  2  3  4  5  6  7 |
  # 2  |  8  9 10 11 12 13 14 15 | <- Pimoroni Unicorn pHat on Channel 0 (pin 18)
  # 3  | 16 17 18 19 20 21 22 23 |
  # 4  | 24 25 26 27 28 29 30 31 |
  #    |-------------------------|

  alias Blinkchain.Point

  defmodule State do
    defstruct [:timer, :colors]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Send ourselves a message to draw each frame every 33 ms,
    # which will end up being approximately 15 fps.
    {:ok, ref} = :timer.send_interval(33, :draw_frame)

    state = %State{
      timer: ref,
      colors: Rainbow.colors()
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do
    [c1, c2, c3, c4, c5] = Enum.slice(state.colors, 0..4)
    tail = Enum.slice(state.colors, 1..-1)

    # Shift all pixels to the right
    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 7, 5)

    # Populate the five leftmost pixels with new colors
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, c1)
    Blinkchain.set_pixel(%Point{x: 0, y: 1}, c2)
    Blinkchain.set_pixel(%Point{x: 0, y: 2}, c3)
    Blinkchain.set_pixel(%Point{x: 0, y: 3}, c4)
    Blinkchain.set_pixel(%Point{x: 0, y: 4}, c5)

    Blinkchain.render()
    {:noreply, %State{state | colors: tail ++ [c1]}}
  end
end
