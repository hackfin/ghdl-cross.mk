
MINGW_W64_ARCH = i686-w64-mingw32

MINGW_SANDBOX = $(BUILD_ROOT)/cross-toolchain/mingw-w64
MINGW_HEADERS = $(BUILD_ROOT)/cross-toolchain/mingw-w64-headers

$(MINGW_SANDBOX):
	[ -e $@ ] || mkdir $@

$(MINGW64_SRC)/configure: | $(MINGW64_SRC)

$(MINGW_SANDBOX)/Makefile: $(MINGW64_SRC)/configure | $(MINGW_SANDBOX) 
	cd $(MINGW_SANDBOX) && $< \
		$(CROSS_TOOLS) \
		--prefix=$(INSTALL_PREFIX)/$(MINGW_W64_ARCH) \
		--enable-lib32 --enable-experimental --host=$(MINGW_W64_ARCH) \
		--with-sysroot=$(CROSS_SANDBOX)

build-mingw64: $(MINGW_SANDBOX)/Makefile
	cd $(MINGW_SANDBOX) && $(MAKE)
	touch $@

install-mingw64: build-mingw64
	cd $(MINGW_SANDBOX) && $(MAKE) install DESTDIR=$(CROSS_SANDBOX)
	touch $@

$(MINGW_HEADERS)/config.status: $(MINGW64_SRC)/mingw-w64-headers/configure
	[ -e $(MINGW_HEADERS) ] || mkdir $(MINGW_HEADERS)
	cd $(MINGW_HEADERS) && $<  \
		--host=$(MINGW_W64_ARCH) \
		--prefix=$(INSTALL_PREFIX)/$(MINGW_W64_ARCH)

install-headers: $(MINGW_HEADERS)/config.status
	make -C $(MINGW_HEADERS) all install DESTDIR=$(CROSS_SANDBOX)

clean-headers:
	rm -fr $(MINGW_HEADERS)

clean-mingw64:
	rm -fr $(MINGW_SANDBOX)

install-runtime: install-mingw64

clean-runtime: clean-headers clean-mingw64

$(CROSS_SANDBOX)/mingw:
	ln -s $(CROSS_SANDBOX)/$(INSTALL_PREFIX)/$(ARCH) $@

# GHDL_DEPENDENCIES = $(CROSS_SANDBOX)/mingw

.PHONY: install-runtime

DUTIES += build-mingw64 install-mingw64
