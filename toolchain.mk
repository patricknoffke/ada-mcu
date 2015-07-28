TOOLCHAIN_DIR := $(OUTPUT_DIR)/toolchain
TOOLCHAIN_SRC_DIR := $(ROOT_DIR)/toolchain
DL_DIR = $(TOOLCHAIN_SRC_DIR)/dl

GNAT_BIN := $(DL_DIR)/gnat-gpl-2015-arm-elf-linux-bin.tar.gz
GNAT_SRC := $(DL_DIR)/gnat-gpl-2015-src.tar.gz
ZFP_SRC := $(DL_DIR)/bb-runtimes-gpl-2015-src.tar.gz
GCC_SRC := $(DL_DIR)/gcc-4.9-gpl-2015-src.tar.gz

GNAT_BIN_DIR = $(TOOLCHAIN_DIR)/gnat

$(TOOLCHAIN_DIR)/.stamp_extracted:
	mkdir -p $(TOOLCHAIN_DIR)/src/gcc
	tar -C $(TOOLCHAIN_DIR) -xzf $(GNAT_BIN)
	tar -C $(TOOLCHAIN_DIR)/src -xzf $(GNAT_SRC)
	tar --strip-components=1 -C $(TOOLCHAIN_DIR)/src/gcc -xzf $(GCC_SRC)
	tar -C $(TOOLCHAIN_DIR)/src -xzf $(ZFP_SRC)
	cd $(TOOLCHAIN_DIR)/src && ln -s gnat-gpl-2015-src/src/ada gnat
	@touch $@

$(TOOLCHAIN_DIR)/.stamp_install_bin: $(TOOLCHAIN_DIR)/.stamp_extracted
	$(MAKE) -C $(TOOLCHAIN_DIR)/gnat-gpl-2015-arm-elf-linux-bin prefix=$(GNAT_BIN_DIR) ins-all
	@touch $@

$(TOOLCHAIN_DIR)/.stamp_patched: $(TOOLCHAIN_DIR)/.stamp_install_bin
	cd $(TOOLCHAIN_DIR)/src/bb-runtimes-gpl-2015-src && \
            patch -p1 < $(TOOLCHAIN_SRC_DIR)/bb-runtimes-gpl-2015.patch
	cd $(TOOLCHAIN_DIR)/src/gnat-gpl-2015-src && \
            patch -p1 < $(TOOLCHAIN_SRC_DIR)/gnat-gpl-2015-src.patch
	@touch $@

$(TOOLCHAIN_DIR)/.stamp_built: $(TOOLCHAIN_DIR)/.stamp_patched
	cd $(TOOLCHAIN_DIR)/src/bb-runtimes-gpl-2015-src && \
           PATH=$(TOOLCHAIN_DIR)/gnat/bin:$(PATH) ./build-all.sh -v --target=sam4s full
	mkdir -p $(GNAT_BIN_DIR)/arm-eabi/lib/gnat/ravenscar-full-sam4s
	cd $(GNAT_BIN_DIR)/arm-eabi/lib/gnat/ravenscar-full-sam4s && \
           rsync -aPv $(TOOLCHAIN_DIR)/src/bb-runtimes-gpl-2015-src/install/ .
	@touch $@

TOOLCHAIN += $(TOOLCHAIN_DIR)/.stamp_built
