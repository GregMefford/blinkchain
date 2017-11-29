defmodule Nerves.Neopixel.ConfigTest do
  use ExUnit.Case

  alias Nerves.Neopixel
  alias Neopixel.{
    Canvas,
    Channel,
    Config,
    Strip
  }

  describe "Nerves.Neopixel.Config.load" do
    test "with two channels, each with one Strip" do
      config = [
        canvas: {10, 2},
        channels: [:channel1, :channel2],
        channel1: [
          pin: 18,
          arrangement: [
            %{
              type: :strip,
              origin: {0, 0},
              count: 10,
              direction: :right
            }
          ]
        ],
        channel2: [
          pin: 19,
          arrangement: [
            %{
              type: :strip,
              origin: {0, 1},
              count: 5,
              direction: :right
            }
          ]
        ]
      ]

      %Config{
        canvas: canvas,
        channels: [ch1, ch2]
      } = Config.load(config)

      assert canvas == %Canvas{width: 10, height: 2}

      assert ch1 == %Channel{
        pin: 18,
        arrangement: [%Strip{origin: {0, 0}, count: 10, direction: :right}]
      }

      assert ch2 == %Channel{
        pin: 19,
        arrangement: [%Strip{origin: {0, 1}, count: 5, direction: :right}]
      }
    end

    test "with one channel that has a zig-zag Matrix" do
      config = [
        canvas: {8, 4},
        channels: [:channel1],
        channel1: [
          pin: 18,
          arrangement: [
            %{
              type: :matrix,
              origin: {0, 0},
              count: {8, 4},
              direction: {:right, :down},
              progressive: false
            }
          ]
        ]
      ]

      %Config{
        canvas: canvas,
        channels: [ch1]
      } = Config.load(config)

      assert canvas == %Canvas{width: 8, height: 4}

      assert ch1 == %Channel{
        pin: 18,
        arrangement: [
          %Strip{origin: {0, 0}, count: 8, direction: :right},
          %Strip{origin: {7, 1}, count: 8, direction: :left},
          %Strip{origin: {0, 2}, count: 8, direction: :right},
          %Strip{origin: {7, 3}, count: 8, direction: :left}
        ]
      }
    end

    test "with one channel that has a rotated zig-zag Matrix" do
      config = [
        canvas: {4, 8},
        channels: [:channel1],
        channel1: [
          pin: 18,
          arrangement: [
            %{
              type: :matrix,
              origin: {3, 0},
              count: {4, 8},
              direction: {:down, :left},
              progressive: false
            }
          ]
        ]
      ]

      %Config{
        canvas: canvas,
        channels: [ch1]
      } = Config.load(config)

      assert canvas == %Canvas{width: 4, height: 8}

      assert ch1 == %Channel{
        pin: 18,
        arrangement: [
          %Strip{origin: {3, 0}, count: 8, direction: :down},
          %Strip{origin: {2, 7}, count: 8, direction: :up},
          %Strip{origin: {1, 0}, count: 8, direction: :down},
          %Strip{origin: {0, 7}, count: 8, direction: :up}
        ]
      }
    end

    test "with one channels that has a mixture of Strips and Matrices" do
      config = [
        canvas: {9, 8},
        channels: [:channel1],
        channel1: [
          pin: 18,
          arrangement: [
            %{
              type: :matrix,
              origin: {0, 0},
              count: {4, 8},
              direction: {:down, :right},
              progressive: true
            },
            %{
              type: :strip,
              origin: {4, 7},
              count: 8,
              direction: :up
            },
            %{
              type: :matrix,
              origin: {5, 0},
              count: {4, 8},
              direction: {:right, :down},
              progressive: false
            }
          ]
        ]
      ]

      %Config{
        canvas: canvas,
        channels: [ch1]
      } = Config.load(config)

      assert canvas == %Canvas{width: 9, height: 8}

      assert ch1 == %Channel{
        pin: 18,
        arrangement: [
          %Strip{origin: {0, 0}, count: 8, direction: :down},
          %Strip{origin: {1, 0}, count: 8, direction: :down},
          %Strip{origin: {2, 0}, count: 8, direction: :down},
          %Strip{origin: {3, 0}, count: 8, direction: :down},
          %Strip{origin: {4, 7}, count: 8, direction: :up},
          %Strip{origin: {5, 0}, count: 4, direction: :right},
          %Strip{origin: {8, 1}, count: 4, direction: :left},
          %Strip{origin: {5, 2}, count: 4, direction: :right},
          %Strip{origin: {8, 3}, count: 4, direction: :left},
          %Strip{origin: {5, 4}, count: 4, direction: :right},
          %Strip{origin: {8, 5}, count: 4, direction: :left},
          %Strip{origin: {5, 6}, count: 4, direction: :right},
          %Strip{origin: {8, 7}, count: 4, direction: :left}
        ]
      }
    end
  end # describe configuration

end
