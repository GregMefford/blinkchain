defmodule Blinkchain.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :blinkchain,
      version: @version,
      description: "Drive WS2812B \"NeoPixel\" RGB LED strips from a Raspberry Pi using Elixir.",
      elixir: "~> 1.6",
      make_clean: ["clean"],
      make_targets: ["all"],
      compilers: [:elixir_make | Mix.compilers()],
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      package: package(),
      aliases: [
        docs: [&copy_images/1, "docs"],
        format: &format/1
      ],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.circle": :test
      ],
      docs: [
        main: "readme",
        extras: [
          "README.md"
        ]
      ],
      name: "Blinkchain",
      source_url: "https://github.com/GregMefford/blinkchain"
    ]
  end

  def application() do
    [mod: {Blinkchain.Application, []}, extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp copy_images(_) do
    File.cp_r("resources", "doc/resources")
  end

  # Calling `mix format` wiithout any arguments, so also format the C code
  defp format([]) do
    Mix.Tasks.Format.run([])
    System.cmd("astyle", ~w{-n -q -s2 src/*.h src/*.c})
  end

  # If arguments are passed to `mix format` (e.g. `--check-formatted`),
  # assume they don't apply to astylei, so don't run it.
  defp format(args) do
    Mix.Tasks.Format.run(args)
  end

  defp package do
    [
      files: [
        "lib",
        "src/*.[ch]",
        "src/rpi_ws281x/*.[ch]",
        "mix.exs",
        "LICENSE*",
        "Makefile"
      ],
      maintainers: ["Greg Mefford"],
      licenses: ["MIT", "BSD 2-Clause"],
      links: %{"GitHub" => "https://github.com/GregMefford/blinkchain"}
    ]
  end
end
