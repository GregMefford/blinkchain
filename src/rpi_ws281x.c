#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <err.h>

#include "rpi_ws281x/clk.h"
#include "rpi_ws281x/gpio.h"
#include "rpi_ws281x/dma.h"
#include "rpi_ws281x/pwm.h"
#include "rpi_ws281x/ws2811.h"

#include "erlcmd.h"
#include "utils.h"

#define DMA_CHANNEL 5


/*
  Receive from Erlang a list of tuples
  {channel, {brightness, data}}
  Each tuple contains
  {brightness, led_data}
*/
static void led_handle_request(const char *req, void *cookie) {

  ws2811_t *ledstring = (ws2811_t *)cookie;

  int req_index = sizeof(uint16_t);
  if (ei_decode_version(req, &req_index, NULL) < 0)
      errx(EXIT_FAILURE, "Message version issue?");

  int arity;
  if (ei_decode_tuple_header(req, &req_index, &arity) < 0 ||
          arity != 2)
    errx(EXIT_FAILURE, "expecting {{channel1}, {channel2}} tuple");


  unsigned int ch_num;
  ei_decode_long(req, &req_index, (long int *) &ch_num);

  ws2811_channel_t *channel = &ledstring->channel[ch_num];

  if (ei_decode_tuple_header(req, &req_index, &arity) < 0 ||
          arity != 2)
    errx(EXIT_FAILURE, "expecting {brightness, led_data} tuple");

  unsigned int brightness;
  if (ei_decode_long(req, &req_index, (long int *) &brightness) < 0 ||
    brightness > 255)
    errx(EXIT_FAILURE, "brightness: min=0, max=255");

  channel->brightness = brightness;

  long int led_data_len = (4 * channel->count);
  ei_decode_binary(req, &req_index, channel->leds, &led_data_len);

  if (ws2811_render(ledstring)) {
    errx(EXIT_FAILURE, "Failed to render");
  }
}

int main(int argc, char *argv[]) {
  if (argc != 5) {
    fprintf(stderr, "Usage: %s <Channel 1 GPIO Pin> <Channel 1 LED Count> <Channel 2 GPIO Pin> <Channel 2 LED Count>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  uint8_t gpio_pin1 = atoi(argv[1]);
  uint32_t led_count1 = strtol(argv[2], NULL, 10);

  uint8_t gpio_pin2 = atoi(argv[3]);
  uint32_t led_count2 = strtol(argv[4], NULL, 10);

  /*
  Setup the channels. Raspberry Pi supports 2 PWM channels.
  */
  ws2811_t ledstring = {
    .freq = WS2811_TARGET_FREQ,
    .dmanum = DMA_CHANNEL,
    .channel = {
      [0] = {
        .gpionum = gpio_pin1,
        .count = led_count1,
        .invert = 0,
        .brightness = 0,
      },
      [1] = {
        .gpionum = gpio_pin2,
        .count = led_count2,
        .invert = 0,
        .brightness = 0,
      },
    },
  };

  if (ws2811_init(&ledstring)) {
    exit(EXIT_FAILURE);
  }

  struct erlcmd handler;
  erlcmd_init(&handler, led_handle_request, &ledstring);

  for (;;) {
    erlcmd_process(&handler);
  }
}
