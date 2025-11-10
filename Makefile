############################################################################
#
# (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
# 
# Project: https://github.com/egnagflow/vmon
# License: https://github.com/egnagflow/vmon/blob/main/LICENSE
#
############################################################################

PLATFORM     ?= vic20
TARGET       ?= unexpanded
IMAGE_SUFFIX ?= prg

IMAGE = $(PLATFORM)_$(TARGET)

SRC_DIR     = src
GEN_DIR     = gen
TARGETS_DIR = targets
IMAGES_DIR  = images

TARGET_CONFIG     = $(TARGETS_DIR)/$(PLATFORM)/$(TARGET).cfg
TARGET_CONFIG_GEN = $(GEN_DIR)/target.h

# Get platform and target specific make rules, if they exist.
-include $(TARGETS_DIR)/$(PLATFORM)/$(TARGET).mk

INCLUDES = \
		   -I $(GEN_DIR) \
		   -I $(SRC_DIR) \
		   -I $(SRC_DIR)/$(PLATFORM) \
		   -I $(TARGETS_DIR) \
		   -I $(TARGETS_DIR)/$(PLATFORM)

SRCS = \
	$(SRC_DIR)/prg_header.s \
	$(SRC_DIR)/basic_header.s \
	$(SRC_DIR)/mon_relocate.s \
	\
	$(SRC_DIR)/main.s \
	$(SRC_DIR)/example_code.s \
	$(SRC_DIR)/screen.s \
	$(SRC_DIR)/screen_memmap.s \
	$(SRC_DIR)/shared_vars.s \
	$(SRC_DIR)/print_registers.s \
	$(SRC_DIR)/print_disassembly.s \
	$(SRC_DIR)/print_mem_dump.s \
	$(SRC_DIR)/keyscan.s \
	$(SRC_DIR)/key_handler.s \
	$(SRC_DIR)/key_handler_common.s \
	$(SRC_DIR)/key_handler_color.s \
	$(SRC_DIR)/key_handler_display.s \
	$(SRC_DIR)/key_handler_exec.s \
	$(SRC_DIR)/key_handler_go.s \
	$(SRC_DIR)/key_handler_help.s \
	$(SRC_DIR)/key_handler_memop.s \
	$(SRC_DIR)/key_handler_nav.s \
	$(SRC_DIR)/key_handler_quit.s \
	$(SRC_DIR)/key_handler_regs.s \
	$(SRC_DIR)/key_handler_screen.s \
	$(SRC_DIR)/opcode_6502.s \
	$(SRC_DIR)/opcode_exec.s \
	$(SRC_DIR)/brk.s \
	$(SRC_DIR)/init_vars.s \
	$(SRC_DIR)/hexin.s \
	$(SRC_DIR)/hexout.s \
	$(SRC_DIR)/mem_access.s \
	$(SRC_DIR)/io.s \
	\
	$(SRC_DIR)/$(PLATFORM)/screen.s

ifneq ($(wildcard $(SRC_DIR)/$(PLATFORM)/keyscan.s),)
	SRCS += $(SRC_DIR)/$(PLATFORM)/keyscan.s
endif
ifneq ($(wildcard $(SRC_DIR)/$(PLATFORM)/cartridge.s),)
	SRCS += $(SRC_DIR)/$(PLATFORM)/cartridge.s
endif

OBJS = ${SRCS:s=o}

PRG = $(IMAGES_DIR)/$(IMAGE).$(IMAGE_SUFFIX)
LBL = $(IMAGES_DIR)/$(IMAGE).lbl
CRT = $(IMAGES_DIR)/$(PLATFORM)_$(TARGET).crt

all: info $(PRG)

crt: info $(PRG)
	@cartconv -p -i $(PRG) -o $(CRT) -t $(CARTRIDGE_TYPE) -l $(CARTRIDGE_ADDRESS) >/dev/null

info:
	@echo "##### Building $(PLATFORM) $(TARGET) #####"

target-include: gen-dir
	@echo '; Generated file. DO NOT EDIT.' > $(TARGET_CONFIG_GEN)
	@echo '.ifndef _TARGET_CONFIG_H_' >> $(TARGET_CONFIG_GEN)
	@echo '.include "$(TARGET)_config.h"' >> $(TARGET_CONFIG_GEN)
	@echo '.include "defaults.h"' >> $(TARGET_CONFIG_GEN)
	@echo '.include "system.h"' >> $(TARGET_CONFIG_GEN)
	@echo '_TARGET_CONFIG_H_ := 1' >> $(TARGET_CONFIG_GEN)
	@echo '.endif' >> $(TARGET_CONFIG_GEN)

build-dir:
	@mkdir -p $(IMAGES_DIR)

gen-dir:
	@mkdir -p $(GEN_DIR)

$(OBJS): %.o: %.s
	@ca65 -U $(INCLUDES) $< -o $@

$(PRG): target-include build-dir $(OBJS)
	@ld65 -C $(TARGET_CONFIG) -o $(PRG) -Ln $(LBL) $(OBJS)

clean:
	@rm -rf $(OBJS) $(PRG) $(LBL) $(TARGET_CONFIG_GEN)

mrproper: clean
	@rm -rf $(IMAGES_DIR) $(GEN_DIR)
