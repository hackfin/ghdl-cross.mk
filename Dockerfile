# Setup for non-sandbox build (docker hub)
FROM reznik/gnat:gpl.2017.slim 
# See sandbox config in 
# Dockerfile.gcc-7.2.0 

RUN apt-get update; apt-get install -y \
	make git wget libz-dev texinfo xz-utils bzip2 file \
	gnat-mingw-w64 g++

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

