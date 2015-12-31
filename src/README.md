rpi_ws281x
==========

Userspace Raspberry Pi PWM library for WS281X LEDs

This code was adapted from https://github.com/jgarff/rpi_ws281x.
What follows is currently the README from that project, which doesn't
apply directly to its use in this project. I'll try to update it as the
code diverges from what it was originally.

Background:

The BCM2835 in the Raspberry Pi has a PWM module that is well suited to
driving individually controllable WS281X LEDs.  Using the DMA, PWM FIFO,
and serial mode in the PWM, it's possible to control almost any number
of WS281X LEDs in a chain connected to the PWM output pin.

This library and test program set the clock rate of the PWM controller to
3X the desired output frequency and creates a bit pattern in RAM from an
array of colors where each bit is represented by 3 bits for the PWM
controller as follows.

    Bit 1 - 1 1 0
    Bit 0 - 1 0 0


Hardware:

WS281X LEDs are generally driven at 5V, which requires that the data
signal be at the same level.  Converting the output from a Raspberry
Pi GPIO/PWM to a higher voltage through a level shifter is required.

It is possible to run the LEDs from a 3.3V - 3.6V power source, and
connect the GPIO directly at a cost of brightness, but this isn't
recommended.

The test program is designed to drive a 8x8 grid of LEDs from Adafruit
(http://www.adafruit.com/products/1487).  Please see the Adafruit
website for more information.

Know what you're doing with the hardware and electricity.  I take no
reponsibility for damage, harm, or mistakes.

Usage:

The API is very simple.  Make sure to create and initialize the ws2811_t
structure as seen in main.c.  From there it can be initialized
by calling ws2811_init().  LEDs are changed by modifying the color in
the .led[index] array and calling ws2811_render().  The rest is handled
by the library, which creates the DMA memory and starts the DMA/PWM.

Make sure to hook a signal handler for SIGKILL to do cleanup.  From the
handler make sure to call ws2811_fini().  It'll make sure that the DMA
is finished before program execution stops.

That's it.  Have fun.  This was a fun little weekend project.  I hope
you find it useful.  I plan to add some diagrams, waveform scope shots,
and a .deb package soon.

