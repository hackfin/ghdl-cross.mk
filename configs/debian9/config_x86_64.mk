# Local configuration make settings for ghdl-cross setup
#

# You have to edit the locations in this Makefile to make stuff compile.

# unused: PARALLELIZE = -j3

MAKE_OPTIONS = 

# Development version:

VERSION = 0.003

# Workaround for asm/errno.h error:
PREPARE_BUILD = export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu; \
	export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

# Define when we build GHDL with a cross compiler built in the sandbox:
BUILD_FROM_SANDBOX = y

# Installation prefix:
ifdef BUILD_FROM_SANDBOX
BUILD_INFO = 'Debian 9 x86-64 build, sandboxed cross compiler'
INSTALL_PREFIX = /usr/local
# Don't specify, take from installed
# GCC_VERSION = 7.2.0
# Choose any that compiles:
MINGW64_VERSION = 6.0.0
else
BUILD_INFO = 'Debian 9 x86-64 build, native cross compiler'
INSTALL_PREFIX = /usr
# Choose version closest to local installation:
MINGW64_VERSION = 3.1.0
CC=gcc-7
CXX=g++-7
endif

# Source location of binutils:
BINUTILS_SRC = $(TOOLCHAIN_SRC)/binutils-2.31

# Source location of gcc:
GCC_SRC = $(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION)

# Mingw32 specifics:
MINGW64_SRC = $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION)

#MINGW32_W64_INCLUDE = /usr/x86_64-w64-mingw32/include
