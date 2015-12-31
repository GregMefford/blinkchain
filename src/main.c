#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "clk.h"
#include "gpio.h"
#include "dma.h"
#include "pwm.h"

#include "ws2811.h"

#define DMA_CHANNEL 5

int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr, "Usage: %s <GPIO Pin> <LED Count>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  uint8_t pin = atoi(argv[1]);
  uint32_t count = strtol(argv[2], NULL, 10);

  ws2811_t ledstring = {
    .freq = WS2811_TARGET_FREQ,
    .dmanum = DMA_CHANNEL,
    .channel = {
      [0] = {
        .gpionum = pin,
        .count = count,
        .invert = 0,
        .brightness = 255,
      },
      [1] = {
        .gpionum = 0,
        .count = 0,
        .invert = 0,
        .brightness = 0,
      },
    },
  };

  if (ws2811_init(&ledstring)) {
    exit(EXIT_FAILURE);
  }

  uint8_t counter = 0;

  ws2811_led_t leds[] = { 0xff0000, 0x00ff00, 0x0000ff };

  while (1) {
    int i;
    for (i = 0; i < count-3; i+=3) {
      ledstring.channel[0].leds[i+0] = leds[0+(counter%3)];
      ledstring.channel[0].leds[i+1] = leds[1+(counter%3)];
      ledstring.channel[0].leds[i+2] = leds[2+(counter%3)];
    }
    counter++;

    if (ws2811_render(&ledstring)) {
      break;
    }

    usleep(1000000);
  }

  ws2811_fini(&ledstring);
  exit(EXIT_FAILURE);
}

