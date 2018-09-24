CROSS_PREFIX ?= $(CROSS_SANDBOX)$(INSTALL_PREFIX)/bin/$(ARCH)

CROSS_TOOLS = \
	CC=$(CROSS_PREFIX)-gcc DLLTOOL=$(CROSS_PREFIX)-dlltool \
	AS=$(CROSS_PREFIX)-as \
	LD=$(CROSS_PREFIX)-ld RANLIB=$(CROSS_PREFIX)-ranlib \
	NM=$(CROSS_PREFIX)-nm OBJCOPY=$(CROSS_PREFIX)-objcopy 

CROSS_FLAGS = --target=$(ARCH)
CROSS_FLAGS += --enable-sjlj-exceptions

ifeq ($(ARCH),i586-mingw32msvc)
	CROSS_FLAGS += --disable-win32-registry
	ARCH_DEPS = install-runtime
	# Hack to disable some functionality with missing declarations in legacy
	# win32 api headers
	GRT_EXTRA_CFLAGS = -DNO_FULL_WINAPI_SUPPORT
	include mingw.mk
endif

MINGW_PREFIX ?= $(CROSS_SANDBOX)$(INSTALL_PREFIX)
MINGW_CC     ?= $(MINGW_PREFIX)/bin/$(ARCH)-gcc

ifeq ($(ARCH),i686-w64-mingw32)
	CROSS_FLAGS += --disable-win32-registry
	MING32_W64_INCLUDE = $(MINGW_PREFIX)/$(ARCH)/include
ifdef BUILD_FROM_SANDBOX
	ARCH_DEPS = install-runtime
endif
	include mingw-w64.mk
	include libz.mk
	GRT_EXTRA_CFLAGS = -I$(MING32_W64_INCLUDE)
	TARGET_GHDL_CFLAGS = CFLAGS_FOR_TARGET="$(GHDL_EXTRA_FLAGS)"

ifneq ($(MINGW_CC),)
	CROSS_EXTRAFLAGS = CC_FOR_TARGET=$(MINGW_CC) 
else
	CROSS_EXTRAFLAGS = 
endif
	CROSS_EXTRAFLAGS += CXXFLAGS_FOR_TARGET="-I$(MING32_W64_INCLUDE)" 
	CROSS_EXTRAFLAGS += $(TARGET_GHDL_CFLAGS)

	GHDL_EXTRA_FLAGS = -I$(MING32_W64_INCLUDE)
	GHDL_EXTRA_FLAGS += -B$(MINGW_PREFIX)/$(ARCH)/lib
	GHDL_EXTRA_FLAGS += -Wno-strict-prototypes -Wno-unknown-pragmas


endif

BUILD_MACHINE = $(shell uname -m)

ifeq ($(BUILD_MACHINE),aarch64)
	CROSS_FLAGS += CFLAGS="-O2 -fPIC"
endif
