
# Install base GCC with libraries:
# > make install-sandbox
#
# Install GHDL and libraries (do not use -j option):
#
# > make all-ghdl_cross

# The GCC version to use
GCC_VERSION = 7.2.0
# Mingw64 version to use
MINGW64_VERSION = 6.0.0

# ARCH = i586-mingw32msvc
ARCH = i686-w64-mingw32
# ARCH ?= x86_64-linux

# The install prefix to use:
INSTALL_PREFIX = /usr/local

# include local configuration:
include config.mk
# Prepare script
include prepare.mk
-include downloads.mk

# Where the cross toolchain is built:
CROSS_BUILD = $(BUILD_ROOT)/cross-toolchain/$(ARCH)

# Where the cross GHDL is built:
GHDL_CROSS_BUILD = $(BUILD_ROOT)/cross-toolchain/$(ARCH)-ghdl

# Where binaries, libs and headers of the temporary toolchain are installed:
SANDBOX_ROOT = $(BUILD_ROOT)/cross-sandbox

CROSS_SANDBOX = $(SANDBOX_ROOT)/$(ARCH)

BOOTSTRAP = $(BUILD_ROOT)/native
BOOTSTRAP_BIN = $(BOOTSTRAP)$(INSTALL_PREFIX)/bin


############################################################################
# Normally, don't change these:

USE_NATIVE_SANDBOX_PATH = \
	export PATH=$(BOOTSTRAP_BIN):$$PATH

USE_CROSS_SANDBOX_PATH = \
	export PATH=$(BOOTSTRAP_BIN):$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin:$$PATH

CONF_FLAGS = --prefix=$(INSTALL_PREFIX) \
             --disable-multilib \
             --enable-threads \
             --enable-checking \
             --disable-shared

include gcc-ada.mk

include binutils.mk

include crossconfig.mk

include gcc-cross.mk
include ghdl-cross.mk

DUTIES = build-binutils build-gcc

all: install-sandbox all-ghdl_cross


$(BUILD_ROOT)/cross-toolchain:
	mkdir $@

$(CROSS_BUILD): $(BUILD_ROOT)/cross-toolchain
	mkdir $@

install-bootstrap: install-gcc-ada

# Compile in order such that:
# - Headers are present before building cross-GCC
# - Runtime is compiled by 'bare' compiler
# - Additional libraries are then compiled against installed runtime
install-sandbox: install-binutils install-headers install-gcc install-targetlib install-libz 

all-ghdl_cross: build-ghdl_cross install-ghdl_cross install-ghdllib_cross install-libbacktrace

.NOTPARALLEL: all install-sandbox all-ghdl_cross

clean-sandbox:
	rm -fr $(BOOTSTRAP_BIN)

clean-bootstrap:
	rm -fr $(BOOTSTRAP_BIN)$(INSTALL_PREFIX)

clean: clean-sandbox
	-rm $(DUTIES)


# Rules that don't parallelize:

.NOTPARALLEL: build-gcc

dist:
	cd ..; tar cfvz ghdl-build.mk.tgz $(notdir $(CURDIR)) \
		--exclude=.git --exclude=*.swp --exclude=build-* --exclude=install-*
	cat self-extract.sh ../ghdl-build.mk.tgz >ghdlbuild_sfx.sh
