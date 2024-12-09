#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

if [[ -n ${MLM_LICENSE_FILE} ]]; then
    echo "License MATLAB using Network License Manager"
    sed -i "s|^#export MLM_LICENSE_FILE=.*|export MLM_LICENSE_FILE='${MLM_LICENSE_FILE}'|" ${MLM_DEF_FILE}
else
    echo "License MATLAB using Online Licensing"
fi

# The remainng setup will run in "/etc/profile.d/set-newuser-permissions.sh" after user login.