FROM reznik/gnat:gpl.2017.slim 
# Alternative:
# FROM ghdl/ghdl:buster-gcc-7.2.0 

RUN apt-get update; apt-get install -y \
	make git wget libz-dev texinfo xz-utils bzip2


RUN useradd -u 1000 -g 100 -m -s /bin/bash build 

RUN mkdir /home/build/src
RUN mkdir /home/build/build
RUN mkdir /home/build/scripts
RUN echo "export PATH=$PATH:/opt/gnat/bin" >> /home/build/.bashrc

COPY ghdlbuild_sfx.sh /home/build/scripts/

RUN chown -R build /home/build
USER build

