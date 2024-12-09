#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

# Enable PasswordAuthentication in /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication[[:space:]]\+no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable PasswordAuthentication in all files within /etc/ssh/sshd_config.d/
# This is needed because of a new change in Ubuntu 22.04+ versions.
# Solution Reference: https://serverfault.com/a/1118144
for config_file in /etc/ssh/sshd_config.d/*; do
    sed -i 's/^#\?PasswordAuthentication[[:space:]]\+no/PasswordAuthentication yes/' "$config_file"
done

# Restart SSH service to apply changes
systemctl restart sshd
