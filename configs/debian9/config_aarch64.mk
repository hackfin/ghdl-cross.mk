# Local configuration make settings for ghdl-cross setup
#

# You have to edit the locations in this Makefile to make stuff compile.

# unused: PARALLELIZE = -j3

MAKE_OPTIONS = 

BUILD_INFO = 'Debian 9 aarch64 build, non-sandbox'

REQUIRED_PACKAGES = gnat-mingw-w64

# Development version:

VERSION = 0.003

CC = gcc-7
CXX = g++-7

export CC CXX

# override:
GCC_VERSION = 7.2.0

PREPARE_BUILD = true

# Don't build from sandbox, but make sure REQUIRED_PACKAGES are installed
# BUILD_FROM_SANDBOX = y

MINGW64_VERSION = 6.0.0

INSTALL_PREFIX = /usr/local

# Source location of binutils:
BINUTILS_SRC = $(TOOLCHAIN_SRC)/binutils-2.31
# Source location of gcc:
GCC_SRC = $(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION)

# Define empty, so we use default cross mingw compiler
# Mingw32 specifics:
MINGW64_SRC = $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION)

