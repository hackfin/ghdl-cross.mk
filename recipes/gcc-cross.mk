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
		--enable-libada \
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


# Builds the gnat tools in the cross version.
# Important: The local gcc version must be the same as GCC_VERSION or
# in some way compatible, as gnat does not check for sanity.
build-targetlib: $(TEST_BUILD)/config.status | $(ARCH_DEPS) 
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) $(_MAKE_OPTIONS) \
		$(CROSS_EXTRAFLAGS) \
		all-gnattools
	touch $@

install-target: build-gcc build-targetlib
	$(USE_NATIVE_SANDBOX_PATH); \
	$(MAKE) -C $(TEST_BUILD) $(_MAKE_OPTIONS) \
		$(CROSS_EXTRAFLAGS) \
		install-gcc install-target-libgcc
	touch $@

clean-targetlib:
	rm -f $(TEST_BUILD)/config.status

# Procedure:
#
# 1) build gcc without libs
# 2) Then build mingw runtime libs with THIS gcc (install-gcc)
# 3) Then build the gnattools


all-gcc-mingw32: install-headers install-gcc install-runtime install-targetlib

DUTIES += build-gcc build-targetlib install-target
