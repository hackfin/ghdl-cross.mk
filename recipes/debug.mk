debug:
	@echo "------------------------------------------------------"
	@echo "------------       DEBUGGING       -------------------"
	@echo
	@echo "BUILD_INFO: $(BUILD_INFO)"
	@echo
	@echo "Building cross GHDL for architecture: $(ARCH)"
	@echo "Building in:       $(CROSS_BUILD)"
	@echo "Native path:       $(BOOTSTRAP_BIN)"
ifdef BUILD_FROM_SANDBOX
	@echo "Build sysroot:     $(CROSS_SANDBOX)"
	@echo "Cross build path:  $(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin"
	@echo "mingw-w64 source:  $(MINGW64_SRC)"
	@echo "mingw-w64 prefix:  $(MINGW_PREFIX)"
endif
	@echo "Using GCC:         `which $(CC)`   `which $(CXX)`"
	@echo "Build GCC version: $(GCC_VERSION)"
	@echo "-----------------------------------------"
	@echo "Target tools:"
	@echo "Cross GCC:         `which $(CROSS_PREFIX)-$(CC)`"
	@for i in $(TARGET_TOOLS); do echo $$i; done
	@echo "Cross flags for GCC target libraries:"
	@echo $(CROSS_EXTRAFLAGS)
	@echo "Cross flags for target specific GHDL:"
	@echo $(TARGET_GHDL_OPTIONS)

debug-stamp:
	$(call makestamp, CC CXX)
	
