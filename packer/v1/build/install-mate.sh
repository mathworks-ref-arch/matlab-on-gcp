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

# Configure MATE
sudo apt-get -qq install dkms
sudo dkms autoinstall

# Wait for dpkg lock to be free before proceeding
if ! wait_for_dpkg_lock; then
    echo "Failed to acquire dpkg lock after waiting. However, still proceeding..."
fi

# Configure the MATE theme and panel layout (aka desktop layout)
# https://lauri.xn--vsandi-pxa.com/2015/03/dconf.html
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install dconf-cli
sudo mkdir -p /etc/dconf/profile
sudo cp -f /var/tmp/config/mate/user /etc/dconf/profile

sudo mkdir -p /etc/dconf/db/site.d
sudo cp -f /var/tmp/config/mate/panel /etc/dconf/db/site.d
sudo cp -f /var/tmp/config/mate/theme /etc/dconf/db/site.d
sudo rm -f /etc/dconf/db/site
sudo dconf update

# Configure the MATE default menus for all users
# https://developer.gnome.org/menu-spec/
sudo cp -f /var/tmp/config/mate/mate-applications.menu /etc/xdg/menus
sudo mkdir -p /usr/share/applications
# See https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles
sudo cp -f /var/tmp/config/desktop/*.desktop /usr/share/applications
sudo mkdir -p /usr/share/mate/desktop-directories
sudo cp -f /var/tmp/config/mate/mate-matlab.directory /usr/share/mate/desktop-directories
sudo mkdir -p /etc/skel/Desktop

# Create basic directories
sudo cp /var/tmp/config/mate/user-dirs.defaults /etc/xdg/user-dirs.defaults
sudo -u packer bash -c xdg-user-dirs-update

# Configure MATLAB icon on desktop
sudo cp -f /var/tmp/config/desktop/matlab.desktop /etc/skel/Desktop
sudo chmod a+x /etc/skel/Desktop/matlab.desktop
sudo sed -Ei "s/Name=MATLAB/Name=MATLAB $RELEASE/" /etc/skel/Desktop/matlab.desktop
sudo mkdir -p /home/packer/Desktop
sudo cp -f /etc/skel/Desktop/matlab.desktop /home/packer/Desktop/
sudo sed -i '/\[Desktop Entry\]/a Trusted=true' /home/packer/Desktop/matlab.desktop

# Configure the MATLAB icon
sudo mkdir -p /usr/share/matlab
sudo cp -f /var/tmp/config/matlab/icons/matlab32.png /usr/share/matlab
sudo cp -f /var/tmp/config/matlab/icons/matlab64.png /usr/share/matlab
sudo ln -sf /usr/share/matlab/matlab32.png /usr/share/icons/hicolor/32x32/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/64x64/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/128x128/apps/matlab.png

# Refresh the icon cache
sudo apt-get -qq install gtk-update-icon-cache
sudo update-icon-caches /usr/share/icons/*
sudo dconf update

# Sleep for 1 minute to let any pending process complete
sleep 60

# Install MATE Desktop Environment
sudo apt-get -qq install mate-desktop-environment mate-session-manager

# Register mate-session with update-alternatives
sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/mate-session 1500

# Now set mate-session as the default x-session-manager
sudo update-alternatives --set x-session-manager /usr/bin/mate-session