#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

sudo mkdir -p /opt/mathworks/
sudo mv /tmp/startup/ /opt/mathworks/
chmod +x /opt/mathworks/startup/*.sh

sudo mkdir -p /opt/mathworks/wallpaper
sudo mv /var/tmp/config/mate/MathWorks_Desktop_Wallapper.jpg /opt/mathworks/wallpaper

# Install runtime script
sudo cp /tmp/runtime/set-newuser-permissions.sh /etc/profile.d/