defmodule Blinkchain.ConfigTest do
  use ExUnit.Case

  alias Blinkchain.Config

  alias Blinkchain.Config.{
    Canvas,
    Channel,
    Strip
  }

  describe "Blinkchain.Config.load" do
    test "with two channels, each with one Strip" do
      config = [
        canvas: {10, 2},
        channel0: [
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
        channel1: [
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
        channel0: ch0,
        channel1: ch1
      } = Config.load(config)

      assert canvas == %Canvas{width: 10, height: 2}

      assert ch0 == %Channel{
               arrangement: [%Strip{origin: {0, 0}, count: 10, direction: :right}],
               number: 0,
               pin: 18
             }

      assert ch1 == %Channel{
               arrangement: [%Strip{origin: {0, 1}, count: 5, direction: :right}],
               number: 1,
               pin: 19
             }
    end

    test "with one channel that has a zig-zag Matrix" do
      config = [
        canvas: {8, 4},
        channel0: [
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
        channel0: ch0
      } = Config.load(config)

      assert canvas == %Canvas{width: 8, height: 4}

      assert ch0 == %Channel{
               arrangement: [
                 %Strip{origin: {0, 0}, count: 8, direction: :right},
                 %Strip{origin: {7, 1}, count: 8, direction: :left},
                 %Strip{origin: {0, 2}, count: 8, direction: :right},
                 %Strip{origin: {7, 3}, count: 8, direction: :left}
               ],
               number: 0,
               pin: 18
             }
    end

    test "with one channel that has a rotated zig-zag Matrix" do
      config = [
        canvas: {4, 8},
        channel0: [
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
        channel0: ch0
      } = Config.load(config)

      assert canvas == %Canvas{width: 4, height: 8}

      assert ch0 == %Channel{
               arrangement: [
                 %Strip{origin: {3, 0}, count: 8, direction: :down},
                 %Strip{origin: {2, 7}, count: 8, direction: :up},
                 %Strip{origin: {1, 0}, count: 8, direction: :down},
                 %Strip{origin: {0, 7}, count: 8, direction: :up}
               ],
               number: 0,
               pin: 18
             }
    end

    test "with one channel that has a mixture of Strips and Matrices" do
      config = [
        canvas: {9, 8},
        channel0: [
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
        channel0: ch0
      } = Config.load(config)

      assert canvas == %Canvas{width: 9, height: 8}

      assert ch0 == %Channel{
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
               ],
               number: 0,
               pin: 18
             }
    end
  end
end
