# Download rules for semi-automated GHDL builds

CURDIR = $(shell pwd)


$(TOOLCHAIN_SRC)/$(GCC_TARFILE):
	cd $(TOOLCHAIN_SRC) && \
	wget ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-$(GCC_VERSION)/$(GCC_TARFILE)

$(TOOLCHAIN_SRC)/binutils-2.31.tar.xz:
	cd $(TOOLCHAIN_SRC); \
	wget http://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.xz

$(GCC_SRC): $(TOOLCHAIN_SRC)/$(GCC_TARFILE)
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking $<, please be patient..." ; \
	tar xf $< ; \
	echo "---------------------------------------------------"

$(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION).tar.bz2:
	@cd $(TOOLCHAIN_SRC) && \
	wget "https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$(MINGW64_VERSION).tar.bz2"

$(MINGW64_SRC): $(TOOLCHAIN_SRC)/mingw-w64-v$(MINGW64_VERSION).tar.bz2
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking $<, please be patient..." ; \
	tar xfj $(notdir $<) ; \
	echo "---------------------------------------------------"

$(BINUTILS_SRC): $(TOOLCHAIN_SRC)/binutils-2.31.tar.xz
	@cd $(TOOLCHAIN_SRC) && \
	echo "---------------------------------------------------" ; \
	echo "Unpacking $<, please be patient..." ; \
	tar xf $(notdir $<) ; \
	echo "---------------------------------------------------"

$(GHDL_SRC): 
	cd $@/.. && \
	git clone https://github.com/hackfin/ghdl.git

download-gcc: $(UNIFIED_BUILDLIBS)

download-binutils: $(BINUTILS_SRC)

download-runtime: $(MINGW64_SRC)

download-all: download-gcc download-binutils download-runtime | $(GHDL_SRC)


.PHONY: download-all download-binutils download-gcc download-runtime
