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

ifneq ($(filter tinywork,$(MAKECMDGOALS)),)
else
ifeq ($(wildcard $(TINYWORK_DIR)/Makefile.inc),)
$(error TinyWork submodule is missing. Run 'make tinywork' or 'git submodule update --init --recursive')
endif
include $(TINYWORK_DIR)/Makefile.inc
endif

.PHONY: tinywork
tinywork:
	@if [ -f "$(TINYWORK_DIR)/Makefile.inc" ]; then \
		echo "TinyWork already initialized"; \
	else \
		git submodule sync --recursive; \
		git submodule update --init --recursive; \
	fi
