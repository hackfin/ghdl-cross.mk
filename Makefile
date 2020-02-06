DESTDIR_DEBIAN = $(CURDIR)/debian/tmp

# Enable when building mingw32 cross GHDL:
# CROSS_PREFIX = mingw32

install: 
	$(MAKE) -f Makefile.native install INSTALL_ROOT=$(DESTDIR_DEBIAN)

install-cross:
	$(MAKE) -C recipes install-libz all-ghdl_cross DESTDIR=$(DESTDIR_DEBIAN)

deb:
	fakeroot debian/rules binary CROSS_PREFIX=$(CROSS_PREFIX)

debclean:
	fakeroot debian/rules clean

