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
	$(ECHO) "  make all TARGET=<aiesim/x86sim> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<aiesim/x86sim> PLATFORM=<FPGA platform>"
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
PARAMS ?= test_0_tool_canary_aie
PARAMS_FILE ?= multi_params.json 

# #################### Checking if PLATFORM in whitelist ############################
PLATFORM_ALLOWLIST += vck190 vek280 xcvr1602-vsva2488-2LP-e-S-es1 xc2ve3858-ssva2112-2LP-e-S
PLATFORM_BLOCKLIST += 

include ./utils.mk
TEMP_DIR := _x_temp.$(TARGET).$(PLATFORM_NAME)
TEMP_REPORT_DIR := $(CUR_DIR)/reports/_x.$(TARGET).$(PLATFORM_NAME)
BUILD_DIR := build_dir.$(TARGET).$(PLATFORM_NAME)
ifneq ($(RESULT_DIR),)
BUILD_DIR = $(RESULT_DIR)
endif
BUILD_REPORT_DIR := $(CUR_DIR)/reports/_build.$(TARGET).$(PLATFORM_NAME)

include $(XFLIB_DIR)/L2/tests/aie/common/scripts/params.mk

RUN_DEPS :=

# aie template
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include

AIE_WORK_DIR ?= Work
AIE_PKG_DIR ?= Work

# Setting customized_params in aiecompiler

ifneq (,$(shell echo $(XPLATFORM) | awk '/xcvr1602-vsva2488-2LP-e-S-es1/'))
            
COMPILER_ARGS ?= 
AIE_VARIANT ?= 1
FIFO_THRESHOLD ?=  
TAG ?= UUT
UUT_KERNEL ?= widget_api_cast
REF_KERNEL ?= widget_api_cast_ref
UUT_GRAPH ?= widget_api_cast_graph
REF_GRAPH ?= widget_api_cast_ref_graph
UUT_SIM_FILE ?= ./data/uut_output.txt
REF_SIM_FILE ?= ./data/ref_output.txt
UUT_SIM_FILE2 ?= ./data/uut_output_2.txt
REF_SIM_FILE2 ?= ./data/ref_output_2.txt
UUT_WINDOW_VSIZE ?= WINDOW_VSIZE
REF_WINDOW_VSIZE ?= $$((WINDOW_VSIZE*2))
DIFF_TOLERANCE ?= 0
CC_TOLERANCE ?= 0
LOC_INPUT_FILE ?= ./data/input.txt
UUT_TARGET_COMPILE_ARGS ?= --aie.Xchess=llvm.xargs="-std=c++2a" --aie.Xchess=main:backend.mist2.xargs="+NOdra"  --aie.Xchess=main:backend.mist2.pnll="off" 
REF_TARGET_COMPILE_ARGS ?= 
PREPROC_ARGS ?= --aie.Xpreproc=-DINPUT_FILE=$(LOC_INPUT_FILE)
USING_REF ?= 
USING_UUT ?= --aie.Xpreproc=-DUSING_UUT=1
TAG_PREPROC_ARGS ?= --aie.Xpreproc=-DUUT_GRAPH=$($(TAG)_GRAPH) --aie.Xpreproc=-DOUTPUT_FILE=$($(TAG)_SIM_FILE) --aie.Xpreproc=-DOUTPUT_FILE2=$($(TAG)_SIM_FILE2) $(PREPROC_ARGS) $(USING_$(TAG))

else ifneq (,$(shell echo $(XPLATFORM) | awk '/xc2ve3858-ssva2112-2LP-e-S/'))
            
COMPILER_ARGS ?=  --aie.Xpreproc=-D_AIE_API_WORKAROUND_CR_1223259_=1
AIE_VARIANT ?= 22
FIFO_THRESHOLD ?= --aie.swfifo-threshold=120 
TAG ?= UUT
UUT_KERNEL ?= widget_api_cast
REF_KERNEL ?= widget_api_cast_ref
UUT_GRAPH ?= widget_api_cast_graph
REF_GRAPH ?= widget_api_cast_ref_graph
UUT_SIM_FILE ?= ./data/uut_output.txt
REF_SIM_FILE ?= ./data/ref_output.txt
UUT_SIM_FILE2 ?= ./data/uut_output_2.txt
REF_SIM_FILE2 ?= ./data/ref_output_2.txt
UUT_WINDOW_VSIZE ?= WINDOW_VSIZE
REF_WINDOW_VSIZE ?= $$((WINDOW_VSIZE*2))
DIFF_TOLERANCE ?= 0
CC_TOLERANCE ?= 0
LOC_INPUT_FILE ?= ./data/input.txt
UUT_TARGET_COMPILE_ARGS ?= --aie.Xchess=llvm.xargs="-std=c++2a" --aie.Xchess=main:backend.mist2.xargs="+NOdra"  --aie.Xchess=main:backend.mist2.pnll="off" 
REF_TARGET_COMPILE_ARGS ?= 
PREPROC_ARGS ?= --aie.Xpreproc=-DINPUT_FILE=$(LOC_INPUT_FILE)
USING_REF ?= 
USING_UUT ?= --aie.Xpreproc=-DUSING_UUT=1
TAG_PREPROC_ARGS ?= --aie.Xpreproc=-DUUT_GRAPH=$($(TAG)_GRAPH) --aie.Xpreproc=-DOUTPUT_FILE=$($(TAG)_SIM_FILE) --aie.Xpreproc=-DOUTPUT_FILE2=$($(TAG)_SIM_FILE2) $(PREPROC_ARGS) $(USING_$(TAG))

