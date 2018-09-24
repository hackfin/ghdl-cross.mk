
# Install base GCC with libraries:
# > make install-sandbox
#
# Install GHDL and libraries (do not use -j option):
#
# > make all-ghdl_cross

# The GCC version to use
GCC_VERSION = 7.2.0

# ARCH = i586-mingw32msvc
ARCH = i686-w64-mingw32
# ARCH ?= x86_64-linux

# The install prefix to use:
INSTALL_PREFIX = /usr/local

# include local configuration:
include config.mk

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
include ghdl-outside.mk

include binutils.mk

include crossconfig.mk

include gcc-cross.mk
include ghdl-cross.mk

DUTIES = build-binutils build-gcc

all: install-sandbox all-ghdl_cross

install-bootstrap: install-gcc-ada

install-sandbox: install-binutils install-runtime install-libz install-gcc install-targetlib

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
