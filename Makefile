DESTDIR_DEBIAN = $(CURDIR)/debian/tmp

DESTDIR?= ..

# Enable when building mingw32 cross GHDL:
# CROSS_PREFIX = mingw32

# `make mrproper` cleans up system specifics. Do that when changing the
# GCC version

%: 
	$(MAKE) -C recipes -f Makefile.native $@ INSTALL_ROOT=$(DESTDIR_DEBIAN)

install-cross:
	$(MAKE) -C recipes install-libz all-ghdl_cross DESTDIR=$(DESTDIR_DEBIAN)

deb:
	cp  debian.in/* debian/
	fakeroot debian/rules binary CROSS_PREFIX=$(CROSS_PREFIX) \
		DESTDIR=$(DESTDIR)

debclean:
	fakeroot debian/rules clean

