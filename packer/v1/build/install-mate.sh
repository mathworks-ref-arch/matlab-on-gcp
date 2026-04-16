#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

echo "Installing MATE Desktop Environment..."

# Configure non-interactive mode
export DEBIAN_FRONTEND=noninteractive

####################################################
# INSTALL MATE DESKTOP
#####################################################

echo "Installing MATE desktop packages..."
sudo apt-get update -qq
sudo apt-get install -qq -y \
  mate-desktop-environment \
  mate-session-manager \
  dconf-cli \
  dkms

# Run DKMS autoinstall (for hardware drivers like NVIDIA)
echo "Running DKMS autoinstall..."
sudo dkms autoinstall || true

# Set MATE as default session manager
echo "Configuring MATE as default session..."
sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/mate-session 1500
sudo update-alternatives --set x-session-manager /usr/bin/mate-session

#####################################################
# CONFIGURE MATE THEME AND LAYOUT
#####################################################

echo "Configuring MATE theme and panel layout..."

# Configure dconf profile
sudo mkdir -p /etc/dconf/profile
sudo cp -f /var/tmp/config/mate/user /etc/dconf/profile/

# Configure MATE settings via dconf
sudo mkdir -p /etc/dconf/db/site.d
sudo cp -f /var/tmp/config/mate/panel /etc/dconf/db/site.d/
sudo cp -f /var/tmp/config/mate/theme /etc/dconf/db/site.d/

# Update dconf database
sudo rm -f /etc/dconf/db/site
sudo dconf update

#####################################################
# CONFIGURE MATE MENUS
#####################################################

echo "Configuring MATE application menus..."

# Configure MATE menus
sudo cp -f /var/tmp/config/mate/mate-applications.menu /etc/xdg/menus/

# Install desktop files
sudo mkdir -p /usr/share/applications
sudo cp -f /var/tmp/config/desktop/*.desktop /usr/share/applications/

# Install MATE directory definitions
sudo mkdir -p /usr/share/mate/desktop-directories
sudo cp -f /var/tmp/config/mate/mate-matlab.directory /usr/share/mate/desktop-directories/

#####################################################
# CONFIGURE USER DIRECTORIES
#####################################################

echo "Configuring default user directories..."

# Set default user directories
sudo cp -f /var/tmp/config/mate/user-dirs.defaults /etc/xdg/user-dirs.defaults

# Create directories for packer user
sudo -u packer bash -c 'xdg-user-dirs-update'

#####################################################
# CONFIGURE MATLAB DESKTOP ICON
#####################################################

echo "Installing MATLAB desktop icon..."

# Create skeleton desktop directory
sudo mkdir -p /etc/skel/Desktop

# Install MATLAB desktop launcher
sudo cp -f /var/tmp/config/desktop/matlab.desktop /etc/skel/Desktop/
sudo chmod a+x /etc/skel/Desktop/matlab.desktop
sudo sed -Ei "s/Name=MATLAB/Name=MATLAB ${RELEASE:-}/" /etc/skel/Desktop/matlab.desktop

# Configure for packer user
sudo mkdir -p /home/packer/Desktop
sudo cp -f /etc/skel/Desktop/matlab.desktop /home/packer/Desktop/
sudo sed -i '/\[Desktop Entry\]/a Trusted=true' /home/packer/Desktop/matlab.desktop
sudo chown -R packer:packer /home/packer/Desktop

#####################################################
# INSTALL MATLAB ICONS
#####################################################

echo "Installing MATLAB icons..."

# Copy MATLAB icons
sudo mkdir -p /usr/share/matlab
sudo cp -f /var/tmp/config/matlab/icons/matlab32.png /usr/share/matlab/
sudo cp -f /var/tmp/config/matlab/icons/matlab64.png /usr/share/matlab/

# Create icon symlinks
sudo mkdir -p /usr/share/icons/hicolor/{32x32,64x64,128x128}/apps
sudo ln -sf /usr/share/matlab/matlab32.png /usr/share/icons/hicolor/32x32/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/64x64/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/128x128/apps/matlab.png

# Update icon cache
echo "Updating icon cache..."
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/ 2>/dev/null || true

# Final dconf update
sudo dconf update

echo "MATE desktop installation completed successfully!"
