# Buster slim gcc-8 docker file to build ghdl and yosys
FROM debian:buster-slim

RUN apt-get update --allow-releaseinfo-change ; \
	apt-get install -y \
	fakeroot debhelper gnat-8 texinfo zlib1g-dev pkg-config \
	git python3-dev \
	libboost-dev libboost-filesystem-dev libboost-thread-dev \
	libboost-program-options-dev libboost-python-dev libboost-iostreams-dev \
	bison flex tcl-dev libreadline6-dev libffi-dev

RUN useradd -u 1000 -g 100 -m -s /bin/bash pyosys 

