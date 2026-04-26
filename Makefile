# Spirward - 256-byte DOS demo

# Project configuration
PROJECT_NAME = spirward
TINYWORK_DIR = tinywork
SOURCE_DIR = core

# Demo-specific assembly flags
SCANLINE ?= 0

ASMFLAGS_OPTIONS =
ifeq ($(SCANLINE),1)
    ASMFLAGS_OPTIONS += -DSCANLINE
endif

include $(TINYWORK_DIR)/Makefile.inc
