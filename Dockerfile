FROM ubuntu:18.04

LABEL maintainer="stefan.golinschi@gmail.com"

# environment
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV USERNAME="user"
ENV CONDA_ENV="zephyr-dev"
ENV CMAKE_VERSION="3.15.3"
ENV WEST_VERSION="0.6.3"
ENV DEBIAN_FRONTEND="noninteractive"

# install requirements
RUN apt-get install --no-install-recommends -y \
    git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
    python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib

# install dev tools
RUN apt-get install --no-install-recommends -y \
    vim tmux meld git sudo

# add user
RUN useradd -G video -ms /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Install conda under user
USER ${USERNAME}
COPY resources/Miniconda3-4.7.10-Linux-x86_64.sh /opt/miniconda.sh
RUN /bin/bash /opt/miniconda.sh -b -p /home/${USERNAME}/miniconda3 \
    && echo '. ${HOME}/miniconda3/etc/profile.d/conda.sh' >> ~/.bashrc \
    && sudo rm -f /opt/miniconda.sh \
    && . ${HOME}/miniconda3/etc/profile.d/conda.sh \
    && conda clean -ay

USER ${USERNAME}
RUN \
    . ${HOME}/miniconda3/etc/profile.d/conda.sh \
    && cd ${HOME} \
    && conda install setuptools \
    && conda update conda \
    && conda create -n ${CONDA_ENV} \
           python=3.7 \
    && conda clean -ay \
    && conda activate ${CONDA_ENV} \
    && pip install cmake==${CMAKE_VERSION} \
	&& pip install west==${WEST_VERSION}

# install zephyr SDK
USER ${USERNAME}
ENV ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
ENV ZEPHYR_SDK_INSTALL_DIR="/home/user/zephyr-sdk-0.10.3"
ENV ZEPHYR_SDK_VERSION="0.10.3"

COPY resources/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run

USER root
RUN \
	chown ${USERNAME} /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run \
    && chmod +x /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run

USER ${USERNAME}
RUN \
    /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run -- -d ${ZEPHYR_SDK_INSTALL_DIR}

# install zephyr source code
USER ${USERNAME}
RUN \
    cd /home/user \
    && . ${HOME}/miniconda3/etc/profile.d/conda.sh \
    && conda activate ${CONDA_ENV} \
    && west init zephyrproject \
    && cd zephyrproject \
    && west update \
    && pip install -r zephyr/scripts/requirements.txt

# install Segger J-Link
USER root
COPY resources/nRF-Command-Line-Tools_10_4_1_Linux-amd64.tar.gz /opt/nRF-Command-Line-Tools_10_4_1_Linux-amd64.tar.gz
RUN \
    mkdir -p /opt/nRF-Command-Line-Tools \
    && tar -xzf /opt/nRF-Command-Line-Tools_10_4_1_Linux-amd64.tar.gz -C /opt/nRF-Command-Line-Tools \
    && dpkg -i /opt/nRF-Command-Line-Tools/JLink_Linux_V650b_x86_64.deb \
    && dpkg -i /opt/nRF-Command-Line-Tools/nRF-Command-Line-Tools_10_4_1_Linux-amd64.deb

# on login:
# source zephyr env
# enable conda env
USER ${USERNAME}
RUN cd ${HOME} \
    && echo "bash -c 'source /home/user/zephyrproject/zephyr/zephyr-env.sh'" >> ~/.bashrc \
    && echo "conda activate ${CONDA_ENV}" >> ~/.bashrc
WORKDIR /home/user/zephyrproject/zephyr

