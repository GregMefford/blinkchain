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

  uint8_t gpio_pin = atoi(argv[1]);
  uint32_t led_count = strtol(argv[2], NULL, 10);

  ws2811_t ledstring = {
    .freq = WS2811_TARGET_FREQ,
    .dmanum = DMA_CHANNEL,
    .channel = {
      [0] = {
        .gpionum = gpio_pin,
        .count = led_count,
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

  freopen(NULL, "rb", stdin);

  uint32_t leds_read;
  uint8_t colors[] = {0, 0, 0};

  while (1) {
    ws2811_led_t *ptr = ledstring.channel[0].leds;

    for(leds_read = 0; leds_read < led_count; leds_read++, ptr++) {
      fread(colors, 3 * sizeof(uint8_t), 1, stdin);
      *ptr = (uint32_t)(colors[0] << 16 | colors[1] << 8 | colors[2]);
    }

    if (ws2811_render(&ledstring)) {
      break;
    }
  }

  ws2811_fini(&ledstring);
  exit(EXIT_FAILURE);
}

