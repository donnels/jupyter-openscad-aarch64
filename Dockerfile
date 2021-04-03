FROM alpine as gitGetter
    RUN apk --update add git less openssh \
        && rm -rf /var/lib/apt/lists/* \
        && rm /var/cache/apk/*
    WORKDIR /git
    RUN git clone https://github.com/pschatzmann/openscad-kernel

FROM debian:stable-slim as Base
LABEL maintainer="docker@donnellan.de"
    USER root
    RUN mkdir -p /home/openscad
    RUN apt-get update \
        && apt-get install -y \
            curl

FROM Base as Node
    RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

FROM Node as Python
    RUN apt-get update \
        && apt-get install -y \
            python3 python3-pip libffi-dev \
            xvfb x11-utils nodejs

From Python as Openscad
    RUN apt update \
        && apt install -y \
            openscad
    ENV PATH /opt/conda/envs/beakerx/bin:$PATH
    RUN pip3 install jupyterlab 
    WORKDIR /opt
    COPY --from=gitGetter /git/openscad-kernel .
    WORKDIR /opt/openscad-kernel
    RUN pip3 install .
    RUN python3 -m iopenscad.install
    RUN jupyter labextension install jupyterlab-openscad-syntax-highlighting
#RUN jupyter labextension install jupyterlab-viewer-3d
    WORKDIR /home/openscad
    RUN cp /opt/openscad-kernel/documentation/* /home/openscad/

FROM Openscad
    CMD jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser