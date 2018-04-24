// This is a bare-bones implementation of the ws2811 API
// to make it easier to test on non-Raspberry Pi hardware

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "rpi_ws281x/ws2811.h"
#include "port_interface.h"

#define RPI_PWM_CHANNELS 2

ws2811_return_t ws2811_init(ws2811_t *ws2811) {
    int chan;
    for (chan = 0; chan < RPI_PWM_CHANNELS; chan++) {
        ws2811_channel_t *channel = &ws2811->channel[chan];
        channel->leds = calloc(channel->count, sizeof(ws2811_led_t));
        channel->strip_type=WS2811_STRIP_RGB;
    }
    return WS2811_SUCCESS;
}

ws2811_return_t ws2811_render(ws2811_t *ws2811) {
    debug("Called render()");
    uint8_t ch;
    uint16_t offset;
    for(ch = 0; ch < RPI_PWM_CHANNELS; ch++) {
        for(offset = 0; offset < ws2811->channel[ch].count; offset++) {
            debug("  [%hhu][%hu]: 0x%08x", ch, offset, ws2811->channel[ch].leds[offset]);
        }
    }
    return WS2811_SUCCESS;
}

const char * ws2811_get_return_t_str(const ws2811_return_t state) {
    const int index = -state;
    static const char * const ret_state_str[] = { WS2811_RETURN_STATES(WS2811_RETURN_STATES_STRING) };

    if (index < (int)(sizeof(ret_state_str) / sizeof(ret_state_str[0])))
    {
        return ret_state_str[index];
    }

    return "";
}
