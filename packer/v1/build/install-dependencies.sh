#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Initialise apt
echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections
sudo apt-get -qq update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Ensure essential utilities are installed
sudo apt-get -qq install gcc make unzip wget

cd /tmp

# Install pip
sudo apt-get -qq install python3-pip

# Install nvidia-driver
if [[ -n "${NVIDIA_DRIVER_VERSION}" ]]; then
  wget -O cuda-keyring.deb ${NVIDIA_CUDA_KEYRING_URL}
  sudo dpkg -i cuda-keyring.deb
  sudo apt-get update
  sudo apt-get -y -qq install --no-install-recommends "nvidia-driver-${NVIDIA_DRIVER_VERSION}-server"
fi

# Install Firefox to ensure a web browser is available
sudo apt-get -qq install firefox
