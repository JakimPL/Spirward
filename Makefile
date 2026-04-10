# Cross-platform Makefile for DOS and Linux builds

# Debug mode (set DEBUG=1 to enable)
DEBUG ?= 1

# Executables
LINUX_OUT = spiral-linux
DOS_OUT = spiral.exe
COM_OUT = spiral.com
LST_OUT = spiral.lst spiral-raw.lst

# Source files
MAIN_SRC = main.c
SPIRAL_SOURCES = $(wildcard spiral/*.c)
SDL_SRC = video/video_sdl.c
DOS_SRC = video/video_dos.c
ASM_SRC = core/linux.asm
COM_SRC = main.asm

# Object files (in main directory)
SPIRAL_ASM_OBJ_LINUX = spiral-linux.o
SPIRAL_ASM_OBJ_DOS = spiral.o

# Compilers
CC_LINUX = gcc
CC_DOS = /home/mateusz/Projects/C++/djgpp/bin/i586-pc-msdosdjgpp-gcc
ASM = nasm

# Base flags
CFLAGS_BASE = -Wall -Wextra -mno-sse -mfpmath=387 -ffast-math -fno-math-errno
ASMFLAGS_BASE =

# Debug flags
ifeq ($(DEBUG),1)
    CFLAGS_DEBUG = -g -O0
    ASMFLAGS_DEBUG_LINUX = -g -F dwarf
    ASMFLAGS_DEBUG_DOS = -g
else
    CFLAGS_DEBUG = -O2
    ASMFLAGS_DEBUG_LINUX =
    ASMFLAGS_DEBUG_DOS =
endif

# Platform-specific flags
CFLAGS_LINUX = $(CFLAGS_BASE) $(CFLAGS_DEBUG) -Ispiral -Ivideo -m32
CFLAGS_DOS = $(CFLAGS_BASE) $(CFLAGS_DEBUG) -Ispiral -Ivideo
ASMFLAGS_LINUX = -f elf32 $(ASMFLAGS_DEBUG_LINUX) -DLINUX
ASMFLAGS_DOS = -f coff --prefix _ $(ASMFLAGS_DEBUG_DOS) -DDOS
ASMFLAGS_COM = -f bin -DDOS -DCOM

# Libraries
LDFLAGS_LINUX = -lSDL2 -lm
LDFLAGS_DOS = -lm

# Default target
.PHONY: all
all: clean linux dos com

# Assembly object file rules
$(SPIRAL_ASM_OBJ_LINUX): $(ASM_SRC)
	$(ASM) $(ASMFLAGS_LINUX) -o $@ $<

$(SPIRAL_ASM_OBJ_DOS): $(ASM_SRC)
	$(ASM) $(ASMFLAGS_DOS) -o $@ $<

# Linux build (SDL2)
.PHONY: linux
linux: $(LINUX_OUT)

$(LINUX_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC) $(SPIRAL_ASM_OBJ_LINUX)
	$(CC_LINUX) $(CFLAGS_LINUX) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC) $(SPIRAL_ASM_OBJ_LINUX) $(LDFLAGS_LINUX)
	@echo "Linux build complete: $(LINUX_OUT)"

# DOS build (DJGPP)
# TODO: Assembly integration needs underscore-prefixed symbols for DJGPP
.PHONY: dos
dos: $(DOS_OUT)

$(DOS_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC) $(SPIRAL_ASM_OBJ_DOS)
	$(CC_DOS) $(CFLAGS_DOS) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC) $(SPIRAL_ASM_OBJ_DOS) $(LDFLAGS_DOS)
	@echo "DOS build complete: $(DOS_OUT)"

# COM build (Assembly only)
.PHONY: com
com: $(COM_OUT)

$(COM_OUT): $(COM_SRC)
	$(ASM) $(ASMFLAGS_COM) $< -o $@ -l $(basename $@).lst
	@./show-sizes.sh $(basename $@).lst
	@echo "COM build complete: $(COM_OUT) ($$(stat -c%s $@) bytes)"
	@echo "Listing with sizes: $(basename $@).lst"

# Show instruction sizes from listing
.PHONY: sizes
sizes: com
	@./show-sizes.sh $(basename $(COM_OUT)).lst

# Run Linux version
.PHONY: run
run: linux
	./$(LINUX_OUT)

# Clean build artifacts
.PHONY: clean
clean:
	rm -f $(LINUX_OUT) $(DOS_OUT) $(COM_OUT) $(SPIRAL_ASM_OBJ_LINUX) $(SPIRAL_ASM_OBJ_DOS) $(LST_OUT)
	@echo "Cleaned build artifacts"

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make linux       - Build for Linux with SDL2"
	@echo "  make dos         - Cross-compile for DOS with DJGPP"
	@echo "  make com         - Assemble standalone .com file"
	@echo "  make sizes       - Show instruction sizes from .lst file"
	@echo "  make run         - Build and run Linux version"
	@echo "  make clean       - Remove build artifacts"
	@echo "  make all         - Build all targets"
	@echo ""
	@echo "Debug mode:"
	@echo "  make DEBUG=1 linux  - Build Linux version with debug symbols"
	@echo "  make DEBUG=1 all    - Build all targets with debug symbols"
