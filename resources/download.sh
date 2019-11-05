#!/bin/bash

ZEPHYR_SDK_FILE="zephyr-sdk-0.10.3-setup.run"
MINICONDA_INSTALLER_FILE="Miniconda3-4.7.10-Linux-x86_64.sh"
NRF_CMDTOOLS_FILE="nRFCommandLineTools1041Linuxamd64tar.gz"
SEGGER_JLINK_INSTALLER_FILE="JLink_Linux_V654a_x86_64.deb"


if test -f "${ZEPHYR_SDK_FILE}"; then
	echo "ZEPHYR_SDK_FILE already installed."
else
	echo -n "Downloading ZEPHYR_SDK_FILE..." 
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.3/zephyr-sdk-0.10.3-setup.run > /dev/null 2>&1
	echo "done"
fi

if test -f "${MINICONDA_INSTALLER_FILE}"; then
	echo "MINICONDA_INSTALLER_FILE already installed."
else
	echo -n "Downloading MINICONDA_INSTALLER_FILE..." 
	wget https://repo.continuum.io/miniconda/Miniconda3-4.7.10-Linux-x86_64.sh > /dev/null 2>&1
	echo "done"
fi

if test -f "${NRF_CMDTOOLS_FILE}"; then
	echo "NRF_CMDTOOLS_FILE already installed."
else
	echo -n "Downloading NRF_CMDTOOLS_FILE..." 
	wget https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/nRFCommandLineTools1041Linuxamd64tar.gz > /dev/null 2>&1
	echo "done"
fi

