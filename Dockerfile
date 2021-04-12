#this stage removes the need for git etc in further stages
#this is a general stage used to get remote content required later
FROM alpine as gitgetter
    RUN apk --update add git less curl openssh bash \
        && rm -rf /var/lib/apt/lists/* \
        && rm /var/cache/apk/*
    WORKDIR /git
    RUN git clone https://github.com/pschatzmann/openscad-kernel
    RUN curl -sL https://deb.nodesource.com/setup_12.x

FROM debian:stable-slim as base
LABEL maintainer="docker@donnellan.de"
    USER root
    RUN mkdir -p /home/openscad
    RUN apt-get update \
        && apt-get install -y \
            curl

FROM base as node
    RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

FROM node as python
    RUN apt-get update \
        && apt-get install -y \
            python3 python3-pip libffi-dev \
            xvfb x11-utils nodejs \
            pandoc \
            texlive-xetex texlive-fonts-recommended texlive-generic-recommended

From python as openscad
    RUN apt update \
        && apt install -y \
            openscad
    ENV PATH /opt/conda/envs/beakerx/bin:$PATH
    ENV DISPLAY :99
    RUN pip3 install jupyterlab 
    WORKDIR /opt
    COPY --from=gitgetter /git/openscad-kernel ./openscad-kernel/
    run ls -laR /opt
    WORKDIR /opt/openscad-kernel
    RUN pip3 install .
    RUN python3 -m iopenscad.install
    RUN jupyter labextension install jupyterlab-openscad-syntax-highlighting
#RUN jupyter labextension install jupyterlab-viewer-3d
    WORKDIR /home/openscad
    RUN cp /opt/openscad-kernel/documentation/* /home/openscad/

FROM openscad
    CMD jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser