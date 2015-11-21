defmodule Neopixel do
  require Logger

  # Trigger file for LED0
  @led_trigger "/sys/class/leds/led0/trigger"

  # Brightness file for LED0
  @led_brightntess "/sys/class/leds/led0/brightness"

  def start(_type, _args) do
    # Setting the trigger to 'none' by default its 'mmc0'
    File.write(@led_trigger, "none")

    # Start blinking forever
    blink_forever
  end

  def blink_forever do
    # Turn on the green LED and sleep for 1000ms
    Logger.debug "Turning ON green"
    set_led(true)

    :timer.sleep 1000

    # Turn off the green LED and sleep for 1000ms
    Logger.debug "Turning OFF green"
    set_led(false)

    :timer.sleep 1000

    # Blink again
    blink_forever
  end

  # Setting the brightness to 1 in case of true and 0 if false
  def set_led(true), do: set_brightness("1")
  def set_led(false), do: set_brightness("0")

  def set_brightness(val) do
      File.write(@led_brightntess, val)
      |> inspect
      |> Logger.debug
  end
end
