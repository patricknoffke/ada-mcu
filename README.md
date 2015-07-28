# ada-mcu
Ada for Microcontrollers

This software consists of a makefile and patches to enable using the GNAT GPL 2015 Linux-hosted arm-eabi toolchain to build an Ada application for the Atmel SAM4S MCU.

Support is provided for the "ravenscar-full" runtime.  The following packages were added to the ravenscar-full runtime:

* Ada.Streams
* Ada.Tags.Generic_Dispatching_Constructor
* Interfaces.C.Pointers

The "ravenscar-sfp" runtime is also supported.  The following packages were added to the ravenscar-sfp runtime:

* Ada.Streams
* Ada.Tags.Generic_Dispatching_Constructor
* Interfaces.C.Pointers
* Ada.IO.Exceptions

If you do not wish to include these packages, then modify Makefile.hie and build-rts.sh accordingly.

Peripheral support is provided in SAM4S.<peripheral-name> packages.

To build and use the toolchain, perform the following steps:

1.  In your own Makefile, set the variables ROOT_DIR and OUTPUT_DIR.
2.  Place the contents of this repository in $(ROOT_DIR)/toolchain/
3.  Include toolchain.mk in your own makefile.
4.  Download the following files and place them in $(ROOT_DIR)/toolchain/dl:
    - gnat-gpl-2015-arm-elf-linux-bin.tar.gz
    - gnat-gpl-2015-src.tar.gz
    - bb-runtimes-gpl-2015-src.tar.gz
    - gcc-4.9-gpl-2015-src.tar.gz
5.  Add a rule to your own Makefile to build the toolchain.  For example:

ROOT_DIR = $(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
OUTPUT_DIR = $(ROOT_DIR)/output

include toolchain/*.mk

  all: $(TOOLCHAIN) $(MY_EXE)

6.  Add a rule to your own Makefile to build your application with this toolchain.  For example, if you are using a gpr project, then:

OBJ_DIR := obj
GPRCONFIG := $(TOOLCHAIN_DIR)/gnat/bin/gprconfig
GPRBUILD := $(TOOLCHAIN_DIR)/gnat/bin/gprbuild
GPRCLEAN := $(TOOLCHAIN_DIR)/gnat/bin/gprclean
CONFIG_FILE := $(OBJ_DIR)/my_proj.cgpr

$(MY_EXE): $(TOOLCHAIN) $(OBJ_DIR) $(MY_SOURCE) $(CONFIG_FILE)
	@echo Building file: $@
	@PATH=$(TOOLCHAIN_DIR)/gnat/bin:$(PATH) $(GPRBUILD) --target=arm-eabi -P$(ROOT_DIR)/my_proj.gpr --config=$(CONFIG_FILE)
