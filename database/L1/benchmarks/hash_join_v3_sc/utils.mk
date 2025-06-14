#
# Copyright 2019-2022 Xilinx, Inc.
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
# vitis makefile-generator v2.0.7
#
#+-------------------------------------------------------------------------------
# The following parameters are assigned with default values. These parameters can
# be overridden through the make command line
#+-------------------------------------------------------------------------------

REPORT := no
PROFILE := no
DEBUG := no

#'estimate' for estimate report generation
#'system' for system report generation
ifneq ($(REPORT), no)
VPP_LDFLAGS += --report estimate
VPP_LDFLAGS += --report system
endif

#Generates profile summary report
ifeq ($(PROFILE), yes)
VPP_LDFLAGS += --profile_kernel data:all:all:all
endif

#Generates debug summary report
ifeq ($(DEBUG), yes)
VPP_LDFLAGS += --dk protocol:all:all:all
endif

#Check environment setup
ifndef XILINX_VITIS
  XILINX_VITIS = /opt/xilinx/$(TOOL_VERSION)/Vitis
  export XILINX_VITIS
endif
ifndef XILINX_XRT
  XILINX_XRT = /opt/xilinx/xrt
  export XILINX_XRT
endif

.PHONY: check_device
check_device:
	@set -eu; \
	inallowlist=False; \
	inblocklist=False; \
	for dev in $(PLATFORM_ALLOWLIST); \
	    do if [[ $$(echo $(PLATFORM_NAME) | grep $$dev) != "" ]]; \
		then inallowlist=True; fi; \
	done ;\
	for dev in $(PLATFORM_BLOCKLIST); \
	    do if [[ $$(echo $(PLATFORM_NAME) | grep $$dev) != "" ]]; \
		then inblocklist=True; fi; \
	done ;\
	if [[ $$inallowlist == False ]]; \
	    then echo "[Warning]: The device $(PLATFORM_NAME) not in allowlist."; \
	fi; \
	if [[ $$inblocklist == True ]]; \
	    then echo "[ERROR]: The device $(PLATFORM_NAME) in blocklist."; exit 1;\
	fi;

#get HOST_ARCH by PLATFORM
ifneq (,$(PLATFORM))
HOST_ARCH_temp = $(shell platforminfo -p $(PLATFORM) | grep 'CPU Type' | sed 's/.*://' | sed '/ai_engine/d' | sed 's/^[[:space:]]*//')
ifeq ($(HOST_ARCH_temp), x86)
HOST_ARCH := x86
else ifeq ($(HOST_ARCH_temp), cortex-a9)
HOST_ARCH := aarch32
else ifneq (,$(findstring cortex-a, $(HOST_ARCH_temp)))
HOST_ARCH := aarch64
endif
endif


# Special processing for tool version/platform type
VITIS_VER = $(shell v++ --version | grep 'v++' | sed 's/^[[:space:]]*//' | sed -e 's/^[*]* v++ v//g' | cut -d " " -f1)
# 1) for versal flow from 2022.1
DEVICE_TYPE = $(shell platforminfo -p $(PLATFORM) | grep 'FPGA Family' | sed 's/.*://' | sed '/ai_engine/d' | sed 's/^[[:space:]]*//')
ifeq ($(DEVICE_TYPE), versal)
ifeq ($(shell expr $(VITIS_VER) \>= 2022.1), 1)
LINK_TARGET_FMT := xsa
else
LINK_TARGET_FMT := xclbin
endif
else
LINK_TARGET_FMT := xclbin
endif
# 2) dfx flow
dfx_hw := off
ifeq ($(findstring _dfx_, $(PLATFORM_NAME)),_dfx_)
ifeq ($(TARGET),hw)
dfx_hw := on
endif
endif

#Checks for Device Family
ifeq ($(HOST_ARCH), aarch32)
	DEV_FAM = 7Series
else ifeq ($(HOST_ARCH), aarch64)
	DEV_FAM = Ultrascale
endif

#Checks for Correct architecture
ifneq ($(HOST_ARCH), $(filter $(HOST_ARCH),aarch64 aarch32 x86))
$(error HOST_ARCH variable not set, please set correctly and rerun)
endif

