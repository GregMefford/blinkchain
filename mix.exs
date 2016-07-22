defmodule Nerves.Neopixel.Mixfile do
  use Mix.Project

  def project do
   [app: :nerves_io_neopixel,
    version: "0.2.0",
    description: "Drive WS2812B \"NeoPixel\" RGB LED strips from a Raspberry Pi using Elixir.",
    elixir: "~> 1.0",
    make_clean: ["clean"],
    compilers: [:elixir_make | Mix.compilers],
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    package: package,
    deps: deps]
  end

  def application do
   [applications: [:logger]]
  end

  defp deps do
    [{:elixir_make, "~> 0.3.0"}]
  end

  defp package do
   [files: ["lib", "src", "config", "mix.exs", "README*", "LICENSE*", "Makefile"],
    maintainers: ["Greg Mefford"],
    licenses: ["MIT", "BSD 2-Clause"],
    links: %{"GitHub" => "https://github.com/GregMefford/nerves_io_neopixel"}]
  end
end
