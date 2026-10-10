CC ?= gcc
CFLAGS := -Wall -Wextra -std=c11 $(shell pkg-config --cflags sdl3)
LDLIBS := $(shell pkg-config --libs sdl3)

all: sdl3-starter

sdl3-starter: main.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f sdl3-starter

.PHONY: all clean
