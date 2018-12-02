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

GCC_VERSION = 7.2.0


# Root toolchain directory
TOOLCHAIN_SRC = /data/src/gcc-toolchain
# Set to directory where stuff should be built:
BUILD_ROOT=/media/strubi/scratch/build

# Define when we build GHDL with a cross compiler built in the sandbox:
# BUILD_FROM_SANDBOX = y

# Installation prefix:
ifdef BUILD_FROM_SANDBOX
INSTALL_PREFIX = /usr/local
# Choose any that compiles:
MINGW64_VERSION = 5.0.4
else
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

# Source location of ghdl original distribution:
GHDL_SRC = /data/src/ghdl.latest

# Mingw32 specifics:
MINGW64_SRC = $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION)

MINGW32_W64_INCLUDE = /usr/x86_64-w64-mingw32/include
