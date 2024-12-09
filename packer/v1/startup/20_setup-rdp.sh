#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

systemctl enable xrdp
systemctl start xrdp
