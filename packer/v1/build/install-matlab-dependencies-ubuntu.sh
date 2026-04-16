#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

cd /tmp

MATLAB_RELEASE_LOWER=$(echo "${RELEASE}" | awk '{print tolower($0)}')
UBUNTU_VERSION=$(lsb_release -rs)
DEFAULT_URL="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE_LOWER}/ubuntu${UBUNTU_VERSION}/base-dependencies.txt"

# Use provided DEPS_LIST or fallback to default URL
SOURCE="${DEPS_LIST:-$DEFAULT_URL}"

# If SOURCE is a URL, download it; otherwise treat it as the package list
if [[ "$SOURCE" =~ ^https?:// ]]; then
    echo "Fetching dependencies from URL: $SOURCE"
    PACKAGES=$(wget -qO- "$SOURCE") || { echo "ERROR: Failed to download dependencies."; exit 1; }
else
    echo "Using provided hardcoded package list."
    PACKAGES="$SOURCE"
fi

# Validate that we actually have packages to install
if [[ -z "${PACKAGES//[[:space:]]/}" ]]; then
    echo "ERROR: Dependency list is empty."
    exit 1
fi

# Install
echo "Installing MATLAB ${RELEASE} dependencies for Ubuntu ${UBUNTU_VERSION}..."
sudo apt-get update -qq
sudo apt-get install -qq -y --no-install-recommends $PACKAGES

echo "✓ Dependencies installed successfully"
