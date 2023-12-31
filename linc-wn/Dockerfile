FROM ubuntu:20.04 as builder

# This Docker image builds the dependencies for the Rapthor pipeline.
# It lives on the head of its dependencies.

# Install all build-time dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        bison \
        build-essential \
        casacore-data \
        casacore-dev \
        cmake \
        flex \
        gfortran \
        git \
        libblas-dev \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-numpy-dev \
        libboost-program-options-dev \
        libboost-python-dev \
        libboost-system-dev \
        libboost-test-dev \
        libcfitsio-dev \
        libfftw3-dev \
        libgsl-dev \
        libgtkmm-3.0-dev \
        libhdf5-serial-dev \
        liblapack-dev \
        liblua5.3-dev \
        libncurses5-dev \
        libpng-dev \
        libpython3-dev \
        pkg-config \
        python3 \
        python3-casacore \
        python3-numpy \
        wcslib-dev \
        wget && \
    mkdir -p /src

WORKDIR /src

# Build portable binaries by default
ARG PORTABLE=TRUE

ARG LOFARSTMAN_COMMIT=master
RUN git clone --no-checkout \
        https://github.com/lofar-astron/LofarStMan && \
    mkdir LofarStMan/build && \
    cd LofarStMan && git checkout ${LOFARSTMAN_COMMIT} && \
    cd build && \
    cmake .. -DPORTABLE=${PORTABLE} && \
    make install -j`nproc`

ARG DYSCO_COMMIT=master
RUN git clone --no-checkout \
        https://github.com/aroffringa/dysco.git && \
    mkdir dysco/build && \
    cd dysco && git checkout ${DYSCO_COMMIT} && \
    cd build && \
    cmake .. -DPORTABLE=${PORTABLE} && \
    make install -j`nproc`

ARG IDG_COMMIT=master
# IDG does not work with --depth 1, because it needs all branches to
# determine its version :-(
RUN git clone  \
        https://git.astron.nl/RD/idg.git && \
    mkdir idg/build && \
    cd idg && git checkout ${IDG_COMMIT} && \
    cd build && \
    cmake .. && \
    make install -j`nproc`

ARG AOFLAGGER_COMMIT=master
RUN git clone --no-checkout \
        https://gitlab.com/aroffringa/aoflagger.git && \
    mkdir aoflagger/build && \
    cd aoflagger && git checkout ${AOFLAGGER_COMMIT} && \
    cd build && \
    cmake .. -DPORTABLE=${PORTABLE} && \
    make install -j`nproc`

ARG LOFARBEAM_COMMIT=master
RUN git clone --no-checkout \
        https://github.com/lofar-astron/LOFARBeam.git && \
    mkdir LOFARBeam/build && \
    cd LOFARBeam && git checkout ${LOFARBEAM_COMMIT} && \
    cd build && \
    cmake .. && \
    make install -j`nproc`

ARG EVERYBEAM_COMMIT=master
RUN git clone --no-checkout \
        https://git.astron.nl/RD/EveryBeam.git && \
    mkdir EveryBeam/build && \
    cd EveryBeam && git checkout ${EVERYBEAM_COMMIT} && \
    cd build && \
    cmake .. && \
    make install -j`nproc`

ARG SAGECAL_COMMIT=master
RUN git clone --no-checkout \
        https://github.com/nlesc-dirac/sagecal && \
    mkdir sagecal/build && \
    cd sagecal && git checkout ${SAGECAL_COMMIT} && \
    cd build && \
    cmake .. -DLIB_ONLY=1 && \
    make install -j`nproc`

ARG DP3_COMMIT=master
RUN git clone --no-checkout \
        https://git.astron.nl/RD/DP3.git && \
    mkdir DP3/build && \
    cd DP3 && git checkout ${DP3_COMMIT} && \
    cd build && \
    cmake .. -DPORTABLE=${PORTABLE} -DLIBDIRAC_PREFIX=/usr/local/ && \
    make install -j`nproc`

ARG WSCLEAN_COMMIT=master
RUN git clone --no-checkout \
        https://gitlab.com/aroffringa/wsclean.git && \
    mkdir wsclean/build && \
    cd wsclean && git checkout ${WSCLEAN_COMMIT} && \
    cd build && \
    cmake .. -DPORTABLE=${PORTABLE} && \
    make install -j`nproc`

