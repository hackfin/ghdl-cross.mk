
MINGW_W64_ARCH = i686-w64-mingw32

MINGW_SANDBOX = $(BUILD_ROOT)/cross-toolchain/mingw-w64

$(MINGW_SANDBOX):
	[ -e $(MINGW_SANDBOX) ] || mkdir $(MINGW_SANDBOX)


$(MINGW_SANDBOX)/config.status: $(MINGW_SANDBOX) $(MINGW64_SRC)/configure
	cd $(MINGW_SANDBOX) && $(MINGW64_SRC)/configure \
		--prefix=$(INSTALL_PREFIX)/i686-w64-mingw32 \
		--enable-lib32 --enable-experimental --host=i686-w64-mingw32

build-mingw64: $(MINGW_SANDBOX)/config.status
	cd $(MINGW_SANDBOX) && $(MAKE)

install-mingw64: $(MINGW_SANDBOX)/config.status
	cd $(MINGW_SANDBOX) && $(MAKE) install DESTDIR=$(CROSS_SANDBOX)

install-runtime: install-mingw64

$(CROSS_SANDBOX)/mingw:
	ln -s $(CROSS_SANDBOX)/$(INSTALL_PREFIX)/$(ARCH) $@

GHDL_DEPENDENCIES = $(CROSS_SANDBOX)/mingw

clean-mingw64:
	rm -fr $(MINGW_SANDBOX)

.PHONY: install-runtime install-mingw64
