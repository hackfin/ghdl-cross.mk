LOCAL_SANDBOX_PATH = $(BOOTSTRAP_BIN):$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin

TEST_BUILD = $(CROSS_BUILD)

GCC_FLAGS =   \
	--disable-bootstrap \
	--disable-multilib \
	--disable-nls \
	--enable-threads \
	--enable-checking \
	--disable-shared

# Bootstrap compiler with different prefix:

$(TEST_BUILD)/config.status:
	[ -e $(TEST_BUILD) ] || mkdir $(TEST_BUILD)
	$(USE_NATIVE_SANDBOX_PATH); \
	cd $(TEST_BUILD); $(GCC_SRC)/configure \
		$(GCC_FLAGS) \
 		--disable-libquadmath \
 		--disable-libssp \
		--prefix=$(CROSS_SANDBOX)$(INSTALL_PREFIX) \
		--enable-languages=c,c++,ada \
		--with-gnu-ld --with-gnu-as \
		$(CROSS_FLAGS)

config-gcc: $(TEST_BUILD)/config.status

# Compile with the sandboxed native (current) build
# Build gcc only. libgcc and target libs are compiled AFTER
# installation of the Mingw runtime environment
build-gcc: $(TEST_BUILD)/config.status 
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) $(_MAKE_OPTIONS) \
		$(CROSS_EXTRAFLAGS) \
		all-gcc all-target-libgcc
	touch $@


install-gcc: build-gcc
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) install-gcc install-target-libgcc


# # Builds libgcc, libstdc++ and other target stuff,
# Must be after mingw32/winapi stuff has been compiled
# To make sure we're not using a locally installed cross compiler,
# we specify CC_FOR_TARGET in CROSS_EXTRAFLAGS
build-targetlib: $(ARCH_DEPS) $(TEST_BUILD)/config.status 
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) $(_MAKE_OPTIONS) \
		$(CROSS_EXTRAFLAGS) \
		all-gnattools
	touch $@

install-targetlib: build-targetlib
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) $(_MAKE_OPTIONS) \
		$(CROSS_EXTRAFLAGS) \
		install-gnattools install-target-libgcc

clean-targetlib:
	rm -f $(TEST_BUILD)/config.status

# Procedure:
#
# 1) build gcc without libs
# 2) Then build mingw runtime libs with THIS gcc (install-gcc)
# 3) Then build the gnattools


all-gcc-mingw32: install-gcc install-runtime install-targetlib
