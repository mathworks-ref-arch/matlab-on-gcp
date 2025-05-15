#!/usr/bin/env bash
#
# Copyright 2024-2025 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

# Enable the xrdp service
systemctl enable xrdp

# Function to start the xrdp service with retry logic
start_xrdp_with_retry() {
    local max_attempts=5
    local attempt=1
    local success=0

    while [ $attempt -le $max_attempts ]; do
        if systemctl start xrdp; then
            success=1
            break
        else
            echo "Attempt $attempt to start xrdp failed. Retrying..."
            attempt=$((attempt + 1))
            sleep 5  # Wait for 5 seconds before retrying
        fi
    done

    if [ $success -eq 0 ]; then
        echo "Failed to start xrdp after $max_attempts attempts."
        exit 1
    fi
}

# Start the xrdp service with retry logic
start_xrdp_with_retry
