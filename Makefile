# Cross-platform Makefile for DOS and Linux builds

# Executables
LINUX_OUT = spiral-linux
DOS_OUT = spiral.exe

# Source files
MAIN_SRC = main.c
SPIRAL_SOURCES = $(wildcard spiral/*.c)
SDL_SRC = video/video_sdl.c
DOS_SRC = video/video_dos.c

# Compilers
CC_LINUX = gcc
CC_DOS = /home/mateusz/Projects/C++/djgpp/bin/i586-pc-msdosdjgpp-gcc

# Flags
CFLAGS_COMMON = -O2 -Wall -Wextra -mno-sse -mfpmath=387 -ffast-math -fno-math-errno
CFLAGS_LINUX = $(CFLAGS_COMMON) -Ispiral -Ivideo -m32
CFLAGS_DOS = $(CFLAGS_COMMON) -Ispiral -Ivideo

# Libraries
LDFLAGS_LINUX = -lSDL2 -lm 
LDFLAGS_DOS = -lm

# Default target
.PHONY: all
all: linux dos

# Linux build (SDL2)
.PHONY: linux
linux: $(LINUX_OUT)

$(LINUX_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC)
	$(CC_LINUX) $(CFLAGS_LINUX) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC) $(LDFLAGS_LINUX)
	@echo "Linux build complete: $(LINUX_OUT)"

# DOS build (DJGPP)
.PHONY: dos
dos: $(DOS_OUT)

$(DOS_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC)
	$(CC_DOS) $(CFLAGS_DOS) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC) $(LDFLAGS_DOS)
	@echo "DOS build complete: $(DOS_OUT)"

# Run Linux version
.PHONY: run
run: linux
	./$(LINUX_OUT)

# Clean build artifacts
.PHONY: clean
clean:
	rm -f $(LINUX_OUT) $(DOS_OUT)
	@echo "Cleaned build artifacts"

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make linux  - Build for Linux with SDL2 (default)"
	@echo "  make dos    - Cross-compile for DOS with DJGPP"
	@echo "  make run    - Build and run Linux version"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make all    - Build both Linux and DOS versions"
