#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

echo "Installing XRDP and configuring for MATE..."

# Configure non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Update package list and upgrade
echo "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

######################################################
# INSTALL XRDP
######################################################
echo "Installing xRDP..."
sudo apt-get install -qq -y \
  xrdp \
  xorgxrdp \
  whois \
  dbus-x11

######################################################
# NVIDIA COMPATIBILITY FIXES
#
# When NVIDIA drivers are installed but no physical GPU
# is present at runtime, two things break:
#  1. NVIDIA changes the Xorg ABI, breaking pre-built
#     xorgxrdp modules (undefined symbol errors).
#  2. NVIDIA's libEGL/GLX libraries segfault Xorg
#     when they try to access non-existent GPU hardware.
#
# Fix 2 & 3 are made UNCONDITIONAL because:
#  - xrdp uses a software framebuffer; GLX is unused.
#  - Mesa software rendering is correct for xrdp.
#  - Both fixes are harmless on non-NVIDIA systems.
######################################################

# Robust NVIDIA detection: check for actual files on disk,
# not just dpkg package names (which vary across repos).
NVIDIA_PRESENT=false
if [ -f /lib/x86_64-linux-gnu/libEGL_nvidia.so.0 ] \
   || [ -f /usr/lib/x86_64-linux-gnu/libEGL_nvidia.so.0 ] \
   || dpkg -l 2>/dev/null | grep -qi "nvidia-driver\|nvidia-dkms\|libnvidia-gl"; then
    NVIDIA_PRESENT=true
    echo "NVIDIA components detected on system."
else
    echo "No NVIDIA components detected."
fi

# Fix 1: Rebuild xorgxrdp from source (only needed when NVIDIA
# changes the Xorg ABI, breaking the pre-built .so modules)
if [ "$NVIDIA_PRESENT" = true ]; then
    echo "Rebuilding xorgxrdp from source for NVIDIA Xorg ABI compatibility..."
    sudo apt-get install -qq -y \
        build-essential pkg-config autoconf automake libtool \
        xserver-xorg-dev nasm libxfont-dev libxkbfile-dev git

    XORGXRDP_VERSION="v0.9.19"
    BUILD_DIR=$(mktemp -d)
    cd "$BUILD_DIR"
    git clone --branch "${XORGXRDP_VERSION}" --depth 1 https://github.com/neutrinolabs/xorgxrdp.git
    cd xorgxrdp
    ./bootstrap
    ./configure
    make -j"$(nproc)"
    sudo make install
    cd /tmp
    rm -rf "$BUILD_DIR"
    echo "xorgxrdp rebuilt successfully (${XORGXRDP_VERSION})"
fi

# Fix 2: Disable GLX in xrdp's Xorg config (UNCONDITIONAL)
# xrdp uses the xrdpdev software framebuffer; GLX is unused
# and loading it triggers the NVIDIA libEGL segfault.
XRDP_XORG_CONF="/etc/X11/xrdp/xorg.conf"
if [ -f "$XRDP_XORG_CONF" ]; then
    echo "Disabling GLX in xrdp Xorg config..."
    sudo sed -i 's/^[[:space:]]*Load "glx"/#   Load "glx"/' "$XRDP_XORG_CONF"
    echo "Commented out Load glx in $XRDP_XORG_CONF"

    if ! grep -q 'Option "GLX" "Disable"' "$XRDP_XORG_CONF"; then
        echo '' | sudo tee -a "$XRDP_XORG_CONF" > /dev/null
        echo 'Section "Extensions"' | sudo tee -a "$XRDP_XORG_CONF" > /dev/null
        echo '    Option "GLX" "Disable"' | sudo tee -a "$XRDP_XORG_CONF" > /dev/null
        echo 'EndSection' | sudo tee -a "$XRDP_XORG_CONF" > /dev/null
        echo "Added Extensions section to disable GLX"
    fi
fi

# Fix 3: Set Mesa as default GL provider for software rendering (UNCONDITIONAL)
MESA_CONF="/usr/lib/x86_64-linux-gnu/mesa/ld.so.conf"
if [ -f "$MESA_CONF" ]; then
    echo "Setting Mesa as default GL provider..."
    sudo update-alternatives --set x86_64-linux-gnu_gl_conf "$MESA_CONF" 2>/dev/null || true
    sudo ldconfig
    echo "GL provider set to Mesa"
fi

######################################################
# CONFIGURE XRDP FOR MATE
######################################################
# 1. Allow any user to start X server
sudo mkdir -p /etc/X11
echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config

# 2. Configure startwm.sh to launch MATE with D-Bus
echo "Configuring XRDP to use MATE session..."
sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak
sudo bash -c "cat > /etc/xrdp/startwm.sh" <<'EOF'
#!/bin/bash
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

if [ -r /etc/profile ]; then
    . /etc/profile
fi

export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=mate
export XDG_CURRENT_DESKTOP=MATE

# Ensure XDG_RUNTIME_DIR exists for the user
if [ -z "$XDG_RUNTIME_DIR" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
    mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null
    chmod 0700 "$XDG_RUNTIME_DIR" 2>/dev/null
fi

# Launch MATE session with D-Bus session bus
if [ -x /usr/bin/mate-session ]; then
    exec dbus-launch --exit-with-session /usr/bin/mate-session
fi

exec /bin/sh /etc/X11/Xsession
EOF
sudo chmod +x /etc/xrdp/startwm.sh

# 3. Fix SSL Cert permissions
if getent group ssl-cert > /dev/null; then
    sudo adduser xrdp ssl-cert
fi

# 4. Copy custom xRDP configurations (if they exist)
if [ -d "/var/tmp/config/xrdp" ]; then
    sudo cp /var/tmp/config/xrdp/xrdp.ini /etc/xrdp/xrdp.ini
    sudo cp /var/tmp/config/xrdp/sesman.ini /etc/xrdp/sesman.ini
fi

# 5. Fix Polkit Color Manager Crash
echo "Configuring Polkit rules for color management..."
sudo mkdir -p /etc/polkit-1/localauthority/50-local.d/
sudo bash -c "cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

######################################################
# SYSTEM CONFIGURATION
######################################################
if [[ -e "/usr/share/xsessions/packer.desktop" ]]; then
    sudo mv /usr/share/xsessions/packer.desktop /usr/share/xsessions/packer.desktop.disabled
fi

sudo systemctl set-default multi-user.target
sudo systemctl disable xrdp

sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport 2>/dev/null || true
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades 2>/dev/null || true

sudo apt-get autoremove -qq -y
sudo apt-get clean

echo "Ubuntu desktop (XRDP/MATE) configuration completed successfully!"
