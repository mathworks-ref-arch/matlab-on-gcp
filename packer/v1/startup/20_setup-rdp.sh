#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

# Reload systemd to pick up any unit file changes from the build
systemctl daemon-reload

# Enable the xrdp service
systemctl enable xrdp

# Ensure Mesa GL is active for xrdp software rendering
# (prevents NVIDIA libEGL segfault on instances without a physical GPU)
MESA_CONF="/usr/lib/x86_64-linux-gnu/mesa/ld.so.conf"
if [ -f "$MESA_CONF" ]; then
    update-alternatives --set x86_64-linux-gnu_gl_conf "$MESA_CONF" 2>/dev/null || true
    ldconfig
fi

# Function to start the xrdp service with retry logic
start_xrdp_with_retry() {
    local max_attempts=5
    local attempt=1
    local success=0

    while [ $attempt -le $max_attempts ]; do
        # Restart xrdp (which manages sesman internally on newer versions)
        systemctl restart xrdp
        # Restart sesman separately if it exists as a standalone service
        systemctl restart xrdp-sesman 2>/dev/null || true

        if systemctl is-active --quiet xrdp; then
            success=1
            echo "xrdp started successfully on attempt $attempt."
            break
        else
            echo "Attempt $attempt to start xrdp failed. Retrying..."
            attempt=$((attempt + 1))
            sleep 5
        fi
    done

    if [ $success -eq 0 ]; then
        echo "Failed to start xrdp after $max_attempts attempts. Continuing with remaining setup."
    fi
}

# Start the xrdp service with retry logic
start_xrdp_with_retry
