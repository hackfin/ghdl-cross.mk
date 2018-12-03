
GHDL_BUILDDIR = $(BUILD_ROOT)/ghdl

VHDL_GCC = $(GCC_SRC)/gcc/vhdl

UNIFIED_BUILDLIBS = $(GCC_SRC)/mpfr
UNIFIED_BUILDLIBS += $(GCC_SRC)/mpc
UNIFIED_BUILDLIBS += $(GCC_SRC)/gmp
UNIFIED_BUILDLIBS += $(GCC_SRC)/isl

$(GCC_SRC)/contrib/download_prerequisites: | $(GCC_SRC)

$(UNIFIED_BUILDLIBS): $(GCC_SRC)/contrib/download_prerequisites
	cd $(GCC_SRC) && sh $< $(NO_VERIFY)

$(BUILD_ROOT):
	mkdir $@

$(GHDL_BUILDDIR): | $(BUILD_ROOT)
	mkdir $@

$(GHDL_BUILDDIR)/config.status: $(GHDL_SRC)/configure | $(GHDL_BUILDDIR)
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && $< \
		--with-gcc=$(GCC_SRC) \
		--prefix=$(INSTALL_PREFIX)

$(VHDL_GCC): $(GHDL_BUILDDIR)/config.status
	cd $(GHDL_BUILDDIR) && $(MAKE) copy-sources

prepare-ghdl: $(VHDL_GCC)

prepare: prepare-ghdl

.PHONY: prepare prepare-ghdl
