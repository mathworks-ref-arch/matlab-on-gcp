#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Function to check for dpkg lock
wait_for_dpkg_lock() {
    local wait_time=0
    local max_wait=600   # Maximum wait time in seconds (e.g., 10 minutes)
    local interval=10    # Interval to check the lock status

    echo "Checking for dpkg lock..."

    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        echo "Waiting for other software managers to finish..."
        sleep $interval
        wait_time=$((wait_time + interval))

        if [ "$wait_time" -ge "$max_wait" ]; then
            echo "Timed out waiting for dpkg lock."
            return 1
        fi
    done

    echo "dpkg lock is free."
    return 0
}

echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections

echo "Update Ubuntu repositories and upgrade to latest packages..."
sudo apt-get -qq clean
sudo mv /var/lib/apt/lists /var/lib/apt/lists.broke
sudo mkdir -p /var/lib/apt/lists/partial

# Clear locks: https://unix.stackexchange.com/questions/315502/how-to-disable-apt-daily-service-on-ubuntu-cloud-vm-image
sudo systemctl stop apt-daily.service
sudo systemctl kill --kill-who=all apt-daily.service

# Wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | grep -qE '(dead|failed)'); do
  sleep 2;
done

# Wait until locks clear
sleep 10

# Make sure package list and packages are up to date
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  upgrade

###################################################### CONFIGURE XRDP ######################################################
# Enable xfce
sudo rm -f /usr/bin/x-session-manager
sudo ln -s /usr/bin/xfce4-session /usr/bin/x-session-manager

# Install whois
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install whois

# Install/Configure xrdp
# https://github.com/neutrinolabs/xrdp/wiki/Building-on-Debian-8
sudo mv /var/lib/dpkg/info/install-info.postinst /var/lib/dpkg/info/install-info.postinst.bad

UBUNTU_VERSION=$(lsb_release -rs | tr -d '.')

# Wait for dpkg lock to be free before proceeding
if ! wait_for_dpkg_lock; then
    echo "Failed to acquire dpkg lock after waiting. However, still proceeding..."
fi

sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install \
  autoconf \
  automake \
  bison \
  flex \
  g++ \
  gcc \
  git \
  intltool \
  libfuse-dev \
  libjpeg-dev \
  libmp3lame-dev \
  libpam0g-dev \
  libpixman-1-dev \
  libssl-dev \
  libtool \
  libx11-dev \
  libxfixes-dev \
  libxml2-dev \
  libxrandr-dev \
  make \
  nasm \
  pkg-config \
  xserver-xorg-dev \
  xsltproc \
  xutils \
  xutils-dev \
  "$([[ $UBUNTU_VERSION -lt 2204 ]] && echo "python-libxml2" || echo "python3-libxml2")"


# Wait for dpkg lock to be free before proceeding
if ! wait_for_dpkg_lock; then
    echo "Failed to acquire dpkg lock after waiting. However, still proceeding..."
fi

sudo apt-get -qq install --reinstall xserver-xorg-video-intel xserver-xorg-core

BASE_DIR=$(pwd)
mkdir -p "${BASE_DIR}"/git/neutrinolabs
cd "${BASE_DIR}"/git/neutrinolabs
wget --no-verbose https://github.com/neutrinolabs/xrdp/releases/download/v0.9.9/xrdp-0.9.9.tar.gz
wget --no-verbose https://github.com/neutrinolabs/xorgxrdp/releases/download/v0.2.12/xorgxrdp-0.2.12.tar.gz

cd "${BASE_DIR}"/git/neutrinolabs
tar xvfz xrdp-0.9.9.tar.gz
cd "${BASE_DIR}"/git/neutrinolabs/xrdp-0.9.9
./bootstrap
./configure --enable-fuse --enable-mp3lame --enable-pixman
sudo make install
sudo ln -sf /usr/local/sbin/xrdp /usr/sbin
sudo ln -sf /usr/local/sbin/xrdp-sesman /usr/sbin

cd "${BASE_DIR}"/git/neutrinolabs
tar xvfz xorgxrdp-0.2.12.tar.gz
cd "${BASE_DIR}"/git/neutrinolabs/xorgxrdp-0.2.12
./bootstrap
./configure
make
sudo make install

cd "${BASE_DIR}"
sudo rm -rf git

sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  autoremove

# Configure the XServer so it can be started by users connecting with remote desktop.
# Ensure there is an Xwrapper.config file.
FILE=/etc/X11/Xwrapper.config
if test -f "$FILE"; then
  sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
  echo "Xwrapper.config updated"
else
  sudo echo "allowed_users=anybody" | sudo tee -a /etc/X11/Xwrapper.config
  echo "Xwrapper.config created"
fi

# Set default permissions
sudo chmod -R a+w /var/tmp/config

# Fix XRDP icons
sudo mkdir -p /usr/share/matlab
sudo cp /var/tmp/config/matlab/icons/matlabicon24b.bmp /usr/share/matlab

# Fix xrdp login screen options
sudo cp /var/tmp/config/xrdp/xrdp.ini /etc/xrdp/xrdp.ini
# Fix xrdp bit depth and folder sharing options
sudo cp /var/tmp/config/xrdp/sesman.ini /etc/xrdp/sesman.ini

# Installing NVDIA driver
sudo apt-get -qq install --no-install-recommends "nvidia-driver-${NVIDIA_DRIVER_VERSION}"

sudo cp /var/tmp/config/nvidia/xorg.conf /etc/X11/xorg.conf

# Remove gnome option from the lightdm menu
if [[ -e "/usr/share/xsessions/packer.desktop" ]]; then
    sudo mv /usr/share/xsessions/packer.desktop /usr/share/xsessions/packer.desktop.disabled
fi
sudo systemctl set-default multi-user.target

sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport

# Disable ubuntu upgrade notification pop-ups
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Disable both services. one will be enabled on boot
sudo systemctl disable xrdp

# Disable managed color device pop-up
sudo cp /var/tmp/config/matlab/999-allow-colord.conf /etc/polkit-1/localauthority.conf.d/999-allow-colord.conf

sudo reboot