# Rules to cross compile libz

ifdef DESTDIR
DESTDIR_LIBZ = $(DESTDIR)
else
DESTDIR_LIBZ = $(CROSS_SANDBOX)
endif

$(BUILD_ROOT)/zlib/config.status:
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@); \
	$(CROSS_TOOLS) \
	$(GCC_SRC)/zlib/configure --prefix=$(INSTALL_PREFIX)/$(ARCH) \
		--host=$(ARCH)
	
install-libz: $(BUILD_ROOT)/zlib/config.status
	$(USE_CROSS_SANDBOX_PATH) ; \
	$(MAKE) -C $(BUILD_ROOT)/zlib install DESTDIR=$(DESTDIR_LIBZ)

clean-libz:
	rm -fr $(BUILD_ROOT)/zlib