else             
TAG ?= UUT
AIE_VARIANT ?= 1
UUT_KERNEL ?= widget_api_cast
REF_KERNEL ?= widget_api_cast_ref
UUT_GRAPH ?= widget_api_cast_graph
REF_GRAPH ?= widget_api_cast_ref_graph
UUT_SIM_FILE ?= ./data/uut_output.txt
REF_SIM_FILE ?= ./data/ref_output.txt
UUT_SIM_FILE2 ?= ./data/uut_output_2.txt
REF_SIM_FILE2 ?= ./data/ref_output_2.txt
UUT_WINDOW_VSIZE ?= WINDOW_VSIZE
REF_WINDOW_VSIZE ?= $$((WINDOW_VSIZE*2))
DIFF_TOLERANCE ?= 0
CC_TOLERANCE ?= 0
LOC_INPUT_FILE ?= ./data/input.txt
UUT_TARGET_COMPILE_ARGS ?= --aie.Xchess=llvm.xargs="-std=c++2a" --aie.Xchess=main:backend.mist2.xargs="+NOdra"  --aie.Xchess=main:backend.mist2.pnll="off" 
REF_TARGET_COMPILE_ARGS ?= 
PREPROC_ARGS ?= --aie.Xpreproc=-DINPUT_FILE=$(LOC_INPUT_FILE)
USING_REF ?= 
USING_UUT ?= --aie.Xpreproc=-DUSING_UUT=1
TAG_PREPROC_ARGS ?= --aie.Xpreproc=-DUUT_GRAPH=$($(TAG)_GRAPH) --aie.Xpreproc=-DOUTPUT_FILE=$($(TAG)_SIM_FILE) --aie.Xpreproc=-DOUTPUT_FILE2=$($(TAG)_SIM_FILE2) $(PREPROC_ARGS) $(USING_$(TAG))

endif
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

AIE_CXXFLAGS += --target=$(AIETARGET)    --aie.pl-freq 625 
AIE_CXXFLAGS += $(AIE_CXXFLAGS_INC)
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_WORK_DIR = $(CUR_DIR)/Work
AIE_PKG_DIR = $(AIE_WORK_DIR)

ifneq (,$(shell echo $(XPLATFORM) | awk '/xcvr1602-vsva2488-2LP-e-S-es1/'))
        
AIE_CXXFLAGS += -I $(XFLIB_DIR)/L1/include/aie -I $(XFLIB_DIR)/L1/src/aie -I $(XFLIB_DIR)/L1/tests/aie/inc -I $(XFLIB_DIR)/L1/tests/aie/src -I $(XFLIB_DIR)/L2/include/aie -I $(XFLIB_DIR)/L2/tests/aie/common/inc -I $(CUR_DIR)
AIE_CXXFLAGS += --aie.verbose $($(TAG)_TARGET_COMPILE_ARGS) $(TAG_PREPROC_ARGS)

else ifneq (,$(shell echo $(XPLATFORM) | awk '/xc2ve3858-ssva2112-2LP-e-S/'))
        
AIE_CXXFLAGS += -I $(XFLIB_DIR)/L1/include/aie -I $(XFLIB_DIR)/L1/src/aie -I $(XFLIB_DIR)/L1/tests/aie/inc -I $(XFLIB_DIR)/L1/tests/aie/src -I $(XFLIB_DIR)/L2/include/aie -I $(XFLIB_DIR)/L2/tests/aie/common/inc -I $(CUR_DIR)
AIE_CXXFLAGS += --aie.verbose $($(TAG)_TARGET_COMPILE_ARGS) $(TAG_PREPROC_ARGS)

else         
AIE_CXXFLAGS += -I $(XFLIB_DIR)/L1/include/aie -I $(XFLIB_DIR)/L1/src/aie -I $(XFLIB_DIR)/L1/tests/aie/inc -I $(XFLIB_DIR)/L1/tests/aie/src -I $(XFLIB_DIR)/L2/include/aie -I $(XFLIB_DIR)/L2/tests/aie/common/inc -I $(CUR_DIR)
AIE_CXXFLAGS += --aie.verbose $($(TAG)_TARGET_COMPILE_ARGS) $(TAG_PREPROC_ARGS)

endif

AIESIMFLAGS += $(EXTRA_AIESIMFLAGS)

############################## Setting Rules for AIE (Building Kernels) ##################
$(AIE_CONTAINER): pre_build test.cpp $(XFLIB_DIR)/L1/src/aie/widget_api_cast.cpp uut_config.h 
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
	$(X86SIMULATOR) --pkg-dir=$(AIE_PKG_DIR) $(if $(filter-out REF,$(TAG)), --valgrind)    
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk ssr_zip HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) SPLIT_ZIP_FILE=./x86simulator_output/data/uut_output.txt")
	$(if $(filter REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk ssr_zip HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) SPLIT_ZIP_FILE=./x86simulator_output/data/ref_output.txt")
	$(if $(filter-out REF,$(TAG)), grep -ve '[XT]' ./x86simulator_output/data/uut_output.txt > ./data/uut_output.txt)
	$(if $(filter REF,$(TAG)), grep -ve '[XT]' ./x86simulator_output/data/ref_output.txt > ./data/ref_output.txt)
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f $(XFLIB_DIR)/L2/tests/aie/common/scripts/fir_helper.mk diff HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR)")
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk get_status HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)")
	$(if $(filter-out REF,$(TAG)), tclsh $(XFLIB_DIR)/L2/tests/aie/common/scripts/diff_exit.tcl ./)
endif
#aiesim
ifeq ($(TARGET), aiesim)
	$(AIESIMULATOR) --pkg-dir=$(AIE_PKG_DIR) --profile --graph-latency     $(AIESIMFLAGS) 
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk ssr_zip HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) SPLIT_ZIP_FILE=./aiesimulator_output/data/uut_output.txt"
	grep -ve '[XT]' ./aiesimulator_output/data/uut_output.txt > ./data/uut_output.txt
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f $(XFLIB_DIR)/L2/tests/aie/common/scripts/fir_helper.mk diff HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR)"
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk get_status HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)"
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk get_latency HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)"
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk get_stats HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)"
	$(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk harvest_mem HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)"
	tclsh $(XFLIB_DIR)/L2/tests/aie/common/scripts/diff_exit.tcl ./
endif

############################## Setting Targets ##############################
.PHONY: pre_build
pre_build:
	 mkdir -p logs
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk get_status HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) UUT_KERNEL=$(UUT_KERNEL)")
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "tclsh $(XFLIB_DIR)/L2/tests/aie/common/scripts/get_common_config_json.tcl ./config.json ./ $(UUT_KERNEL)"  --connector " " --var "DATA_TYPE:IN_API:OUT_API:NUM_INPUTS:WINDOW_VSIZE:NUM_OUTPUT_CLONES:PATTERN:HEADER_BYTES:AIE_VARIANT")
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/meta/scripts/metadata_checker.py --ip $(UUT_KERNEL))
	$(if $(filter-out REF,$(TAG)), # vitis --classic -exec ipmetadata_config_checker $(XFLIB_DIR)/L2/meta/$(UUT_KERNEL).json ./config.json -newflow)
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk gen_input HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) INPUT_FILE=$(LOC_INPUT_FILE) ")
	$(if $(filter-out REF,$(TAG)), $(VITIS_PYTHON3) $(XFLIB_DIR)/L2/tests/aie/common/scripts/paramenv.py --parameter_file $(PARAMS_FILE) --instance_name $(PARAMS) --command "make -f helper.mk ssr_split HELPER_CUR_DIR=$(CUR_DIR) HELPER_ROOT_DIR=$(XFLIB_DIR) INPUT_FILE=$(LOC_INPUT_FILE)")
	$(if $(filter-out REF,$(TAG)), make run TARGET=x86sim TAG=REF)
	$(if $(filter-out REF,$(TAG)), make cleanall)

.PHONY: clean cleanall valid_params

#################### Parameterized File Generation ##########################

GENERATED_FILES += uut_config.h
uut_config.h: $(XFLIB_DIR)/L2/tests/aie/common/scripts/tb_gen.py 
	$(VITIS_PYTHON3) $(XFLIB_DIR)/scripts/instance_generator.py -o uut_config.h --param-set $(PARAMS) --param-file $(PARAMS_FILE) --file "$(XFLIB_DIR)/L2/tests/aie/common/scripts/tb_gen.py" --func "generate_testbench"

.PHONY: valid_params gen_instances

valid_params:

gen_instances: $(GENERATED_FILES)

############################## Cleaning Rules ##############################
clean:
		rm -rf $(BUILD_DIR)/* _x*  Work *simulator_output .AIE_SIM_CMD_LINE_OPTIONS sol.db memconfig.json *.aierun_summary *.csv 
		rm -rf $(CUR_DIR)/reports  *.html $(GENERATED_FILES)

cleanall: clean
		rm -rf $(AIE_CONTAINER) $(TEMP_DIR)  timelog.txt *.log QoR.json SIM-* HV_* profile_funct_* profile_instr_* PASS FAIL

ultraclean: cleanall
		rm -rf data*