#!/usr/bin/env bash

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
