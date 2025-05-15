#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

cd /tmp
sudo apt-get -qq update

MATLAB_RELEASE_LOWER=$(echo "${RELEASE}" | awk '{print tolower($0)}')
UBUNTU_VERSION=$(lsb_release -rs)

# Use environment variable if set, otherwise use the default URL
DEPS_LIST=${DEPS_LIST:-"https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE_LOWER}/ubuntu${UBUNTU_VERSION}/base-dependencies.txt"}
# Print which DEPS_LIST URL is being used
echo "Using dependencies list from: ${DEPS_LIST}"

touch base-dependencies.txt
wget -O base-dependencies.txt $DEPS_LIST || echo "Unable to find MATLAB ${RELEASE} dependencies file for Ubuntu ${UBUNTU_VERSION}."
sudo apt-get -qq install --no-install-recommends $(cat base-dependencies.txt)
rm base-dependencies.txt
