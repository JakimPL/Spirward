# Cross-platform Makefile for DOS, Linux, and Windows builds

# Debug mode (set DEBUG=1 to enable)
DEBUG ?= 0

# Assembly options (set NO_VSYNC=1 or SCANLINE=1 to enable)
NO_VSYNC ?= 0
SCANLINE ?= 0
RETURN_TO_DOS ?= 0

# Detect platform
ifeq ($(OS),Windows_NT)
    PLATFORM := Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        PLATFORM := Linux
    endif
endif

# Bin/build directories
BIN_DIR = bin
BUILD_DIR = build

LINUX_BUILD = $(BUILD_DIR)/linux
WINDOWS_BUILD = $(BUILD_DIR)/windows
DOS_BUILD = $(BUILD_DIR)/dos

# Executables
LINUX_OUT = $(BIN_DIR)/spirward-linux
WINDOWS_OUT = $(BIN_DIR)/spirward-windows.exe
DOS_OUT = $(BIN_DIR)/spirward.exe
COM_OUT = $(BIN_DIR)/spirward.com
LST_OUT = spirward.lst

# Source files
MAIN_SRC = main.c
SDL_SRC = video/video_sdl.c
DOS_SRC = video/video_dos.c
M32_SRC = core/m32.asm
COM_SRC = main.asm

# Object files (in build subdirectories)
M32_OBJ_LINUX = $(LINUX_BUILD)/m32.o
M32_OBJ_WINDOWS = $(WINDOWS_BUILD)/m32.o
M32_OBJ_DOS = $(DOS_BUILD)/m32.o

# Compilers
CC_LINUX = gcc
CC_WINDOWS = i686-w64-mingw32-gcc
CC_DOS = i586-pc-msdosdjgpp-gcc
ASM = nasm

# Check if DOS compiler is available
DJGPP_AVAILABLE := $(shell command -v $(CC_DOS) 2>/dev/null)

# Base flags
CFLAGS_BASE = -Wall -Wextra -mno-sse -mfpmath=387 -ffast-math -fno-math-errno
ASMFLAGS_BASE =

# Debug flags
ifeq ($(DEBUG),1)
    CFLAGS_DEBUG = -g -O0
    ASMFLAGS_DEBUG_LINUX = -g -F dwarf
    ASMFLAGS_DEBUG_WINDOWS = -g -F cv8
    ASMFLAGS_DEBUG_DOS = -g
else
    CFLAGS_DEBUG = -O2
    ASMFLAGS_DEBUG_LINUX =
    ASMFLAGS_DEBUG_WINDOWS =
    ASMFLAGS_DEBUG_DOS =
endif

# Assembly option flags
ASMFLAGS_OPTIONS =
ifeq ($(NO_VSYNC),1)
    ASMFLAGS_OPTIONS += -DNO_VSYNC
endif
ifeq ($(SCANLINE),1)
    ASMFLAGS_OPTIONS += -DSCANLINE
endif
ifeq ($(RETURN_TO_DOS),1)
    ASMFLAGS_OPTIONS += -DRETURN_TO_DOS
endif

# Platform-specific flags
CFLAGS_LINUX = $(CFLAGS_BASE) $(CFLAGS_DEBUG) -Ispiral -Ivideo -m32
CFLAGS_WINDOWS = $(CFLAGS_BASE) $(CFLAGS_DEBUG) -Ispiral -Ivideo -m32
CFLAGS_DOS = $(CFLAGS_BASE) $(CFLAGS_DEBUG) -Ispiral -Ivideo
ASMFLAGS_LINUX = -f elf32 $(ASMFLAGS_DEBUG_LINUX) $(ASMFLAGS_OPTIONS) -DLINUX
ASMFLAGS_WINDOWS = -f win32 --prefix _ $(ASMFLAGS_DEBUG_WINDOWS) $(ASMFLAGS_OPTIONS) -DWINDOWS
ASMFLAGS_DOS = -f coff --prefix _ $(ASMFLAGS_DEBUG_DOS) $(ASMFLAGS_OPTIONS) -DDOS
ASMFLAGS_COM = -f bin $(ASMFLAGS_OPTIONS) -DDOS -DCOM

# Libraries
LDFLAGS_LINUX = -lSDL2 -lm
LDFLAGS_WINDOWS = -lmingw32 -lSDL2main -lSDL2 -lm -mwindows
LDFLAGS_DOS = -lm

# Default target (builds for current platform + DOS + COM)
.PHONY: all
ifeq ($(PLATFORM),Windows)
all: clean windows dos com
else ifeq ($(PLATFORM),Linux)
all: clean linux dos com
else
all: clean linux windows dos com
endif

# All targets (cross-platform)
.PHONY: all-targets
all-targets: clean linux windows dos com

# Create build directories
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(LINUX_BUILD):
	@mkdir -p $(LINUX_BUILD)

$(WINDOWS_BUILD):
	@mkdir -p $(WINDOWS_BUILD)

