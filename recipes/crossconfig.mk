ifdef BUILD_FROM_SANDBOX
	CROSS_PREFIX ?= $(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)
	GHDL_CROSS_OPT = --with-build-sysroot=$(CROSS_SANDBOX)
else
	CROSS_PREFIX ?= $(ARCH)
	GHDL_CROSS_OPT = 
endif

CROSS_TOOLS = \
	CC=$(CROSS_PREFIX)-gcc DLLTOOL=$(CROSS_PREFIX)-dlltool \
	AS=$(CROSS_PREFIX)-as \
	LD=$(CROSS_PREFIX)-ld RANLIB=$(CROSS_PREFIX)-ranlib \
	NM=$(CROSS_PREFIX)-nm OBJCOPY=$(CROSS_PREFIX)-objcopy 

TARGET_TOOLS = \
	AS_FOR_TARGET=$(CROSS_PREFIX)-as \
	RANLIB_FOR_TARGET=$(CROSS_PREFIX)-ranlib \
	AR_FOR_TARGET=$(CROSS_PREFIX)-ar \
	NM_FOR_TARGET=$(CROSS_PREFIX)-nm \
	LD_FOR_TARGET=$(CROSS_PREFIX)-ld

CROSS_FLAGS = --target=$(ARCH)
CROSS_FLAGS += --enable-sjlj-exceptions


############################################################################
# Arch specifics:

ifeq ($(ARCH),i686-w64-mingw32)
	CROSS_FLAGS += --disable-win32-registry
	include mingw-w64.mk
	include libz.mk

ifdef BUILD_FROM_SANDBOX
	ARCH_DEPS = install-runtime
# Prefix is sandbox install dir:
	MINGW_PREFIX = $(CROSS_SANDBOX)$(INSTALL_PREFIX)
else
# Take it from local installation
	MINGW_PREFIX ?= /usr
endif

	MINGW32_W64_INCLUDE = $(MINGW_PREFIX)/$(ARCH)/include
	GRT_EXTRA_CFLAGS  = -I$(MINGW32_W64_INCLUDE)
	# Make sure #include_next gets the RIGHT headers:
	MINGW32_W64_SYSTEM_INCLUDE = -isystem $(MINGW32_W64_INCLUDE)
	GHDL_EXTRA_CFLAGS = $(MINGW32_W64_SYSTEM_INCLUDE)
	GHDL_EXTRA_CFLAGS += -Wno-strict-prototypes -Wno-unknown-pragmas

	# These options apply to compiling the cross GHDL:
	TARGET_GHDL_OPTIONS = CFLAGS_FOR_TARGET="$(GHDL_EXTRA_CFLAGS)"
	# Make linker look for crt and libs here:
	TARGET_GHDL_OPTIONS += FLAGS_FOR_TARGET=-B$(MINGW_PREFIX)/$(ARCH)/lib
	TARGET_GHDL_OPTIONS += CC=$(CC) CXX=$(CXX)

	# These flags apply to cross-compiling the target libraries:
	CROSS_EXTRAFLAGS += CXXFLAGS_FOR_TARGET="$(MINGW32_W64_SYSTEM_INCLUDE)"
	CROSS_EXTRAFLAGS += $(TARGET_GHDL_OPTIONS)

endif

BUILD_MACHINE = $(shell uname -m)

ifeq ($(BUILD_MACHINE),aarch64)
	CROSS_FLAGS += CFLAGS="-O2 -fPIC"
endif
