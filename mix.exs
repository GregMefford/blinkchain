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
    version: "0.1.0",
    description: "Drive WS2812B \"NeoPixel\" RGB LED strips from a Raspberry Pi using Elixir.",
    elixir: "~> 1.0",
    name: "Nerves.IO.Neopixel",
    compilers: [:Ws281x, :elixir, :app],
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    package: package,
    deps: deps
  ]

  def application, do: [
    applications: [:logger],
    mod: {Nerves.IO.Neopixel, []}
  ]

  defp deps, do: [
  ]

  defp package, do: [
    files: ["lib", "src", "config", "rel", "mix.exs", "README*", "LICENSE*", "Makefile"],
    maintainers: ["Greg Mefford"],
    licenses: ["MIT", "BSD 2-Clause"],
    links: %{"GitHub" => "https://github.com/GregMefford/nerves_io_neopixel"}
  ]
  
end
