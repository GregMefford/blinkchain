# Blinkchain

Drive WS2812B "NeoPixel" RGB LED strips from a Raspberry Pi using Elixir!

![NeoPixel strip driven by a Raspberry Pi](nerves_neopixel_rgb.jpg)

This project was designed to make it easy to drive a string of AdaFruit
NeoPixels from a Raspberry Pi using [Nerves](http://nerves-project.org). The
code would probably also work outside of Nerves with minor modifications to the
Makefile, if you so desire.

> NOTE: This library used to be called `nerves_neopixel`. The reason for the
> new name and major version bump is that I wanted to overhaul the API and
> also make it less-specific to Nerves and NeoPixels. For example, it could be
> used in the future to control DotStar LED chains from Raspbian Linux.

## Installation

Add it to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:blinkchain, "~> 1.0"}]
    end
    ```

If you've cloned the `blinkchain` repository, be sure to check out the
`rpi_ws281x` submodule:

```sh
$ git submodule init
$ git submodule update
```

## Connections

Only a subset of GPIO pins on the Raspberry Pis can control the NeoPixels. See
[GPIO Usage](https://github.com/jgarff/rpi_ws281x#gpio-usage) for details.
Additionally, since the Raspberry Pi has 3.3V I/O outputs and the NeoPixels
require 5V I/O input, you'll need a level shifter to convert between voltages.

You can read more about using NeoPixels with Nerves in [my blog post about the
project](http://www.gregmefford.com/blog/2016/01/22/driving-neopixels-with-elixir-and-nerves).

## Usage

Supervision trees and an Elixir `Port` are used to maintain fault-tolerance when
interfacing with the low-level driver, which is written in C. To drive an
NeoPixel strip, you just have to configure which GPIO pin(s) to use and how the
pixels are arranged in each chain.

```elixir
# config/config.exs
use Mix.Config

config :blinkchain,
  channels: [:channel0, :channel1]

config :blinkchain, :channel0,
  arrangement: [
    %{
      type: :strip,
      count: 144,
      direction: :right,
      origin: {0, 0},
    }
  ],
  pin: 18,
  type: :gbr
```
