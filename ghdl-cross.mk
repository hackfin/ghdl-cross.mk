# Rules to cross-compile GHDL
#
#
GHDL_CROSS_BUILDDIR = $(GHDL_CROSS_BUILD)/ghdl

ifdef BUILD_FROM_SANDBOX

TARGET_TOOLS = \
	AS_FOR_TARGET=$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)-as \
	AR_FOR_TARGET=$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)-ar \
	NM_FOR_TARGET=$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)-nm \
	LD_FOR_TARGET=$(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)-ld

	GHDL_CROSS_OPT = --with-build-sysroot=$(CROSS_SANDBOX)
	GHDL_INSTALL_PREFIX = $(INSTALL_PREFIX)
else

TARGET_TOOLS = \
	AS_FOR_TARGET=$(ARCH)-as \
	AR_FOR_TARGET=$(ARCH)-ar \
	NM_FOR_TARGET=$(ARCH)-nm \
	LD_FOR_TARGET=$(ARCH)-ld

	GHDL_CROSS_OPT = 
	GHDL_INSTALL_PREFIX=/usr
endif

$(GHDL_CROSS_BUILD):
	[ -e $@ ] || mkdir $@

# Fails with:
# > raised TYPES.UNRECOVERABLE_ERROR : comperr.adb:406
# - Remove -g from config.status:825
# > S["CFLAGS"]="-O2" 

$(GHDL_CROSS_BUILDDIR)/config.status: $(GHDL_CROSS_BUILD)
	[ -e $(GHDL_CROSS_BUILDDIR) ] || mkdir $(GHDL_CROSS_BUILDDIR)
	cd $(dir $@) && \
	$(USE_NATIVE_SANDBOX_PATH); \
	$(TARGET_TOOLS) \
	$(TARGET_GHDL_CFLAGS) \
	$(GCC_SRC)/configure \
 		$(GHDL_CROSS_OPT) \
 		--prefix=$(GHDL_INSTALL_PREFIX) \
 		--enable-languages=c,vhdl \
 		--disable-lto \
 		--disable-bootstrap \
 		--enable-target-zlib \
 		--enable-libbacktrace \
 		--disable-libssp \
 		--disable-libgomp \
 		--disable-libquadmath \
 		--disable-multilib \
 		--with-gnu-ld --with-gnu-as \
		$(CROSS_FLAGS)

#		--with-build-sysroot=$(CROSS_SANDBOX) \
#		--prefix=$(INSTALL_PREFIX) \
#		--enable-languages=c,vhdl \
#		--disable-bootstrap \
#		--disable-multilib \
#        --enable-checking \
#		--with-gnu-ld --with-gnu-as \

build-ghdl_cross: $(GHDL_CROSS_BUILDDIR)/config.status $(GHDL_DEPENDENCIES)
	$(USE_CROSS_SANDBOX_PATH) ; \
	$(MAKE) -C $(GHDL_CROSS_BUILDDIR) \
		CFLAGS_FOR_TARGET="$(GHDL_EXTRA_FLAGS)" \
		$(CROSS_EXTRAFLAGS) \
		all-gcc all-target

install-ghdl_cross:
	$(USE_CROSS_SANDBOX_PATH) ; \
	$(MAKE) -C $(GHDL_CROSS_BUILDDIR) install-gcc install-target \
		DESTDIR=$(CROSS_SANDBOX)/ghdl-cross

############################################################################
#

install-libbacktrace: $(GHDL_CROSS_BUILDDIR)/$(ARCH)/libbacktrace/.libs/libbacktrace.a
	cp $< $(CROSS_SANDBOX)/ghdl-cross$(INSTALL_PREFIX)/lib/ghdl

GHDLLIB_CROSS_BUILDDIR = $(GHDL_CROSS_BUILDDIR)/ghdllib

$(GHDLLIB_CROSS_BUILDDIR):
	[ -e $@ ] || mkdir $@


$(GHDLLIB_CROSS_BUILDDIR)/Makefile: $(GHDL_SRC)/configure $(GHDLLIB_CROSS_BUILDDIR) 
	cd $(dir $@) && $< \
		AS=$(CROSS_PREFIX)-as \
		CC=$(CROSS_PREFIX)-gcc \
		--with-gcc=$(GCC_SRC) --prefix=$(INSTALL_PREFIX)

GRT_CFLAGS = -I$(GCC_SRC)/zlib

GHDL_PREFIX = $(CROSS_SANDBOX)/ghdl-cross$(INSTALL_PREFIX)

# GHDL library build options to explicitely use installed
# compiler

GHDLLIB_OPTIONS = \
	AS=$(CROSS_PREFIX)-as \
	CC="$(CROSS_PREFIX)-gcc $(GHDL_EXTRA_FLAGS)"\
	GRT_RANLIB=$(CROSS_PREFIX)-ranlib \
	GNATMAKE=$(CROSS_PREFIX)-gnatmake \
	GRT_FLAGS="$(GRT_CFLAGS) $(GRT_EXTRA_CFLAGS)" \
	GHDL_GCC_BIN=$(GHDL_PREFIX)/bin/$(ARCH)-ghdl \
	GHDL1_GCC_BIN=--GHDL1=$(GHDL_PREFIX)/libexec/gcc/$(ARCH)/$(GCC_VERSION)/ghdl1


# Build ghdl library with the prefix of the installed GHDL:
build-ghdllib_cross: $(GHDLLIB_CROSS_BUILDDIR)/Makefile
	$(MAKE) -C $(dir $<) ghdllib \
		$(GHDLLIB_OPTIONS)
	touch $@

install-ghdllib_cross: build-ghdllib_cross
	$(MAKE) -C $(GHDLLIB_CROSS_BUILDDIR) install \
		$(GHDLLIB_OPTIONS) \
		DESTDIR=$(CROSS_SANDBOX)/ghdl-cross

# Warning: When splitting up build and install, the install rule will
# rebuild again. When not setting all the above parameters, we'll end up
# with a broken library...


clean-all-cross:
	rm -fr $(CROSS_SANDBOX)/ghdl-cross build-gcc build-ghdllib_cross
	rm -f $(GHDLLIB_CROSS_BUILDDIR)/Makefile
	rm -f $(GHDL_CROSS_BUILDDIR)/config.status
	# rm -fr $(GHDL_CROSS_BUILDDIR)

############################################################################
	
/tmp/test/config.status:
	cd $(dir $@) && \
 	$(USE_NATIVE_SANDBOX_PATH); \
 	$(TARGET_TOOLS) \
	CFLAGS=-O2 \
	$(GCC_SRC)/configure \
 		--with-build-sysroot=$(CROSS_SANDBOX) \
 		--prefix=$(INSTALL_PREFIX) \
 		--enable-languages=c,vhdl \
 		--enable-checking \
 		--enable-libbacktrace \
 		--disable-bootstrap \
 		--disable-libssp \
 		--disable-libquadmath \
 		--disable-multilib \
 		--with-gnu-ld --with-gnu-as \
		--target=$(ARCH)
#
# target_configargs="target-winsup" \

testconfig: /tmp/test/config.status

.PHONY: /tmp/test/config.status

