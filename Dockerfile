# Buster slim gcc-8 docker file to build ghdl and yosys
FROM debian:buster-slim

RUN apt-get update --allow-releaseinfo-change ; \
	apt-get install -y \
	fakeroot debhelper gnat-8 texinfo zlib1g-dev pkg-config \
	git python3-dev \
	libboost-dev libboost-filesystem-dev libboost-thread-dev \
	libboost-program-options-dev libboost-python-dev libboost-iostreams-dev \
	bison flex tcl-dev libreadline6-dev libffi-dev \
	wget 

RUN useradd -u 1000 -g 100 -m -s /bin/bash build && \
    mkdir /home/build/src  && \
    mkdir /home/build/build && \
    mkdir /home/build/scripts && \
    echo "export PATH=$PATH:/opt/gnat/bin" >> /home/build/.bashrc

COPY recipes /home/build/scripts/recipes
COPY configs /home/build/scripts/configs
COPY docker_config.mk /home/build/scripts/

RUN chown -R build /home/build

USER build
WORKDIR /home/build

# RUN useradd -u 1000 -g 100 -m -s /bin/bash pyosys 

