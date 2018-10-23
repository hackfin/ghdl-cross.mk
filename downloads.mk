# If you don't have the next three installed, don't define them (then
# they'll be downloaded instead)
# Otherwise, you have to set *all* of them to the proper location.
# {

GMP_SRC = $(TOOLCHAIN_SRC)/gmp-5.0.4
MPFR_SRC = $(TOOLCHAIN_SRC)/mpfr-3.0.1
MPC_SRC = /data/src/mpc-1.0.1

# }

CURDIR = $(shell pwd)

# Get the mingw runtime source here:
# http://sourceforge.net/projects/mingw/files/MinGW/Base/mingw-rt/mingwrt-3.20/

$(MINGW_RT_SRC):
	cd $(TOOLCHAIN_SRC) && \
	tar xf $(MINGW_RT_ARCHIVE) --lzma
	cd $(MINGW_RT_SRC) && \
	patch -p1 < $(CURDIR)/patches/mingwrt-3.20-2.patch

$(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION).tar.xz:
	cd $(TOOLCHAIN_SRC) && \
	wget ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.xz



$(TOOLCHAIN_SRC)/binutils-2.31.tar.xz:
	cd $(TOOLCHAIN_SRC); \
	wget http://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.xz

$(GCC_SRC)/contrib/download_prerequisites: $(TOOLCHAIN_SRC)/gcc-$(GCC_VERSION).tar.xz
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking tar, please be patient..." ; \
	tar xf gcc-$(GCC_VERSION).tar.xz ; \
	echo "---------------------------------------------------"

$(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION).tar.bz2:
	@cd $(TOOLCHAIN_SRC) && \
	wget "https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$(MINGW64_VERSION).tar.bz2"

$(MINGW64_SRC): $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION).tar.bz2
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking tar, please be patient..." ; \
	tar xfj $(notdir $<) ; \
	echo "---------------------------------------------------"

$(BINUTILS_SRC)/configure: $(TOOLCHAIN_SRC)/binutils-2.31.tar.xz
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking tar, please be patient..." ; \
	tar xf $(notdir $<) ; \
	echo "---------------------------------------------------"

$(GHDL_SRC): 
	cd $@/.. && \
	git clone https://github.com/hackfin/ghdl.git

$(GHDL_SRC)/configure: | $(GHDL_SRC)

download-gcc: $(UNIFIED_BUILDLIBS)

download-binutils: $(BINUTILS_SRC)/configure

download-runtime: $(MINGW64_SRC)

download-all: download-gcc download-binutils


.PHONY: download-all download-binutils download-gcc
