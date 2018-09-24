# GHDL cross build scripts

This is a collection of Makefiles to build a cross compiling GHDL, currently at a basic stage and for experienced developers.
The result is a GHDL binary which produces an executable for instance in a native Linux system that runs on another target, like
  - Windows 32 bit (EXE)
  - ARM64 architecture (under construction)

## Tested platforms

  - [X] Host: x86_64  target: i686-mingw-w64-mingw32
  - [ ] Host: aarch64  target: i686-mingw-w64-mingw32
  - `[dropped]` Host: x86_64  target: i586-mingw32
    Dropped due to lacking API support, use i686-mingw-w64-mingw32 instead
  
## Preparing

Currently, the default GCC version used is 7.2.0.
Check out the GHDL cross compile branch from:

```sh
$ git clone https://github.com/hackfin/ghdl.git
```

After downloading the GCC sources and the cross-compile GHDL branch, you need to complete these steps:
  - Create config.mk
  - Download prerequisites (MPFR, GMP, ...)
  - Configure GHDL

### Creating config.mk

Before running the make process, you need to create a config.mk file from config.mk.in, then edit the variables to point to the corresponding source directories, etc.

### Configuring GCC and GHDL

This can be done through the included Makefile prepare.mk:
```sh
$ make prepare
$ make prepare-ghdl
```

## Building

Depending on whether `BUILD_FROM_SANDBOX` is set, a somewhat sandboxed *cross* compiler is used to build the GHDL target files. If a cross compiler with ADA support and the gnat tools (gnatmake, ...) including all target libraries (like mingw32 runtime) is already installed locally, leave this variable undefined in config.mk

### Sandboxed cross compiler

The build rule to build and install the sandboxed compiler:
```sh
$ make install-sandbox
```

### Building Cross-ghdl:

```sh
$ make all-ghdl_cross
```
