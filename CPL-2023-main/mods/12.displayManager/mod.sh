#!/usr/bin/env bash

# Define instconf function
instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

# Define psuccess function
psuccess() {
    echo "[SUCCESS] $1"
}


#file locs

RC="$(pwd)/"
DATA="$(pwd)/data"

# Check if lightdm is the default display manager
if grep -q lightdm /etc/X11/default-display-manager; then
    # Copy lightdm.conf
    instconf "$RC/lightdm.conf" "/etc/lightdm/lightdm.conf"
    psuccess "Inspect /etc/lightdm"
fi

# Check if gdm3 is the default display manager
if grep -q gdm3 /etc/X11/default-display-manager; then
    # Copy greeter.dconf-defaults and custom.conf
    instconf "$RC/greeter.dconf-defaults" "/etc/gdm3/greeter.dconf-defaults"
    instconf "$RC/custom.conf" "/etc/gdm3/custom.conf"

    # Update autologin user in custom.conf
    sed -i "s/AUTOLOGIN_USER/$(cat "$DATA/autologin_user" | xargs)/" /etc/gdm3/custom.conf

    psuccess "Inspect /etc/gdm3"
fi

