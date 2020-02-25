# Build rules for native GHDL build outside gcc directory
#
# Requires a number of configuration variables:
#
#

# Version of GCC:
GCC_VERSION ?= 7.2.0
#
# Where GCC sources are located:
# GCC_SRC = $(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION)
#
# Where GHDL source is located:
# GHDL_SRC = $(TOOLCHAIN_SRC)/ghdl.latest
#
# Directory root where to install
INSTALL_ROOT ?= /tmp/ghdl
#
# Directory prefix for installation:
INSTALL_PREFIX ?= /usr
#
# Build (scratch) path: Needs quite some storage space.
BUILD_ROOT ?= /tmp/ghdl_build

# Enable when building with synthesis:
GHDL_SYNTH_OPTIONS = --enable-libghdl --enable-synth --default-pic

# Define when building from outside a specific sandbox
USE_NATIVE_SANDBOX_PATH ?= true

MACHINE = $(shell uname -m)

# Will fail with
# > raised TYPES.UNRECOVERABLE_ERROR : comperr.adb:406
# or similar, when forgotten:
ifeq ($(MACHINE),aarch64)
	PLATFORM=-unknown-linux-gnu
endif
ifeq ($(MACHINE),x86_64)
	PLATFORM=-pc-linux-gnu
endif

# EXTRA_FLAGS = CFLAGS=-fPIC

ARCH=$(MACHINE)$(PLATFORM)


GHDL_GCC_BUILDDIR = $(BUILD_ROOT)/ghdl-native-$(GCC_VERSION)

GHDL_BUILDDIR ?= $(BUILD_ROOT)/ghdl

VHDL_GCC = $(GCC_SRC)/gcc/vhdl

$(GHDL_BUILDDIR):
	mkdir $@

$(GHDL_BUILDDIR)/config.status: $(GHDL_SRC)/configure | $(GHDL_BUILDDIR)
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && $< \
		$(GHDL_SYNTH_OPTIONS) \
		--with-gcc=$(GCC_SRC) \
		--prefix=$(INSTALL_PREFIX)


$(VHDL_GCC): $(GHDL_BUILDDIR)/config.status
	cd $(GHDL_BUILDDIR) && $(MAKE) copy-sources
	
$(GHDL_GCC_BUILDDIR)/config.status: $(GCC_SRC)/configure | $(GHDL_GCC_BUILDDIR)
	$(USE_NATIVE_SANDBOX_PATH); \
	cd $(dir $@) && $< \
		--prefix=$(INSTALL_PREFIX) \
		--enable-languages=c,vhdl \
		--enable-default-pie \
		--disable-bootstrap \
		--disable-multilib \
		--disable-lto \
		--disable-libgomp --disable-libquadmath --disable-libssp
	

$(GHDL_GCC_BUILDDIR): | $(GHDL_BUILDDIR)
	[ -e $@ ] || mkdir $@


ghdl: $(GHDL_BUILDDIR)/config.status
	# Need separate call:
	cd $(GHDL_BUILDDIR) && \
	$(MAKE) \
		ghdl1-gcc \
		AGCC_GCCSRC_DIR=$(GCC_SRC)/ \
		AGCC_GCCOBJ_DIR=$(GHDL_GCC_BUILDDIR)/
	# Need separate call:

	cd $(GHDL_BUILDDIR) && \
		$(MAKE) libs.vhdl.local_gcc \
		AGCC_GCCSRC_DIR=$(GCC_SRC)/ \
		AGCC_GCCOBJ_DIR=$(GHDL_GCC_BUILDDIR)/

	cd $(GHDL_BUILDDIR) && \
	$(MAKE) \
		grt-all install.vpi.local \
		LIBBACKTRACE=$(GHDL_GCC_BUILDDIR)/libbacktrace/.libs/libbacktrace.a


build-ghdl: $(GHDL_GCC_BUILDDIR)/config.status
	cd $(GHDL_GCC_BUILDDIR) && $(MAKE) $(EXTRA_FLAGS) $(MAKE_OPTIONS)
	touch build-ghdl

install-ghdl: build-ghdl
	cd $(GHDL_GCC_BUILDDIR) && $(MAKE) install DESTDIR=$(INSTALL_ROOT)

############################################################################

# Build ghdl library with the prefix of the installed GHDL:
install-ghdllib: $(GHDL_BUILDDIR)/Makefile
	$(MAKE) -C $(dir $<) ghdllib install \
		GHDL_GCC_BIN=$(INSTALL_ROOT)$(INSTALL_PREFIX)/bin/ghdl \
		GHDL1_GCC_BIN=--GHDL1=$(INSTALL_ROOT)$(INSTALL_PREFIX)/libexec/gcc/$(ARCH)/$(GCC_VERSION)/ghdl1 \
		DESTDIR=$(INSTALL_ROOT)

prepare-ghdl: $(VHDL_GCC)

debug:
	@echo VHDL_GCC = $(VHDL_GCC)
	@echo GHDL_BUILDDIR = $(GHDL_BUILDDIR)
	@echo INSTALL_PREFIX = $(INSTALL_PREFIX)

DUTIES += build-ghdl

clean:
	rm -f $(GHDL_BUILDDIR)/config.status $(DUTIES)
	rm -fr $(VHDL_GCC)

