defmodule Nerves.Neopixel.HAL do
  use GenServer

  alias Nerves.Neopixel.{
    Canvas,
    Channel,
    Config,
    Strip
  }

  require Logger

  def start_link(opts) do
    config = load_config(opts)
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    args =
      config.channels
      |> Enum.flat_map(fn ch -> ["#{ch.pin}", "#{Channel.total_count(ch)}", "#{ch.type}"] end)

    Logger.debug("Opening rpi_ws281x Port")
    port = Port.open({:spawn_executable, rpi_ws281x_path()}, [
      {:args, args},
      {:line, 1024},
      :use_stdio,
      :stderr_to_stdout,
      :exit_status
    ])
    send(self(), :init_canvas)
    {:ok, %{ config: config, port: port }}
  end

  # This is intended to be used for testing.
  # It causes Nerves.Neopixel.HAL to send feedback to the registered process
  # whenever it gets output from the rpi_ws281x Port.
  # It's a call instead of a cast so that we can synchronously make sure
  # it got registered before we move on to the next step.
  def handle_call(:subscribe, {from, _ref}, state) do
    {:reply, :ok, Map.put(state, :subscriber, from)}
  end

  # This is intended to be used for testing. It doesn't do anything useful
  # in a real application.
  def handle_cast(:print_topology, %{port: port} = state) do
    send_to_port("print_topology\n", port)
    {:noreply, state}
  end

  def handle_cast({:set_brightness, channel, brightness}, %{port: port} = state) do
    send_to_port("set_brightness #{channel} #{brightness}\n", port)
    {:noreply, state}
  end

  def handle_cast({:set_gamma, channel, gamma}, %{port: port} = state) do
    send_to_port("set_gamma #{channel} #{Base.encode64(gamma)}\n", port)
    {:noreply, state}
  end

  def handle_cast({:set_pixel, {x, y}, {r, g, b, w}}, %{port: port} = state) do
    send_to_port("set_pixel #{x} #{y} #{r} #{g} #{b} #{w}\n", port)
    {:noreply, state}
  end

  def handle_cast({:fill, {x, y}, width, height, {r, g, b, w}}, %{port: port} = state) do
    send_to_port("fill #{x} #{y} #{width} #{height} #{r} #{g} #{b} #{w}\n", port)
    {:noreply, state}
  end

  def handle_cast({:copy, {xs, ys}, {xd, yd}, width, height}, %{port: port} = state) do
    send_to_port("copy #{xs} #{ys} #{xd} #{yd} #{width} #{height}\n", port)
    {:noreply, state}
  end

  def handle_cast({:copy_blit, {xs, ys}, {xd, yd}, width, height}, %{port: port} = state) do
    send_to_port("copy_blit #{xs} #{ys} #{xd} #{yd} #{width} #{height}\n", port)
    {:noreply, state}
  end

  def handle_cast({:blit, {x, y}, width, height, data}, %{port: port} = state) do
    base64_data = Base.encode64(data)
    send_to_port("blit #{x} #{y} #{width} #{height} #{String.length(base64_data)} #{base64_data}\n", port)
    {:noreply, state}
  end

  def handle_cast(:render, %{port: port} = state) do
    send_to_port("render\n", port)
    {:noreply, state}
  end

  def handle_info(:init_canvas, %{config: config, port: port} = state) do
    Logger.debug("Initializing canvas")
    config.canvas
    |> init_canvas(port)

    config.channels
    |> Enum.with_index()
    |> Enum.each(fn {channel, channel_number} -> init_channel(channel_number, channel, port) end)

    {:noreply, state}
  end

  def handle_info({_port, {:data, {_, message}}}, state) do
    Logger.debug(fn -> "Reply from rpi_ws281x: <- #{inspect to_string(message)}" end)
    notify(state[:subscriber], to_string(message))
    {:noreply, state}
  end

  def handle_info({_port, {:exit_status, exit_status}}, state) do
    {:stop, "rpi_ws281x OS process died with status: #{inspect exit_status}", state}
  end

  def handle_info(message, state) do
    Logger.error("Unhandled message: #{inspect message}")
    {:noreply, state}
  end

  defp load_config(opts) do
    case Keyword.get(opts, :config) do
      nil -> Config.load()
      config -> Config.load(config)
    end
  end

  defp init_canvas(%Canvas{width: width, height: height}, port) do
    "init_canvas #{width} #{height}\n"
    |> send_to_port(port)
  end

  defp init_channel(channel_num, %Channel{} = channel, port) do
    invert = if channel.invert, do: 1, else: 0
    "set_invert #{channel_num} #{invert}\n"
    |> send_to_port(port)

    "set_brightness #{channel_num} #{channel.brightness}\n"
    |> send_to_port(port)

    if channel.gamma do
      gamma =
        channel.gamma
        |> Enum.reduce(<<>>, fn val, acc -> <<acc::binary, val::size(8)>> end)
        |> Base.encode64()

      "set_gamma #{channel_num} #{gamma}\n"
      |> send_to_port(port)
    end

    channel.arrangement
    |> with_pixel_offset()
    |> Enum.map(fn {offset, strip} -> init_pixels(channel_num, offset, strip, port) end)
  end

  defp init_pixels(channel_num, offset, %Strip{origin: {x, y}, count: count, direction: direction}, port) do
    {dx, dy} = case direction do
      :right -> {1, 0}
      :left -> {-1, 0}
      :down -> {0, 1}
      :up -> {0, -1}
    end

    "init_pixels #{channel_num} #{offset} #{x} #{y} #{count} #{dx} #{dy}\n"
    |> send_to_port(port)
  end

  defp with_pixel_offset(arrangement, offset \\0)
  defp with_pixel_offset([], _offset), do: []
  defp with_pixel_offset([strip | rest], offset) do
    [{offset, strip} | with_pixel_offset(rest, offset + strip.count)]
  end

  defp rpi_ws281x_path do
    Path.join(:code.priv_dir(:nerves_neopixel), "rpi_ws281x")
  end

  defp send_to_port(command, port) do
    Logger.debug(fn -> "Sending to rpi_ws281x: -> #{inspect command}" end)
    Port.command(port, command)
  end

  defp notify(nil, _message), do: :ok
  defp notify(pid, message), do: send(pid, message)
end
