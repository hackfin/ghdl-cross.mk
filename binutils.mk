$(CROSS_BUILD)/binutils/config.status:
	[ -e $(CROSS_BUILD) ] || mkdir $(CROSS_BUILD)
	[ -e $(CROSS_BUILD)/binutils ] || mkdir $(CROSS_BUILD)/binutils
	cd $(CROSS_BUILD)/binutils; \
	$(BINUTILS_SRC)/configure $(CONF_FLAGS) \
		--target=$(ARCH)

build-binutils: $(CROSS_BUILD)/binutils/config.status
	$(MAKE) -C $(CROSS_BUILD)/binutils $(MAKE_OPTIONS) all-host
	touch $@

install-binutils: build-binutils
	$(MAKE) -C $(CROSS_BUILD)/binutils \
	install DESTDIR=$(CROSS_SANDBOX)
	touch $@
