# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries

# Initialize some variables if not set
LDFLAGS ?=
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILE)-gcc

CFLAGS += -std=gnu99

ifeq ($(MIX_COMPILE_PATH),)
  $(error MIX_COMPILE_PATH should be set by elixir_make!)
endif

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

ifeq ($(CROSSCOMPILE),)
# Host testing build
CFLAGS += -DDEBUG
SRC = src/rpi_ws281x.c src/fake_ws2811.c
else
# Normal build
SRC = src/rpi_ws281x.c src/rpi_ws281x/dma.c src/rpi_ws281x/mailbox.c \
  src/rpi_ws281x/mailbox.c src/rpi_ws281x/pwm.c src/rpi_ws281x/rpihw.c \
  src/rpi_ws281x/pcm.c src/rpi_ws281x/ws2811.c
endif

OBJ = $(patsubst src/%,$(BUILD)/%,$(SRC:.c=.o))

calling_from_make:
	mix compile

all: $(PREFIX) $(PREFIX)/blinkchain

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p $@

$(BUILD)/rpi_ws281x:
	mkdir -p $@

$(BUILD)/%.o: src/%.c $(BUILD) $(BUILD)/rpi_ws281x
	$(CC) $(CFLAGS) -c $< -o $@

$(PREFIX)/blinkchain: $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@
ifeq ($(CROSSCOMPILE),)
	$(warning No cross-compiler detected. Building Blinkchain native code in test mode.)
	$(warning If you were intending to build in normal mode e.g. directly on a Raspberry Pi,)
	$(warning you can force it by running `CROSS_COMPILE=true mix compile`)
endif

clean:
	rm -rf $(PREFIX)/* $(BUILD)/*

.PHONY: all clean calling_from_make
