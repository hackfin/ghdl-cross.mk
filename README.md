# GHDL cross build scripts

This is a collection of Makefiles to build a cross compiling GHDL, currently at a basic stage and for experienced developers.
The result is a GHDL binary which produces an executable for instance in a
native Linux system that runs on another target, like
  - Windows 32 bit (EXE)
  - ARM64 architecture (under construction)

## Tested platforms

  - [X] Host: x86\_64  target: i686-mingw-w64-mingw32
  - [ ] Host: aarch64  target: i686-mingw-w64-mingw32
  - `[dropped]` Host: x86\_64  target: i586-mingw32
    Dropped due to lacking API support, use i686-mingw-w64-mingw32 instead
  
## Preparing the Docker container

  1. Create the `recipes/config.mk` file (see also below)
  2. Generate the distribution self extractable: `make -C recipes dist`
  3. Build the container: `docker build -t ghdlcross .`
  4. Start it: `docker run -it -w /home/build ghdlcross`

### Creating `config.mk`

Before running the make process, you need to create a `config.mk` file from
`config.mk.in` in `recipes/`, then edit the variables to point to the
corresponding source directories, etc.
When using the provided docker container, you'll only have to configure
`TOOLCHAIN_SRC` (this is where the sources will be downloaded to) and
`BUILD_ROOT` (the working and sandbox directory, preferrably on another
hard disk).

## Preparing the build

New behaviour: Since local installations make life very difficult for
proper reproduction, a Dockerfile is supplied for a reference building
environment.

Inside the container, enter the `scripts` directory and extract the build
scripts by
```sh
$ sh ghdlbuild_sfx.sh
```

The `GCC_VERSION` variable is generated from the locally installed GCC.

You can of course modify this variable for testing.

Tested versions:

| GCC version | Docker reference                              | Result    |
| ----------- | --------------------------------------------- | --------- |
| 6.3.0       | (Dockerfile, default)                         | PASS      |
| 7.2.0       | (Dockerfile.gcc-7.2.0)                        | PASS      |
| 7.3.0       | (Docker container: reznik/gnat:gpl.2018.slim) | FAIL      |

It is no longer necessary to download the sources manually.

All the following make calls take place in the `recipes/` directory

### Source download

Covered by `downloads.mk`:

```sh
$ make download-all
```

### Configuring GCC and GHDL

This can be done through the included Makefile `prepare.mk`:
```sh
$ make prepare
```

## Building

Depending on whether `BUILD_FROM_SANDBOX` is set, a somewhat sandboxed *cross*
compiler is used to build the GHDL target files. If a cross compiler with Ada
support and the gnat tools (gnatmake, ...) including all target libraries
(like mingw32 runtime) is already installed locally, leave this variable
undefined.

Note: The installed compiler *must* have the same version as `GCC_VERSION`
defined in `config.mk`. Since GNAT does not check for the proper compiler
version to compile itself, compiling may fail. By default, the version
installed on your system (or Docker container used) is selected.

### Sandboxed cross compiler

The build rule to build and install the sandboxed compiler:
This step is required on a 'bare' container created from the Dockerfile.

```sh
$ make install-sandbox
```

On some systems, the build process might complain about uninstalled GNAT,
even though you have the gnat package installed. Try specifying the CC
on the command line in this case and run the commands one by one:

```sh
$ make install-gcc CC=gcc-7
$ make install-target
...
```

Another classic is also, when g++ is not installed. Then you might get
the /lib/cpp sanity check complaint.

### Building Cross-ghdl:

```sh
$ make all-ghdl_cross
```

### Cleaning up

This part is not very complete yet. If something goes wrong, you may want
to repeat a process in particular by removing the corresponding 'stamp',
e.g.:

```sh
$ rm build-gcc
```

Starting almost entirely from scratch:
```sh
$ make mrproper
```

If you change `GCC_VERSION` somewhere in between, behaviour is completely
undefined, and the build will likely fail.
