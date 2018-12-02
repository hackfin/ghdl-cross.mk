ifdef BUILD_FROM_SANDBOX
CROSS_PREFIX ?= $(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)
else
CROSS_PREFIX ?= $(ARCH)
endif

CROSS_TOOLS = \
	CC=$(CROSS_PREFIX)-gcc DLLTOOL=$(CROSS_PREFIX)-dlltool \
	AS=$(CROSS_PREFIX)-as \
	LD=$(CROSS_PREFIX)-ld RANLIB=$(CROSS_PREFIX)-ranlib \
	NM=$(CROSS_PREFIX)-nm OBJCOPY=$(CROSS_PREFIX)-objcopy 

CROSS_FLAGS = --target=$(ARCH)
CROSS_FLAGS += --enable-sjlj-exceptions

MINGW_PREFIX ?= $(CROSS_SANDBOX)$(INSTALL_PREFIX)
MINGW_CC     ?= $(MINGW_PREFIX)/bin/$(ARCH)-gcc

ifeq ($(ARCH),i686-w64-mingw32)
	CROSS_FLAGS += --disable-win32-registry
	MINGW32_W64_INCLUDE ?= $(MINGW_PREFIX)/$(ARCH)/include
	include mingw-w64.mk
	include libz.mk
	GRT_EXTRA_CFLAGS = -I$(MINGW32_W64_INCLUDE)
	TARGET_GHDL_OPTIONS = CFLAGS_FOR_TARGET="$(GHDL_EXTRA_CFLAGS)"

# 	Never do that here: it will break the build for libgcc
# 	CROSS_EXTRAFLAGS = CC_FOR_TARGET=$(MINGW_CC) 

	GHDL_EXTRA_CFLAGS = -I$(MINGW32_W64_INCLUDE)

ifdef BUILD_FROM_SANDBOX
	ARCH_DEPS = install-runtime
	GHDL_EXTRA_FLAGS += -L$(MINGW_PREFIX)/$(ARCH)/lib
	TARGET_GHDL_OPTIONS += FLAGS_FOR_TARGET=-L/usr/$(ARCH)/lib
else
# Look for local libraries:
	TARGET_GHDL_OPTIONS += FLAGS_FOR_TARGET=-B/usr/$(ARCH)/lib
endif
# Pass configured CC options:
	TARGET_GHDL_OPTIONS += CC=$(CC) CXX=$(CXX)

	GHDL_EXTRA_CFLAGS += -Wno-strict-prototypes -Wno-unknown-pragmas

	CROSS_EXTRAFLAGS += CXXFLAGS_FOR_TARGET="-I$(MINGW32_W64_INCLUDE)" 
	CROSS_EXTRAFLAGS += $(TARGET_GHDL_OPTIONS)

endif

BUILD_MACHINE = $(shell uname -m)

ifeq ($(BUILD_MACHINE),aarch64)
	CROSS_FLAGS += CFLAGS="-O2 -fPIC"
endif
