defmodule Nerves.Neopixel do
  @moduledoc false

  use GenServer
  require Logger

  def start_link(channel1, channel2 \\ [pin: 0, count: 0]) do
    GenServer.start_link(__MODULE__, [channel1, channel2], [name: __MODULE__])
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  # render()
  def render({_, _} = data) do
    render(0, data)
  end

  def render(channel, {_, _} = data) do
    GenServer.call(__MODULE__, {:render, channel, data})
  end

  def init([ch1, ch2]) do
    ch1_pin = (ch1[:pin] || raise "Must pass pin for channel 1")
    |> to_string
    ch1_count = (ch1[:count] || raise "Must pass count for channel 1")
    |> to_string

    ch2_pin = (ch2[:pin] || 0)
    |> to_string
    ch2_count = (ch2[:count] || 0)
    |> to_string

    executable = "#{:code.priv_dir(:nerves_neopixel)}/rpi_ws281x"
    port = Port.open({:spawn_executable, executable},
      [{:args, [ch1_pin, ch1_count, ch2_pin, ch2_count]},
        {:packet, 2},
        :use_stdio,
        :binary])
    {:ok, %{
      port: port
    }}
  end

  def handle_call({:render, channel, {brightness, data}}, _from, s) do
    data = ws2811_brg(data)
    payload =
      {channel, {brightness, data}}
      |> :erlang.term_to_binary
    send s.port, {self(), {:command, payload}}
    {:reply, :ok, s}
  end

  defp ws2811_brg(data) when is_list(data) do
    Enum.reduce(data, <<>>, fn({r, g, b}, acc) ->
      acc <> <<b :: size(8), r :: size(8), g :: size(8), 0x00 :: size(8)>>
    end)
  end

end
