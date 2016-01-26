priv/rpi_ws281x: src/dma.c src/pwm.c src/ws2811.c src/main.c
	@mkdir -p priv
	$(CC) $(CFLAGS) -o $@ $^

