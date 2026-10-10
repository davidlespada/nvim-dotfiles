CXX ?= g++
CXXFLAGS := -Wall -Wextra -std=c++17 $(shell pkg-config --cflags sdl3)
LDLIBS := $(shell pkg-config --libs sdl3)

all: cpp-starter

cpp-starter: main.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f cpp-starter

.PHONY: all clean
