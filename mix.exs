defmodule Mix.Tasks.Compile.Ws281x do
  def run(_) do
    0 = Mix.Shell.IO.cmd("make priv/rpi_ws281x")
    Mix.Project.build_structure
    :ok
  end
end

defmodule Nerves.IO.Neopixel.Mixfile do
  use Mix.Project

  def project, do: [
    app: :nerves_io_neopixel,
    version: "0.0.1",
    elixir: "~> 1.0",
    name: "Nerves.IO.Neopixel",
    compilers: [:Ws281x, :elixir, :app],
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps
  ]

  def application, do: [
    applications: [:logger],
    mod: {Nerves.IO.Neopixel, []}
  ]

  defp deps, do: [
    { :exrm, "~> 0.15.0" }
  ]

end
