include config.mk

GHDL_BUILDDIR = $(BUILD_ROOT)/ghdl

VHDL_GCC = $(GCC_SRC)/gcc/vhdl

UNIFIED_BUILDLIBS = $(GCC_SRC)/mpfr
UNIFIED_BUILDLIBS += $(GCC_SRC)/mpc
UNIFIED_BUILDLIBS += $(GCC_SRC)/gmp
UNIFIED_BUILDLIBS += $(GCC_SRC)/isl

$(UNIFIED_BUILDLIBS): $(GCC_SRC)
	cd $(GCC_SRC) && sh contrib/download_prerequisites $(NO_VERIFY)

$(GHDL_BUILDDIR)/config.status: $(GHDL_SRC)/configure
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && $< \
		--with-gcc=$(GCC_SRC) \
		--prefix=$(INSTALL_PREFIX)


$(VHDL_GCC): $(GHDL_BUILDDIR)/config.status
	cd $(GHDL_BUILDDIR) && $(MAKE) copy-sources

prepare-ghdl: $(VHDL_GCC)

prepare: $(UNIFIED_BUILDLIBS)
