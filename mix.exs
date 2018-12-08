defmodule Blinkchain.Mixfile do
  use Mix.Project

  @version "1.0.0-dev"

  def project do
    [
      app: :blinkchain,
      version: @version,
      description: "Drive WS2812B \"NeoPixel\" RGB LED strips from a Raspberry Pi using Elixir.",
      elixir: "~> 1.6",
      make_clean: ["clean"],
      compilers: [:elixir_make, Mix.compilers()],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      aliases: [
        docs: ["docs", &copy_images/1],
      ],
      deps: deps(),
      docs: [
        main: "Blinkchain",
        extras: [
          "README.md",
        ]
      ],
      name: "Blinkchain",
      source_url: "https://github.com/GregMefford/blinkchain"
    ]
  end

  def application() do
    [mod: {Blinkchain.Application, []},
     extra_applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false}
    ]
  end

  defp copy_images(_) do
    File.cp_r("resources", "doc/resources")
  end

  defp package do
    [
      files: [
        "lib",
        "src/*.[ch]",
        "src/rpi_ws281x/*.[ch]",
        "config",
        "mix.exs",
        "README*",
        "LICENSE*",
        "Makefile"
      ],
      maintainers: ["Greg Mefford"],
      licenses: ["MIT", "BSD 2-Clause"],
      links: %{"GitHub" => "https://github.com/GregMefford/blinkchain"}
    ]
  end
end
