# Copyright (C) 2019-2022, Xilinx, Inc.
# Copyright (C) 2022-2025, Advanced Micro Devices, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# vitis makefile-generator v2.0.9

############################## Help Section ##############################
.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<aiesim> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<aiesim> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""

############################## Setting up Project Variables ##############################

MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
XF_PROJ_ROOT ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo $${MK_PATH%/L2/*}')
CUR_DIR := $(patsubst %/,%,$(dir $(MK_PATH)))
XFLIB_DIR = $(XF_PROJ_ROOT)

# setting default value
TARGET ?= aiesim

# #################### Checking if PLATFORM in whitelist ############################
PLATFORM_ALLOWLIST += vck190
PLATFORM_BLOCKLIST += 

include ./utils.mk
TEMP_DIR := _x_temp.$(TARGET).$(PLATFORM_NAME)
TEMP_REPORT_DIR := $(CUR_DIR)/reports/_x.$(TARGET).$(PLATFORM_NAME)
BUILD_DIR := build_dir.$(TARGET).$(PLATFORM_NAME)
ifneq ($(RESULT_DIR),)
BUILD_DIR = $(RESULT_DIR)
endif
BUILD_REPORT_DIR := $(CUR_DIR)/reports/_build.$(TARGET).$(PLATFORM_NAME)

RUN_DEPS :=

# aie template
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include

AIE_WORK_DIR ?= Work
AIE_PKG_DIR ?= Work

# Setting customized_params in aiecompiler

    
GRAPHNAME ?= FFT_fe3e094c
VMC_GRAPHDIR ?= xmc_aie_lib/$(GRAPHNAME)
VMC_KERNEL ?= vmc_fft

############################ setting AIE Compiler ###########################
ifneq ($(filter aiesim , $(TARGET)),)
AIETARGET := hw
else
AIETARGET := x86sim
endif

ifeq (,$(PLATFORM)) 
AIE_CXXFLAGS += --part=$(XPLATFORM)
else
AIE_CXXFLAGS += --platform=$(XPLATFORM)
endif

AIE_CXXFLAGS += --target=$(AIETARGET)    --aie.pl-freq 1000 
AIE_CXXFLAGS += $(AIE_CXXFLAGS_INC)
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_WORK_DIR = $(CUR_DIR)/Work
AIE_PKG_DIR = $(AIE_WORK_DIR)

AIE_CXXFLAGS += -I $(XFLIB_DIR)/L1/include/aie -I $(XFLIB_DIR)/L1/src/aie -I $(XFLIB_DIR)/L1/tests/aie/inc -I $(XFLIB_DIR)/L1/tests/aie/src -I $(XFLIB_DIR)/L2/include/aie -I $(XFLIB_DIR)/L2/meta/vmc/vmc_test/DDS/$(VMC_GRAPHDIR) -I $(XFLIB_DIR)/L2/tests/aie/common/inc -I $(CUR_DIR)
AIE_CXXFLAGS += --aie.Xchess=llvm.xargs=-std=c++2a --aie.Xx86sim=-client=vmc --aie.verbose

AIESIMFLAGS += $(EXTRA_AIESIMFLAGS)

############################## Setting Rules for AIE (Building Kernels) ##################
$(AIE_CONTAINER): pre_build $(VMC_GRAPHDIR)/$(GRAPHNAME).cpp $(XFLIB_DIR)/L1/src/aie/fft_ifft_dit_1ch.cpp 
	$(ECHO) "Compiling: libadf.a"
	mkdir -p $(dir $@)
	$(VPP) -c --mode aie $(AIE_CXXFLAGS) -o $@ $(filter %.s %.c %.cc %.cpp %cxx, $^)

############################## Setting Essential Checks and Building Rules ##############################
ifneq (,$(filter x86sim aiesim, $(TARGET)))
RUN_DEPS += $(AIE_CONTAINER)
endif

.PHONY: mkflag all run
mkflag:
	mkdir -p $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/makefile_args.txt
	@for var in $(MAKEFLAGS); do echo $$var >> $(BUILD_DIR)/makefile_args.txt; done

all: check_device check_vpp check_platform mkflag $(RUN_DEPS)

run: all
#x86sim
ifeq ($(TARGET), x86sim)
	$(X86SIMULATOR) --pkg-dir=$(AIE_PKG_DIR)     
endif
#aiesim
ifeq ($(TARGET), aiesim)
	$(AIESIMULATOR) --pkg-dir=$(AIE_PKG_DIR) --profile --simulation-cycle-timeout=100     $(AIESIMFLAGS) 
	grep 'Compilation Complete' ./AIECompiler.log || exit 1
endif

############################## Setting Targets ##############################
.PHONY: pre_build
pre_build:
	vitis --classic -exec ipmetadata_config_checker -newflow -metadata_path $(XFLIB_DIR)/L2/meta/ $(XFLIB_DIR)/L2/meta/vmc/$(VMC_KERNEL).json ./config.json
	perl $(XFLIB_DIR)/L2/tests/aie/common/scripts/compare_json.pl ref_out.json ./xmc_aie_lib/$(GRAPHNAME)/out.json | grep 'Files are identical' || exit 1

.PHONY: clean cleanall valid_params

#################### Parameterized File Generation ##########################

gen_instances: $(GENERATED_FILES)

############################## Cleaning Rules ##############################
clean:
		rm -rf $(BUILD_DIR)/* _x*  Work *simulator_output .AIE_SIM_CMD_LINE_OPTIONS sol.db memconfig.json *.aierun_summary *.csv 
		rm -rf $(CUR_DIR)/reports  *.html $(GENERATED_FILES)

cleanall: clean
		rm -rf $(AIE_CONTAINER) $(TEMP_DIR)  timelog.txt *.log QoR.json SIM-* HV_* profile_funct_* profile_instr_* PASS FAIL

ultraclean: cleanall
		rm -rf data*