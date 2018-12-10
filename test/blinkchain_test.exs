defmodule Blinkchain.BlinkchainTest do
  # We have to use async: false for these because the HAL wants to register its
  # name globally, so we can only run one at a time.
  use ExUnit.Case, async: false

  doctest Blinkchain

  alias Blinkchain.{
    Color,
    HAL,
    Point
  }

  # Arrangement looks like this:
  # Y  X: 0  1  2  3  4  5  6  7
  # 0  [  0  1  2  3  4  5  6  7 ] <- Adafruit NeoPixel Stick on Channel 0 (pin 18)
  #    |-------------------------|
  # 1  |  0  1  2  3  4  5  6  7 |
  # 2  |  8  9 10 11 12 13 14 15 | <- Pimoroni Unicorn pHat on Channel 1 (pin 13)
  # 3  | 16 17 18 19 20 21 22 23 |
  # 4  | 24 25 26 27 28 29 30 31 |
  #    |-------------------------|
  defp with_neopixel_stick_and_unicorn_phat(_) do
    Application.stop(:blinkchain)
    {:ok, _pid} = HAL.start_link(config: neopixel_stick_and_unicorn_phat_config(), subscriber: self())
    flush()
    :ok
  end

  describe "Blinkchain.set_pixel" do
    setup [:with_neopixel_stick_and_unicorn_phat]

    test "it works with RGB colors" do
      Blinkchain.set_pixel(%Point{x: 0, y: 0}, %Color{r: 255, g: 0, b: 128})
      assert_receive "DBG: Called set_pixel(x: 0, y: 0, color: 0x00ff0080)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][0]: 0x00ff0080"
    end

    test "it works with RGBW colors" do
      Blinkchain.set_pixel(%Point{x: 0, y: 0}, %Color{r: 255, g: 0, b: 128, w: 64})
      assert_receive "DBG: Called set_pixel(x: 0, y: 0, color: 0x40ff0080)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][0]: 0x40ff0080"
    end

    test "it renders the pixel in the correct location on a strip" do
      Blinkchain.set_pixel(%Point{x: 6, y: 0}, %Color{r: 255, g: 0, b: 128, w: 64})
      assert_receive "DBG: Called set_pixel(x: 6, y: 0, color: 0x40ff0080)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][6]: 0x40ff0080"
    end

    test "it renders the pixel in the correct location on a matrix" do
      Blinkchain.set_pixel(%Point{x: 6, y: 3}, %Color{r: 255, g: 0, b: 128, w: 64})
      assert_receive "DBG: Called set_pixel(x: 6, y: 3, color: 0x40ff0080)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [1][22]: 0x40ff0080"
    end

    test "it works with tuples instead of structs" do
      Blinkchain.set_pixel({0, 1}, {255, 0, 128})
      assert_receive "DBG: Called set_pixel(x: 0, y: 1, color: 0x00ff0080)"

      Blinkchain.set_pixel({0, 1}, {255, 0, 128, 64})
      assert_receive "DBG: Called set_pixel(x: 0, y: 1, color: 0x40ff0080)"

      Blinkchain.set_pixel(%Point{x: 0, y: 1}, {255, 0, 128, 64})
      assert_receive "DBG: Called set_pixel(x: 0, y: 1, color: 0x40ff0080)"

      Blinkchain.set_pixel({0, 1}, %Color{r: 255, g: 0, b: 128, w: 64})
      assert_receive "DBG: Called set_pixel(x: 0, y: 1, color: 0x40ff0080)"
    end
  end

  describe "Blinkchain.fill" do
    setup [:with_neopixel_stick_and_unicorn_phat]

    test "it fills the correct pixels in multiple channels" do
      Blinkchain.fill(%Point{x: 2, y: 0}, 2, 3, %Color{r: 255, g: 0, b: 128})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 2, y: 0, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 3, y: 0, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 2, y: 1, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 3, y: 1, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 2, y: 2, color: 0x00ff0080)"
      assert_receive "DBG:   - write_pixel(x: 3, y: 2, color: 0x00ff0080)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][2]: 0x00ff0080"
      assert_receive "DBG:   [0][3]: 0x00ff0080"
      assert_receive "DBG:   [1][2]: 0x00ff0080"
      assert_receive "DBG:   [1][3]: 0x00ff0080"
      assert_receive "DBG:   [1][10]: 0x00ff0080"
      assert_receive "DBG:   [1][11]: 0x00ff0080"

      # Should not fill outside the specified bounds:
      assert_receive "DBG:   [0][1]: 0x00000000"
      assert_receive "DBG:   [0][4]: 0x00000000"
      assert_receive "DBG:   [1][1]: 0x00000000"
      assert_receive "DBG:   [1][4]: 0x00000000"
      assert_receive "DBG:   [1][9]: 0x00000000"
      assert_receive "DBG:   [1][12]: 0x00000000"
    end

    test "works with RGB or RGBW colors" do
      Blinkchain.fill(%Point{x: 2, y: 0}, 2, 3, %Color{r: 255, g: 0, b: 128})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x00ff0080)"

      Blinkchain.fill(%Point{x: 2, y: 0}, 2, 3, %Color{r: 255, g: 0, b: 128, w: 64})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x40ff0080)"
    end

    test "works with tuples instead of structs" do
      Blinkchain.fill({2, 0}, 2, 3, %Color{r: 255, g: 0, b: 128})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x00ff0080)"

      Blinkchain.fill(%Point{x: 2, y: 0}, 2, 3, {255, 0, 128})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x00ff0080)"

      Blinkchain.fill(%Point{x: 2, y: 0}, 2, 3, {255, 0, 128, 64})
      assert_receive "DBG: Called fill(x: 2, y: 0, width: 2, height: 3, color: 0x40ff0080)"
    end
  end

  describe "Blinkchain.copy" do
    setup [:with_neopixel_stick_and_unicorn_phat]

    test "it copies the correct pixels in multiple channels" do
      Blinkchain.set_pixel(%Point{x: 2, y: 0}, %Color{r: 255, g: 0, b: 0, w: 0})
      Blinkchain.set_pixel(%Point{x: 3, y: 0}, %Color{r: 255, g: 255, b: 0, w: 0})
      Blinkchain.set_pixel(%Point{x: 2, y: 1}, %Color{r: 255, g: 255, b: 255, w: 0})
      Blinkchain.set_pixel(%Point{x: 3, y: 1}, %Color{r: 255, g: 255, b: 255, w: 255})
      Blinkchain.set_pixel(%Point{x: 2, y: 2}, %Color{r: 0, g: 0, b: 0, w: 255})
      Blinkchain.set_pixel(%Point{x: 3, y: 2}, %Color{r: 0, g: 0, b: 255, w: 255})

      Blinkchain.copy(%Point{x: 2, y: 0}, %Point{x: 4, y: 0}, 2, 3)
      assert_receive "DBG: Called copy(xs: 2, ys: 0, xd: 4, yd: 0, width: 2, height: 3)"
      assert_receive "DBG:   - write_pixel(x: 4, y: 0, color: 0x00ff0000)"
      assert_receive "DBG:   - write_pixel(x: 5, y: 0, color: 0x00ffff00)"
      assert_receive "DBG:   - write_pixel(x: 4, y: 1, color: 0x00ffffff)"
      assert_receive "DBG:   - write_pixel(x: 5, y: 1, color: 0xffffffff)"
      assert_receive "DBG:   - write_pixel(x: 4, y: 2, color: 0xff000000)"
      assert_receive "DBG:   - write_pixel(x: 5, y: 2, color: 0xff0000ff)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][4]: 0x00ff0000"
      assert_receive "DBG:   [0][5]: 0x00ffff00"
      assert_receive "DBG:   [1][4]: 0x00ffffff"
      assert_receive "DBG:   [1][5]: 0xffffffff"
      assert_receive "DBG:   [1][12]: 0xff000000"
      assert_receive "DBG:   [1][13]: 0xff0000ff"
    end

    test "copies the pixels atomically" do
      Blinkchain.set_pixel(%Point{x: 0, y: 0}, %Color{r: 255, g: 0, b: 0, w: 0})
      Blinkchain.set_pixel(%Point{x: 1, y: 0}, %Color{r: 255, g: 255, b: 0, w: 0})
      Blinkchain.set_pixel(%Point{x: 2, y: 0}, %Color{r: 255, g: 255, b: 255, w: 0})
      Blinkchain.set_pixel(%Point{x: 3, y: 0}, %Color{r: 255, g: 255, b: 255, w: 255})

      Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 2, y: 0}, 4, 1)

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][0]: 0x00ff0000"
      assert_receive "DBG:   [0][1]: 0x00ffff00"
      assert_receive "DBG:   [0][2]: 0x00ff0000"
      assert_receive "DBG:   [0][3]: 0x00ffff00"
      assert_receive "DBG:   [0][4]: 0x00ffffff"
      assert_receive "DBG:   [0][5]: 0xffffffff"
      assert_receive "DBG:   [0][6]: 0x00000000"
      assert_receive "DBG:   [0][7]: 0x00000000"
    end

    test "works with tuples instead of structs" do
      Blinkchain.copy({2, 0}, %Point{x: 4, y: 0}, 2, 3)
      assert_receive "DBG: Called copy(xs: 2, ys: 0, xd: 4, yd: 0, width: 2, height: 3)"

      Blinkchain.copy(%Point{x: 2, y: 0}, {4, 0}, 2, 3)
      assert_receive "DBG: Called copy(xs: 2, ys: 0, xd: 4, yd: 0, width: 2, height: 3)"

      Blinkchain.copy({2, 0}, {4, 0}, 2, 3)
      assert_receive "DBG: Called copy(xs: 2, ys: 0, xd: 4, yd: 0, width: 2, height: 3)"
    end
  end

  describe "Blinkchain.copy_blit" do
    setup [:with_neopixel_stick_and_unicorn_phat]

    test "it doesn't copy pixels that are 0x00000000" do
      Blinkchain.set_pixel(%Point{x: 1, y: 0}, %Color{r: 0, g: 0, b: 255, w: 0})
      Blinkchain.set_pixel(%Point{x: 0, y: 1}, %Color{r: 0, g: 0, b: 255, w: 0})
      Blinkchain.set_pixel(%Point{x: 2, y: 1}, %Color{r: 0, g: 0, b: 255, w: 0})
      Blinkchain.fill(%Point{x: 3, y: 0}, 3, 2, %Color{r: 255, g: 0, b: 0, w: 0})

      Blinkchain.copy_blit(%Point{x: 0, y: 0}, %Point{x: 3, y: 0}, 3, 2)
      assert_receive "DBG: Called copy_blit(xs: 0, ys: 0, xd: 3, yd: 0, width: 3, height: 2)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][4]: 0x000000ff"
      assert_receive "DBG:   [1][3]: 0x000000ff"
      assert_receive "DBG:   [1][5]: 0x000000ff"

      # Ignored:
      assert_receive "DBG:   [0][3]: 0x00ff0000"
      assert_receive "DBG:   [0][5]: 0x00ff0000"
      assert_receive "DBG:   [1][4]: 0x00ff0000"
    end

    test "works with tuples instead of structs" do
      Blinkchain.copy_blit({0, 0}, %Point{x: 3, y: 0}, 3, 2)
      assert_receive "DBG: Called copy_blit(xs: 0, ys: 0, xd: 3, yd: 0, width: 3, height: 2)"

      Blinkchain.copy_blit(%Point{x: 0, y: 0}, {3, 0}, 3, 2)
      assert_receive "DBG: Called copy_blit(xs: 0, ys: 0, xd: 3, yd: 0, width: 3, height: 2)"

      Blinkchain.copy_blit({0, 0}, {3, 0}, 3, 2)
      assert_receive "DBG: Called copy_blit(xs: 0, ys: 0, xd: 3, yd: 0, width: 3, height: 2)"
    end
  end

  describe "Blinkchain.blit" do
    setup [:with_neopixel_stick_and_unicorn_phat]

    test "it doesn't change pixels that are 0x00000000" do
      data = [
        %Color{r: 0, g: 0, b: 0, w: 0},
        %Color{r: 0, g: 0, b: 0, w: 255},
        %Color{r: 0, g: 0, b: 0, w: 0},
        %Color{r: 0, g: 0, b: 0, w: 255},
        %Color{r: 0, g: 0, b: 0, w: 0},
        %Color{r: 0, g: 0, b: 0, w: 255}
      ]

      Blinkchain.fill(%Point{x: 3, y: 0}, 3, 2, %Color{r: 255, g: 0, b: 0, w: 0})

      :ok = Blinkchain.blit(%Point{x: 3, y: 0}, 3, 2, data)
      assert_receive "DBG: Called blit(x: 3, y: 0, width: 3, height: 2, data: AAAAAAAAAP8AAAAAAAAA/wAAAAAAAAD/)"

      Blinkchain.render()
      assert_receive "DBG: Called render()"
      assert_receive "DBG:   [0][4]: 0x000000ff"
      assert_receive "DBG:   [1][3]: 0x000000ff"
      assert_receive "DBG:   [1][5]: 0x000000ff"

      # Ignored:
      assert_receive "DBG:   [0][3]: 0x00ff0000"
      assert_receive "DBG:   [0][5]: 0x00ff0000"
      assert_receive "DBG:   [1][4]: 0x00ff0000"
    end

    test "works with tuples instead of structs" do
      data = [
        {0, 0, 0, 0},
        {0, 0, 0, 255},
        {0, 0, 0, 0},
        {0, 0, 0, 255},
        {0, 0, 0, 0},
        {0, 0, 0, 255}
      ]

      Blinkchain.blit({3, 0}, 3, 2, data)
      assert_receive "DBG: Called blit(x: 3, y: 0, width: 3, height: 2, data: AAAAAAAAAP8AAAAAAAAA/wAAAAAAAAD/)"
    end

    test "works with binary data" do
      data =
        Enum.join([
          <<0, 0, 0, 0>>,
          <<0, 0, 0, 255>>,
          <<0, 0, 0, 0>>,
          <<0, 0, 0, 255>>,
          <<0, 0, 0, 0>>,
          <<0, 0, 0, 255>>
        ])

      Blinkchain.blit({3, 0}, 3, 2, data)
      assert_receive "DBG: Called blit(x: 3, y: 0, width: 3, height: 2, data: AAAAAAAAAP8AAAAAAAAA/wAAAAAAAAD/)"
    end
  end

  defp flush(type \\ :silent, opts \\ [])

  defp flush(:silent, opts) do
    receive do
      _msg -> flush(:silent, opts)
    after
      100 -> :ok
    end
  end

  defp flush(:inspect, opts) do
    receive do
      msg ->
        # credo:disable-for-next-line
        IO.inspect(msg, opts)
        flush(:inspect, opts)
    after
      100 -> :ok
    end
  end

  defp neopixel_stick_and_unicorn_phat_config do
    [
      canvas: {8, 5},
      channel0: [
        pin: 18,
        arrangement: [
          %{
            type: :strip,
            origin: {0, 0},
            count: 8,
            direction: :right
          }
        ]
      ],
      channel1: [
        pin: 13,
        arrangement: [
          %{
            type: :matrix,
            origin: {0, 1},
            count: {8, 4},
            direction: {:right, :down},
            progressive: true
          }
        ]
      ]
    ]
  end
end
