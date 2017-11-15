FROM phusion/baseimage:0.9.19
MAINTAINER Luke de Oliveira <lukedeo@ldo.io>

USER root

RUN apt-get -qq update && apt-get -y --force-yes install \
        build-essential \
        python-dev \
        libxpm-dev \
        libxft-dev \
        libxext-dev \
        libpng3 \
        gfortran \
        libssl-dev \
        libpcre3-dev \
        libgl1-mesa-dev \
        libglew1.5-dev \
        libftgl-dev \
        libmysqlclient-dev \
        libfftw3-dev \
        libcfitsio3-dev \
        graphviz-dev \
        libavahi-compat-libdnssd-dev \
        libldap2-dev \
        libxml2-dev \
        bc \
        curl \
        git \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        python-pip \
        python-numpy \
        python-scipy \
        libhdf5-serial-dev \
    && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

ADD https://root.cern.ch/download/root_v5.34.32.Linux-ubuntu14-x86_64-gcc4.8.tar.gz /var/tmp/root.tar.gz
RUN tar xzf /var/tmp/root.tar.gz -C /opt && rm /var/tmp/root.tar.gz

# Build pip deps
RUN pip install --no-cache-dir \
        keras[h5py] \
        tensorflow \
        root-numpy \
        rootpy \
        tqdm \
        deepdish \
        ipython<6 \
        notebook==5.2.1 \
        matplotlib \
        scikit-learn \
        pandas

# Build custom deps
RUN pip install --no-cache-dir \
        git+https://github.com/mickypaganini/YaleATLAS

ENV KERAS_BACKEND   "tensorflow"

ENV NB_USER nb_user
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