.PHONY: check_version check_sysroot check_kimage check_rootfs
check_version:
ifneq (, $(shell which git))
ifneq (,$(wildcard $(XFLIB_DIR)/.git))
	@cd $(XFLIB_DIR) && git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 1 && cd -
endif
endif

#Set/Check SYSROOT/K_IMAGE/ROOTFS
ifneq ($(HOST_ARCH), x86)
ifneq (,$(findstring zc706, $(PLATFORM_NAME)))
K_IMAGE ?= $(SYSROOT)/../../uImage
else
K_IMAGE ?= $(SYSROOT)/../../Image
endif
ROOTFS ?= $(SYSROOT)/../../rootfs.ext4
endif

check_sysroot:
ifneq ($(HOST_ARCH), x86)
ifeq (,$(wildcard $(SYSROOT)))
	$(error SYSROOT ENV variable is not set, please set ENV variable correctly and rerun)
endif
endif
check_kimage:
ifneq ($(HOST_ARCH), x86)
ifeq (,$(wildcard $(K_IMAGE)))
	$(error K_IMAGE ENV variable is not set, please set ENV variable correctly and rerun)
endif
endif
check_rootfs:
ifneq ($(HOST_ARCH), x86)
ifeq (,$(wildcard $(ROOTFS)))
	$(error ROOTFS ENV variable is not set, please set ENV variable correctly and rerun)
endif
endif

#Checks for g++
ifeq ($(HOST_ARCH), x86)
X86_CXX := true
else
ifeq ($(ps_on_x86), true)
X86_CXX := true
endif
endif

