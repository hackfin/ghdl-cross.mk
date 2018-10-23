# Build GHDL outside gcc:
#


GHDL_VERSION = 3.5


MACHINE = $(shell uname -m)

# Will fail with
# > raised TYPES.UNRECOVERABLE_ERROR : comperr.adb:406
# or similar, when forgotten:
ifeq ($(MACHINE),aarch64)
	EXTRA_FLAGS = CFLAGS=-fPIC
endif

GHDL_GCC_BUILDDIR = $(GHDL_CROSS_BUILDDIR)


VHDL_GCC = $(GCC_SRC)/gcc/vhdl
	
$(GHDL_GCC_BUILDDIR)/config.status: $(GHDL_GCC_BUILDDIR)
	$(USE_NATIVE_SANDBOX_PATH); \
	cd $(dir $@) && $(GCC_SRC)/configure \
		--prefix=$(INSTALL_PREFIX) \
		--enable-languages=c,vhdl \
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
	cd $(GHDL_GCC_BUILDDIR) && $(MAKE) install DESTDIR=$(BOOTSTRAP)/test

############################################################################

# Build ghdl library with the prefix of the installed GHDL:
install-ghdllib: $(GHDL_BUILDDIR)/Makefile
	$(MAKE) -C $(dir $<) ghdllib install \
		GHDL_GCC_BIN=$(BOOTSTRAP)/test$(INSTALL_PREFIX)/bin/ghdl \
		GHDL1_GCC_BIN=--GHDL1=$(BOOTSTRAP)/test$(INSTALL_PREFIX)/libexec/gcc/x86_64-pc-linux-gnu/$(GCC_VERSION)/ghdl1 \
		DESTDIR=$(BOOTSTRAP)/test/

		# prefix=$(BOOTSTRAP)/test$(INSTALL_PREFIX)

prepare-ghdl: $(VHDL_GCC)

DUTIES += build-ghdl