$(DOS_BUILD):
	@mkdir -p $(DOS_BUILD)

# Assembly object file rules
$(M32_OBJ_LINUX): $(M32_SRC) | $(LINUX_BUILD)
	@echo "\033[1mAssembling $(M32_SRC) for Linux...\033[0m"
	$(ASM) $(ASMFLAGS_LINUX) -o $@ $<

$(M32_OBJ_WINDOWS): $(M32_SRC) | $(WINDOWS_BUILD)
	@echo "\033[1mAssembling $(M32_SRC) for Windows...\033[0m"
	$(ASM) $(ASMFLAGS_WINDOWS) -o $@ $<

$(M32_OBJ_DOS): $(M32_SRC) | $(DOS_BUILD)
	@echo "\033[1mAssembling $(M32_SRC) for DOS...\033[0m"
	$(ASM) $(ASMFLAGS_DOS) -o $@ $<

# Linux build (SDL2)
.PHONY: linux
linux: $(LINUX_OUT)

$(LINUX_OUT): $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_LINUX) | $(BIN_DIR)
	@echo "\033[1;34m==> Building for Linux (SDL2)\033[0m"
	$(CC_LINUX) $(CFLAGS_LINUX) -o $@ $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_LINUX) $(LDFLAGS_LINUX)
	@echo "\033[1;32mLinux build complete: $(LINUX_OUT)\033[0m"
	@echo

# Windows build (MinGW32)
.PHONY: windows
windows: $(WINDOWS_OUT)

$(WINDOWS_OUT): $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_WINDOWS) | $(BIN_DIR)
	@echo "\033[1;36m==> Building for Windows (MinGW32 + SDL2)\033[0m"
	$(CC_WINDOWS) $(CFLAGS_WINDOWS) -o $@ $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_WINDOWS) $(LDFLAGS_WINDOWS)
	@echo "\033[1;32mWindows build complete: $(WINDOWS_OUT)\033[0m"
	@echo

# DOS build (DJGPP), optional
.PHONY: dos
dos:
ifeq ($(DJGPP_AVAILABLE),)
	@echo "\033[1;33mWarning: DJGPP compiler ($(CC_DOS)) not found\033[0m"
	@echo "Skipping DOS build. Install DJGPP cross-compiler to build DOS target."
	@echo
else
	@$(MAKE) $(DOS_OUT)
endif

$(DOS_OUT): $(MAIN_SRC) $(DOS_SRC) $(M32_OBJ_DOS) | $(BIN_DIR)
	@echo "\033[1;35m==> Building for DOS (DJGPP)\033[0m"
	$(CC_DOS) $(CFLAGS_DOS) -o $@ $(MAIN_SRC) $(DOS_SRC) $(M32_OBJ_DOS) $(LDFLAGS_DOS)
	@echo "\033[1;32mDOS build complete: $(DOS_OUT)\033[0m"
	@echo

# COM build (Assembly only)
.PHONY: com
com: $(COM_OUT)

$(COM_OUT): $(COM_SRC) | $(BIN_DIR)
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

# Run platform-specific build
.PHONY: run
ifeq ($(PLATFORM),Windows)
run: windows
	$(WINDOWS_OUT)
else
run: linux
	$(LINUX_OUT)
endif

# Clean build artifacts
.PHONY: clean
clean:
	@echo "\033[1mCleaning build artifacts...\033[0m"
	rm -rf $(BUILD_DIR)
	rm -f $(LINUX_OUT) $(WINDOWS_OUT) $(DOS_OUT) $(COM_OUT) $(LST_OUT)
	@echo "Cleaned build artifacts"
	@echo

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make linux       - Build for Linux with SDL2"
	@echo "  make windows     - Build for Windows with MinGW32 and SDL2"
	@echo "  make dos         - Cross-compile for DOS with DJGPP"
	@echo "  make com         - Assemble standalone .com file"
	@echo "  make sizes       - Show instruction sizes from .lst file"
	@echo "  make run         - Build and run platform-specific executable"
	@echo "  make clean       - Remove build artifacts"
	@echo "  make all         - Build for current platform + COM (auto-detected)"
	@echo "  make all-targets - Build all targets (cross-platform)"
	@echo ""
	@echo "Debug mode:"
	@echo "  make DEBUG=1 linux      - Build Linux version with debug symbols"
	@echo "  make DEBUG=1 windows    - Build Windows version with debug symbols"
	@echo "  make DEBUG=1 all        - Build platform-specific with debug symbols"
	@echo "  make DEBUG=1 all-targets - Build all targets with debug symbols"
	@echo ""
	@echo "Assembly options:"
	@echo "  make NO_VSYNC=1 com          - Build COM file without VSync"
	@echo "  make SCANLINE=1 linux        - Build with scanline rendering (thinner spiral)"
	@echo "  make RETURN_TO_DOS=1 com     - Build COM with graceful exit to text mode"
	@echo "  See Makefile for all available assembly options"
