
$(BUILD_ROOT)/zlib/config.status:
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@); \
	$(CROSS_TOOLS) \
	$(GCC_SRC)/zlib/configure --prefix=$(INSTALL_PREFIX)/$(ARCH)
	
install-libz: $(BUILD_ROOT)/zlib/config.status
	$(USE_CROSS_SANDBOX_PATH) ; \
	$(MAKE) -C $(BUILD_ROOT)/zlib install DESTDIR=$(CROSS_SANDBOX)

clean-libz:
	rm -fr $(BUILD_ROOT)/zlib
