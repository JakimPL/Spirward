# Spirward - 256-byte DOS demo

# Project configuration
PROJECT_NAME = spirward
FRAMEWORK_DIR = framework

# Source files
MAIN_SRC = main.c
M32_SRC = core/m32.asm
COM_SRC = main.asm

# Demo-specific includes
EXTRA_INCLUDES = -Ispiral

# Debug mode (set DEBUG=1 to enable)
DEBUG ?= 0

# Assembly options (set NO_VSYNC=1 or SCANLINE=1 to enable)
NO_VSYNC ?= 0
SCANLINE ?= 0
RETURN_TO_DOS ?= 0

# Build assembly option flags
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

# Include framework build rules
include $(FRAMEWORK_DIR)/Makefile.inc

# Demo-specific targets
FLATTEN_ASM = $(FRAMEWORK_DIR)/scripts/flatten-asm.py

.PHONY: code
code:
	@echo "$(COLOR_BOLD)Generating flattened assembly code...$(COLOR_RESET)"
	@python3 $(FLATTEN_ASM)
	@echo
