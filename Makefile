# Spirward - 256-byte DOS demo

# Project configuration
PROJECT_NAME = spirward
TINYWORK_DIR = tinywork

# Source files
MAIN_SRC = # using default: tinywork/main.c
COM_SRC = # using default: tinywork/main.asm

# General options
DEBUG ?= 0

# Assembly option flags (set NO_VSYNC=1 or SCANLINE=1 to enable)
NO_VSYNC ?= 0
SCANLINE ?= 0
RETURN_TO_DOS ?= 0

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

include $(TINYWORK_DIR)/Makefile.inc