CXX := g++
ifeq ($(X86_CXX), true)
ifeq ($(shell expr $(VITIS_VER) \>= 2022.1), 1)
CXX_VER := 8.3.0
else
CXX_VER := 6.2.0
endif
CXX_V := $(shell echo $(CXX_VER) | awk -F. '{print tolower($$1)}')
ifneq ($(shell expr $(shell echo "__GNUG__" | g++ -E -x c++ - | tail -1) \>= $(CXX_V)), 1)
ifndef XILINX_VIVADO
$(error [ERROR]: g++ version too old. Please use $(CXX_VER) or above)
else
CXX := $(XILINX_VIVADO)/tps/lnx64/gcc-$(CXX_VER)/bin/g++
ifeq ($(LD_LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(XILINX_VIVADO)/tps/lnx64/gcc-$(CXX_VER)/lib64
else
export LD_LIBRARY_PATH := $(XILINX_VIVADO)/tps/lnx64/gcc-$(CXX_VER)/lib64:$(LD_LIBRARY_PATH)
endif
$(warning [WARNING]: g++ version too old. Using g++ provided by the tool: $(CXX))
endif
endif
else 
ifeq ($(HOST_ARCH), aarch64)
CXX := $(XILINX_VITIS)/gnu/aarch64/lin/aarch64-linux/bin/aarch64-linux-gnu-g++
else ifeq ($(HOST_ARCH), aarch32)
CXX := $(XILINX_VITIS)/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-g++
endif
endif

#Check OS and setting env for xrt c++ api
OSDIST = $(shell lsb_release -i |awk -F: '{print tolower($$2)}' | tr -d ' \t' )
OSREL = $(shell lsb_release -r |awk -F: '{print tolower($$2)}' |tr -d ' \t')

# for centos and redhat
ifneq ($(findstring centos,$(OSDIST)),)
ifeq (7,$(shell echo $(OSREL) | awk -F. '{print tolower($$1)}' ))
ifeq ($(HOST_ARCH), x86)
XRT_CXXFLAGS += -D_GLIBCXX_USE_CXX11_ABI=0
endif
endif
else ifneq ($(findstring redhat,$(OSDIST)),)
ifeq (7,$(shell echo $(OSREL) | awk -F. '{print tolower($$1)}' ))
ifeq ($(HOST_ARCH), x86)
XRT_CXXFLAGS += -D_GLIBCXX_USE_CXX11_ABI=0
endif
endif
endif

#Setting VPP
VPP := v++

#Cheks for aiecompiler
AIECXX := aiecompiler
AIESIMULATOR := aiesimulator
X86SIMULATOR := x86simulator

.PHONY: check_vivado
check_vivado:
ifeq (,$(wildcard $(XILINX_VIVADO)/bin/vivado))
	@echo "Cannot locate Vivado installation. Please set XILINX_VIVADO variable." && false
endif

.PHONY: check_vpp
check_vpp:
ifeq (,$(wildcard $(XILINX_VITIS)/bin/v++))
	@echo "Cannot locate Vitis installation. Please set XILINX_VITIS variable." && false
endif

.PHONY: check_xrt
check_xrt:
ifeq (,$(wildcard $(XILINX_XRT)/lib/libxilinxopencl.so))
	@echo "Cannot locate XRT installation. Please set XILINX_XRT variable." && false
endif

export PATH := $(XILINX_VITIS)/bin:$(XILINX_XRT)/bin:$(PATH)
ifeq ($(HOST_ARCH), x86)
ifeq (,$(LD_LIBRARY_PATH))
LD_LIBRARY_PATH := $(XILINX_XRT)/lib
else
LD_LIBRARY_PATH := $(XILINX_XRT)/lib:$(LD_LIBRARY_PATH)
endif
endif

ifneq (,$(wildcard $(PLATFORM)))
# Use PLATFORM as a file path
XPLATFORM := $(PLATFORM)
else
# Use PLATFORM as a file name pattern
# 1. search paths specified by variable
ifneq (,$(PLATFORM_REPO_PATHS))
# 1.1 as exact name
XPLATFORM := $(strip $(foreach p, $(subst :, ,$(PLATFORM_REPO_PATHS)), $(wildcard $(p)/$(PLATFORM)/$(PLATFORM).xpfm)))
# 1.2 as a pattern
ifeq (,$(XPLATFORM))
XPLATFORMS := $(foreach p, $(subst :, ,$(PLATFORM_REPO_PATHS)), $(wildcard $(p)/*/*.xpfm))
XPLATFORM := $(strip $(foreach p, $(XPLATFORMS), $(shell echo $(p) | awk '$$1 ~ /$(PLATFORM)/')))
endif # 1.2
endif # 1
# 2. search Vitis installation
ifeq (,$(XPLATFORM))
# 2.1 as exact name
XPLATFORM := $(strip $(wildcard $(XILINX_VITIS)/platforms/$(PLATFORM)/$(PLATFORM).xpfm))
# 2.2 as a pattern
ifeq (,$(XPLATFORM))
XPLATFORMS := $(wildcard $(XILINX_VITIS)/platforms/*/*.xpfm)
XPLATFORM := $(strip $(foreach p, $(XPLATFORMS), $(shell echo $(p) | awk '$$1 ~ /$(PLATFORM)/')))
endif # 2.2
endif # 2
# 3. search default locations
ifeq (,$(XPLATFORM))
# 3.1 as exact name
XPLATFORM := $(strip $(wildcard /opt/xilinx/platforms/$(PLATFORM)/$(PLATFORM).xpfm))
# 3.2 as a pattern
ifeq (,$(XPLATFORM))
XPLATFORMS := $(wildcard /opt/xilinx/platforms/*/*.xpfm)
XPLATFORM := $(strip $(foreach p, $(XPLATFORMS), $(shell echo $(p) | awk '$$1 ~ /$(PLATFORM)/')))
endif # 3.2
endif # 3
endif

define MSG_PLATFORM
No platform matched pattern '$(PLATFORM)'.
Available platforms are: $(XPLATFORMS)
To add more platform directories, set the PLATFORM_REPO_PATHS variable or point PLATFORM variable to the full path of platform .xpfm file.
endef
export MSG_PLATFORM


.PHONY: check_platform
check_platform:
ifeq (,$(XPLATFORM))
	@echo "$${MSG_PLATFORM}" && false
endif
#Check ends

#   device2xsa - create a filesystem friendly name from device name
#   $(1) - full name of device
PLATFORM_NAME = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))


# Cleaning stuff
RM = rm -f
RMDIR = rm -rf

MV = mv -f
CP = cp -rf
ECHO:= @echo
