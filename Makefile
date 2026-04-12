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
PALETTE_ASM_SRC = core/palette.asm
COM_SRC = main.asm

# Object files (in main directory)
SPIRAL_ASM_OBJ_LINUX = spiral-linux.o
SPIRAL_ASM_OBJ_DOS = spiral.o
DOS_ASM_OBJ = palette.o

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
	@echo "\033[1mAssembling $(ASM_SRC) for Linux...\033[0m"
	$(ASM) $(ASMFLAGS_LINUX) -o $@ $<

$(SPIRAL_ASM_OBJ_DOS): $(ASM_SRC)
	@echo "\033[1mAssembling $(ASM_SRC) for DOS...\033[0m"
	$(ASM) $(ASMFLAGS_DOS) -o $@ $<

$(DOS_ASM_OBJ): $(PALETTE_ASM_SRC)
	@echo "\033[1mAssembling $(PALETTE_ASM_SRC) for DOS...\033[0m"
	$(ASM) $(ASMFLAGS_DOS) -o $@ $<

# Linux build (SDL2)
.PHONY: linux
linux: $(LINUX_OUT)

$(LINUX_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC) $(SPIRAL_ASM_OBJ_LINUX)
	@echo "\033[1;34m==> Building for Linux (SDL2)\033[0m"
	$(CC_LINUX) $(CFLAGS_LINUX) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(SDL_SRC) $(SPIRAL_ASM_OBJ_LINUX) $(LDFLAGS_LINUX)
	@echo "\033[1;32mLinux build complete: $(LINUX_OUT)\033[0m"
	@echo

# DOS build (DJGPP)
# TODO: Assembly integration needs underscore-prefixed symbols for DJGPP
.PHONY: dos
dos: $(DOS_OUT)

$(DOS_OUT): $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC) $(SPIRAL_ASM_OBJ_DOS) $(DOS_ASM_OBJ)
	@echo "\033[1;35m==> Building for DOS (DJGPP)\033[0m"
	$(CC_DOS) $(CFLAGS_DOS) -o $@ $(MAIN_SRC) $(SPIRAL_SOURCES) $(DOS_SRC) $(SPIRAL_ASM_OBJ_DOS) $(DOS_ASM_OBJ) $(LDFLAGS_DOS)
	@echo "\033[1;32mDOS build complete: $(DOS_OUT)\033[0m"
	@echo

# COM build (Assembly only)
.PHONY: com
com: $(COM_OUT)

$(COM_OUT): $(COM_SRC)
	@echo "\033[1;33m==> Building COM file (DOS 256b demo)\033[0m"
	$(ASM) $(ASMFLAGS_COM) $< -o $@ -l $(basename $@).lst
	@./show-sizes.sh $(basename $@).lst
	@echo "\033[1;32mCOM build complete: $(COM_OUT) ($$(stat -c%s $@) bytes)\033[0m"
	@echo "\033[1mListing with sizes: $(basename $@).lst\033[0m"
	@echo

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
	@echo "\033[1mCleaning build artifacts...\033[0m"
	rm -f $(LINUX_OUT) $(DOS_OUT) $(COM_OUT) $(SPIRAL_ASM_OBJ_LINUX) $(SPIRAL_ASM_OBJ_DOS) $(DOS_ASM_OBJ) $(LST_OUT)
	@echo "Cleaned build artifacts"
	@echo

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
