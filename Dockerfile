FROM debian:stable-slim as Base
LABEL maintainer="docker@donnellan.de"
    USER root
    RUN mkdir -p /home/openscad
    RUN add-apt-repository ppa:openscad/releases
    RUN apt-get update \
        && apt-get install -y \
            curl software-properties-common

FROM Base as Node
    RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

FROM Node as Python
    RUN apt-get update \
        && apt-get install -y \
            git python3 python3-pip xvfb x11-utils nodejs

From Python as Openscad
    RUN apt update && apt install -y \
            openscad
    ENV PATH /opt/conda/envs/beakerx/bin:$PATH
    RUN pip3 install jupyterlab 
    WORKDIR /opt
    RUN git clone https://github.com/pschatzmann/openscad-kernel
    WORKDIR /opt/openscad-kernel
    RUN pip3 install .
    RUN python3 -m iopenscad.install
    RUN jupyter labextension install jupyterlab-openscad-syntax-highlighting
#RUN jupyter labextension install jupyterlab-viewer-3d
    WORKDIR /home/openscad
    RUN cp /opt/openscad-kernel/documentation/* /home/openscad/

FROM Install
    CMD jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser