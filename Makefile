# Cross-platform Makefile for DOS, Linux, and Windows builds

# Debug mode (set DEBUG=1 to enable)
DEBUG ?= 0

# Assembly options (set NO_VSYNC=1 or SCANLINE=1 to enable)
NO_VSYNC ?= 0
NO_SCANLINE ?= 0
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

# ANSI color codes (disabled for Windows)
ifneq ($(PLATFORM),Windows)
    COLOR_RESET   := \033[0m
    COLOR_BOLD    := \033[1m
    COLOR_BLUE    := \033[1;34m
    COLOR_CYAN    := \033[1;36m
    COLOR_MAGENTA := \033[1;35m
    COLOR_YELLOW  := \033[1;33m
    COLOR_GREEN   := \033[1;32m
else
    COLOR_RESET   :=
    COLOR_BOLD    :=
    COLOR_BLUE    :=
    COLOR_CYAN    :=
    COLOR_MAGENTA :=
    COLOR_YELLOW  :=
    COLOR_GREEN   :=
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

# Scripts
SHOW_SIZES = scripts/show-sizes.sh
FLATTEN_ASM = scripts/flatten-asm.py

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
ifeq ($(NO_SCANLINE),1)
    ASMFLAGS_OPTIONS += -DNO_SCANLINE
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
	@echo "$(COLOR_BOLD)Assembling $(M32_SRC) for Linux...$(COLOR_RESET)"
	$(ASM) $(ASMFLAGS_LINUX) -o $@ $<

$(M32_OBJ_WINDOWS): $(M32_SRC) | $(WINDOWS_BUILD)
	@echo "$(COLOR_BOLD)Assembling $(M32_SRC) for Windows...$(COLOR_RESET)"
	$(ASM) $(ASMFLAGS_WINDOWS) -o $@ $<

$(M32_OBJ_DOS): $(M32_SRC) | $(DOS_BUILD)
	@echo "$(COLOR_BOLD)Assembling $(M32_SRC) for DOS...$(COLOR_RESET)"
	$(ASM) $(ASMFLAGS_DOS) -o $@ $<

# Linux build (SDL2)
.PHONY: linux
linux: $(LINUX_OUT)

$(LINUX_OUT): $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_LINUX) | $(BIN_DIR)
	@echo "$(COLOR_BLUE)==> Building for Linux (SDL2)$(COLOR_RESET)"
	$(CC_LINUX) $(CFLAGS_LINUX) -o $@ $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_LINUX) $(LDFLAGS_LINUX)
	@echo "$(COLOR_GREEN)Linux build complete: $(LINUX_OUT)$(COLOR_RESET)"
	@echo

# Windows build (MinGW32)
.PHONY: windows
windows: $(WINDOWS_OUT)

$(WINDOWS_OUT): $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_WINDOWS) | $(BIN_DIR)
	@echo "$(COLOR_CYAN)==> Building for Windows (MinGW32 + SDL2)$(COLOR_RESET)"
	$(CC_WINDOWS) $(CFLAGS_WINDOWS) -o $@ $(MAIN_SRC) $(SDL_SRC) $(M32_OBJ_WINDOWS) $(LDFLAGS_WINDOWS)
	@echo "$(COLOR_GREEN)Windows build complete: $(WINDOWS_OUT)$(COLOR_RESET)"
	@echo

# DOS build (DJGPP), optional
.PHONY: dos
dos:
ifeq ($(DJGPP_AVAILABLE),)
	@echo "$(COLOR_YELLOW)Warning: DJGPP compiler ($(CC_DOS)) not found$(COLOR_RESET)"
	@echo "Skipping DOS build. Install DJGPP cross-compiler to build DOS target."
	@echo
else
	@$(MAKE) $(DOS_OUT)
endif

$(DOS_OUT): $(MAIN_SRC) $(DOS_SRC) $(M32_OBJ_DOS) | $(BIN_DIR)
	@echo "$(COLOR_MAGENTA)==> Building for DOS (DJGPP)$(COLOR_RESET)"
	$(CC_DOS) $(CFLAGS_DOS) -o $@ $(MAIN_SRC) $(DOS_SRC) $(M32_OBJ_DOS) $(LDFLAGS_DOS)
	@echo "$(COLOR_GREEN)DOS build complete: $(DOS_OUT)$(COLOR_RESET)"
	@echo

# COM build (Assembly only)
.PHONY: com
com: $(COM_OUT)

$(COM_OUT): $(COM_SRC) | $(BIN_DIR)
	@echo "$(COLOR_YELLOW)==> Building COM file (DOS 256b demo)$(COLOR_RESET)"
	$(ASM) $(ASMFLAGS_COM) $< -o $@ -l $(basename $@).lst
	@$(SHOW_SIZES) $(basename $@).lst
	@echo "$(COLOR_GREEN)COM build complete: $(COM_OUT) ($$(stat -c%s $@) bytes)$(COLOR_RESET)"
	@echo "$(COLOR_BOLD)Listing with sizes: $(basename $@).lst$(COLOR_RESET)"
	@echo

# Show instruction sizes from listing
.PHONY: sizes
sizes: com
	@$(SHOW_SIZES) $(basename $(COM_OUT)).lst

# Generate flattened assembly file
.PHONY: code
code:
	@echo "$(COLOR_BOLD)Generating flattened assembly code...$(COLOR_RESET)"
	@python3 $(FLATTEN_ASM)
	@echo

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
	@echo "$(COLOR_BOLD)Cleaning build artifacts...$(COLOR_RESET)"
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
	@echo "  make code        - Generate flattened assembly code (spirward.asm)"
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
