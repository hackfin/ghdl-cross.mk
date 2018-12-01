
# Install base GCC with libraries:
# > make install-sandbox
#
# Install GHDL and libraries (do not use -j option):
#
# > make all-ghdl_cross

# The GCC version to use: Safest is to use same version as installed:

CC = gcc

# Mingw64 version to use
MINGW64_VERSION = 6.0.0

# ARCH = i586-mingw32msvc # SUPPORT DROPPED
ARCH = i686-w64-mingw32
# ARCH ?= x86_64-linux

# include local configuration:
include config.mk

INSTALL_PREFIX ?= /usr

GCC_VERSION ?= $(shell $(CC) --version | \
	 sed -n 's/^$(CC) (.*) \([0-9]\.[0-9]\.[0-9]\).*/\1/p')

# Some gcc version hacks:
ifeq ($(GCC_VERSION),6.3.1)
	GCC_VERSION = 6.3.0
endif

ifeq ($(GCC_VERSION),6.3.0)
GCC_TARFILE = gcc-$(GCC_VERSION).tar.bz2
else
ifeq ($(GCC_VERSION),7.2.0)
GCC_TARFILE = gcc-$(GCC_VERSION).tar.xz
else
$(warning "Unsupported GCC version $(GCC_VERSION)")
GCC_TARFILE ?= gcc-$(GCC_VERSION).tar.xz
endif
endif

all: install-sandbox all-ghdl_cross

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

-include debug.mk

$(BUILD_ROOT)/cross-toolchain:
	mkdir $@

$(CROSS_BUILD): | $(BUILD_ROOT)/cross-toolchain
	mkdir $@

install-bootstrap: install-gcc-ada

# Compile in order such that:
# - Headers are present before building cross-GCC
# - Runtime is compiled by 'bare' compiler
# - Additional libraries are then compiled against installed runtime
install-sandbox: install-binutils install-headers install-gcc \
	install-target install-libz 

all-ghdl_cross: build-ghdl_cross install-ghdl_cross install-ghdllib_cross \
	install-libbacktrace

.NOTPARALLEL: all install-sandbox all-ghdl_cross

check:
	@echo Building for GCC version: $(GCC_VERSION)
	@echo GCC_SRC: $(GCC_SRC)
	@echo GCC tar to download: $(GCC_TARFILE)

clean-stamps:
	-rm $(DUTIES)

# Run mrproper when changing the config, like GCC_VERSION, ...
mrproper:
	rm -fr $(BUILD_ROOT)/cross-toolchain $(SANDBOX_ROOT)

# Rules that don't parallelize:

.NOTPARALLEL: build-gcc

dist:
	cd ..; tar cfvz ghdl-build.mk.tgz recipes \
		--exclude=.git --exclude=*.swp \
		--exclude=*.swo \
		--exclude=build-* --exclude=install-*
	cat ../self-extract.sh ../ghdl-build.mk.tgz >../ghdlbuild_sfx.sh
