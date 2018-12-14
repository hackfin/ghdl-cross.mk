DESTDIR_DEBIAN = $(CURDIR)/debian/tmp

install: 
	$(MAKE) -f Makefile.native install INSTALL_ROOT=$(DESTDIR_DEBIAN)

install-cross:
	$(MAKE) -C recipes install-libz all-ghdl_cross DESTDIR=$(DESTDIR_DEBIAN)

deb:
	fakeroot debian/rules binary

debclean:
	fakeroot debian/rules clean