# Do not use `pip` from the Debian repository, but fetch it from PyPA.
# This way, we are sure that the latest versions of `pip`, `setuptools`, and
# `wheel` are installed in /usr/local, the only directory we're going to copy
# over to the next build stage.
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py

# Install required python packages
RUN python3 -m pip install --no-cache-dir --upgrade \
    toil[cwl]

# Install current version of LINC. By adding this to the base image
# we can speed up the build of the final image, because all of LINC's
# dependencies will have been installed already and (probably) don't need to
# be updated.
ARG LINC_COMMIT=master
RUN git clone --depth 1 --branch ${LINC_COMMIT} \
        https://git.astron.nl/RD/LINC.git linc && \
        python3 -m pip install --no-cache-dir --upgrade ./linc



#---------------------------------------------------------------------------
# The image will now be rebuilt without adding the sources, in order to
# reduce the size of the image.
#---------------------------------------------------------------------------
FROM ubuntu:20.04 as runner

COPY --from=builder /usr/local /usr/local
RUN chmod +rx /usr/local/bin/*

SHELL ["/bin/bash", "-c"]

# Set default versions. Can be overridden from the command-line
ARG LINC_COMMIT=master
ARG LOFARSTMAN_COMMIT=master
ARG DYSCO_COMMIT=master
ARG SAGECAL_COMMIT=master
ARG IDG_COMMIT=master
ARG AOFLAGGER_COMMIT=master
ARG LOFARBEAM_COMMIT=master
ARG EVERYBEAM_COMMIT=master
ARG DP3_COMMIT=master
ARG WSCLEAN_COMMIT=master

# Add version information to the metadata of the image
LABEL \
    nl.astron.linc.lofarstman.version=${LOFARSTMAN_COMMIT} \
    nl.astron.linc.dysco.version=${DYSCO_COMMIT} \
    nl.astron.linc.sagecal.version=${SAGECAL_COMMIT} \
    nl.astron.linc.idg.version=${IDG_COMMIT} \
    nl.astron.linc.aoflagger.version=${AOFLAGGER_COMMIT} \
    nl.astron.linc.lofarbeam.version=${LOFARBEAM_COMMIT} \
    nl.astron.linc.everybeam.version=${EVERYBEAM_COMMIT} \
    nl.astron.linc.dp3.version=${DP3_COMMIT} \
    nl.astron.linc.wsclean.version=${WSCLEAN_COMMIT}

# Only install run-time required packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        casacore-tools \
        git \
        libatkmm-1.6-1v5 \
        libboost-date-time1.71.0 \
        libboost-filesystem1.71.0 \
        libboost-program-options1.71.0 \
        libboost-python1.71.0 \
        libcairomm-1.0-1v5 \
        libcasa-casa4 \
        libcasa-fits4 \
        libcasa-measures4 \
        libcasa-ms4 \
        libcasa-python3-4 \
        libcasa-scimath4 \
        libcasa-tables4 \
        libcfitsio8 \
        libfftw3-double3 \
        libfftw3-single3 \
        libglibmm-2.4-1v5 \
        libgomp1 \
        libgsl23 \
        libgtkmm-3.0-1v5 \
        libhdf5-103 \
        libhdf5-cpp-103 \
        liblapack3 \
        liblua5.3-0 \
        libpangomm-1.4-1v5 \
        libpng16-16 \
        libpython3.8 \
        libsigc++-2.0-0v5 \
        libstdc++6 \
        nodejs \
        python3 \
        python3-casacore \
        python3-distutils \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install WSRT Measures (extra casacore data)
# Note: The file on the ftp site is updated daily. When warnings regarding leap
# seconds appear, ignore them or regenerate the docker image.
RUN wget -q -O /WSRT_Measures.ztar \
        ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar && \
    cd /var/lib/casacore/data && \
    tar xfz /WSRT_Measures.ztar && \
    rm /WSRT_Measures.ztar

ENV LINC_DATA_ROOT=/usr/local/share/linc \
    PYTHONPATH=/usr/local/bin

RUN git clone --depth 1 --branch ${LINC_COMMIT} \
        https://git.astron.nl/RD/LINC.git /tmp/linc && \
        python3 -m pip install --no-cache-dir --upgrade /tmp/linc && \
        rm -rf /tmp/linc
