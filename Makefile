# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries

LDFLAGS +=

CFLAGS += -std=gnu99

CC ?= $(CROSSCOMPILER)gcc

ifeq ($(NERVES_TOOLCHAIN),)
# Host testing build
CFLAGS += -DDEBUG
SRC = src/rpi_ws281x.c src/fake_ws2811.c
endif
ifneq ($(NERVES_TOOLCHAIN),)
# Normal build
SRC = src/rpi_ws281x.c src/rpi_ws281x/dma.c src/rpi_ws281x/mailbox.c \
	src/rpi_ws281x/mailbox.c src/rpi_ws281x/pwm.c src/rpi_ws281x/rpihw.c \
	src/rpi_ws281x/pcm.c src/rpi_ws281x/ws2811.c
endif

OBJ = $(SRC:.c=.o)

.PHONY: all clean

all: priv/rpi_ws281x

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

priv/rpi_ws281x: $(OBJ)
	@mkdir -p priv
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	rm -f priv/rpi_ws281x src/*.o src/rpi_ws281x/*.o
