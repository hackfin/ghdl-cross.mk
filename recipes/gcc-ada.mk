# Build native gcc toolchain FIRST PASS
# bootstrapping is disabled for faster build

BOOT_BUILD = $(BUILD_ROOT)/gcc-7.2-ada/

$(BOOT_BUILD)/config.status: $(UNIFIED_BUILDLIBS)
	[ -e $(BOOT_BUILD) ] || mkdir $(BOOT_BUILD)
	cd $(BOOT_BUILD); $(GCC_SRC)/configure \
		--disable-multilib \
		--disable-bootstrap \
		--enable-languages=c,c++,ada

build-gcc-ada: $(BOOT_BUILD)/config.status 
	$(PREPARE_BUILD); \
	cd $(BOOT_BUILD) && $(MAKE) $(MAKE_OPTIONS) all
	touch $@

# install-target installs the necessary headers
# This is important for building the cross compiler.
install-gcc-ada: 
	cd $(BOOT_BUILD) && \
	$(MAKE) install-gcc install-target DESTDIR=$(BOOTSTRAP)


checkpath:
	@echo Check for proper installation in $(BOOTSTRAP_BIN)
	TOOLSPATH=$(BOOTSTRAP_BIN); \
	export PATH=$$TOOLSPATH:$$PATH; \
	MYGCC=`which gcc`; GCCPATH=`dirname $$MYGCC`; \
	MYGCCPP=`which g++`; GCCPLUSPATH=`dirname $$MYGCCPP`; \
	MYGNATMAKE=`which gnatmake`; GNATMAKEPATH=`dirname $$MYGNATMAKE`; \
	MYLD=`which ld`; LDPATH=`dirname $$MYLD`; \
	if [ "$$GCCPLUSPATH" != "$$TOOLSPATH" ]; \
	then echo "g++ not correctly installed: $$GCCPLUSPATH"; false; fi; \
	if [ "$$GCCPATH" != "$$TOOLSPATH" ]; \
	then echo "gcc not correctly installed: $$GCCPATH"; false; fi; \
	if [ "$$GNATMAKEPATH" != "$$TOOLSPATH" ]; \
	then echo "gnatmake not correctly installed: $$GNATMAKEPATH"; false; fi; \
	if [ "$$LDPATH" != "$$TOOLSPATH" ]; \
	then echo "ld not correctly installed: $$LDPATH"; false; fi;



all: build-gcc-ada install-gcc-ada

DUTIES += build-gcc-ada

