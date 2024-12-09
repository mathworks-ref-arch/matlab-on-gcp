#!/usr/bin/env bash

# Setup logging
LOG_FILE="/var/log/mathworks/set-${USER}-permission.log"
# Check if the log file exists and is owned by the user
if [ ! -f "$LOG_FILE" ] || [ "$(stat -c '%U' "$LOG_FILE")" != "$USER" ]; then
    sudo touch "$LOG_FILE"
    sudo chown "$USER":"$USER" "$LOG_FILE"
fi

# Start of subshell for logging
(
    exec > >(tee -a "$LOG_FILE") 2>&1

    MATLAB_ROOT=/usr/local/matlab
    echo "Started setting the user permissions at $(date)"

    # Check and copy the desktop icon if it doesn't exist for the user
    DESKTOP_ICON_PATH="/home/${USER}/Desktop/matlab.desktop"
    if [ ! -f "$DESKTOP_ICON_PATH" ]; then
        echo "Copying the MATLAB desktop icon to ${DESKTOP_ICON_PATH}"
        sudo cp -r /etc/skel/. /home/${USER}/
        sudo chown -R ${USER}:${USER} /home/${USER}/
    else
        echo "MATLAB desktop icon already exists at ${DESKTOP_ICON_PATH}"
    fi
    
    # Ensure the user is in their own-named group
    if ! getent group $USER > /dev/null || ! groups $USER | grep -q "\b$USER\b"; then
        echo "Ensuring group $USER exists and $USER is a member..."
        sudo groupadd $USER 2>/dev/null
        sudo usermod -aG $USER $USER
    else
        echo "Group $USER already exists and $USER is a member."
    fi

    # Check and change ownership of the MATLAB directory to the user
    current_owner=$(stat -c '%U' "$MATLAB_ROOT")
    current_group=$(stat -c '%G' "$MATLAB_ROOT")
    if [ "$current_owner" != "$USER" ] || [ "$current_group" != "$USER" ]; then
        echo "Please wait, updating ownership of $MATLAB_ROOT to ${USER}:${USER} ..."
        sudo chown -R ${USER}:${USER} "$MATLAB_ROOT" &
    else
        echo "Ownership of $MATLAB_ROOT already set to ${USER}:${USER}"
    fi

    # Check and change permissions of the MATLAB directory
    current_perms=$(stat -c '%a' "$MATLAB_ROOT")
    desired_perms="755"
    alternate_perms="2755"

    if [ "$current_perms" != "$desired_perms" ] && [ "$current_perms" != "$alternate_perms" ]; then
        echo "Please wait, updating permissions of $MATLAB_ROOT to $desired_perms ..."
        sudo chmod -R 755 "$MATLAB_ROOT"
    else
        echo "Permissions of $MATLAB_ROOT already set to $desired_perms"
    fi

    # Setup MATLAB licensing in non-login shells
    MLM_DEF_FILE=/etc/profile.d/mlm_def.sh
    BASHRC="/home/${USER}/.bashrc"
    MATLAB_LICENSING_ENTRY="# Setup MATLAB Licensing"

if ! grep -qxF "$MATLAB_LICENSING_ENTRY" "$BASHRC"; then
    echo "Appending MATLAB licensing setup to $BASHRC"
    cat >> "$BASHRC" << EOF
$MATLAB_LICENSING_ENTRY
. ${MLM_DEF_FILE}
EOF
else
    echo "MATLAB licensing setup already exists in $BASHRC"
fi
) # End of subshell

echo "Completed setting the user permissions at $(date)"

echo "Info: Before using RDP, you must either set the password for the current user or create a new user with password."