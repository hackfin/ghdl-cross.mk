# Local configuration make settings for ghdl-cross setup
#

# You have to edit the locations in this Makefile to make stuff compile.

# unused: PARALLELIZE = -j3

MAKE_OPTIONS = 

# Development version:

VERSION = 0.002

# Workaround for asm/errno.h error:
PREPARE_BUILD = export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu; \
	export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

GCC_VERSION = 7.2.0

INSTALL_PREFIX=/usr/local

# Root toolchain directory
TOOLCHAIN_SRC = /data/src/gcc-toolchain
# Set to directory where stuff should be built:
BUILD_ROOT=/media/strubi/scratch/build

# Define when we build GHDL with a cross compiler built in the sandbox:
BUILD_FROM_SANDBOX = y


# Source location of binutils:
# BINUTILS_SRC = $(TOOLCHAIN_SRC)/binutils-2.21.1
BINUTILS_SRC = $(TOOLCHAIN_SRC)/binutils-2.31
# Source location of gcc:
GCC_SRC = $(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION)

GHDL_SRC = /data/src/ghdl.latest
# Source location of ghdl original distribution:

# MINGW_CC =

# Mingw32 specifics:
MINGW_RT_SRC = $(TOOLCHAIN_SRC)/mingwrt-5.0.2
# MINGW_RT_SRC = $(TOOLCHAIN_SRC)/mingwrt-4.0.3-1-mingw32-src
WIN32API_SRC = $(TOOLCHAIN_SRC)/w32api-5.0.2
MINGW64_SRC = $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION)
MINGW_RT_ARCHIVE = /media/scratch/Downloads/mingwrt-3.20-2-mingw32-src.tar.lzma


