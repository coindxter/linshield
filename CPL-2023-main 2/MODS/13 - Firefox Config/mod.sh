#!/usr/bin/env bash

# Copy user.js to all Firefox profiles in /home
for home in /home/*/; do
    user=$(basename "$home")
    for profile in "$home"/.mozilla/firefox/*.*/; do
        install -o "$user" -g "$user" -Dm660 "$RC/user.js" "$profile/user.js"
    done
done

# Determine the operating system
if [[ $OS = d* ]]; then
    # Copy debian_locked.js and restart Firefox-esr
    instconf "$RC/debian_locked.js" "/etc/firefox-esr/firefox-esr.js"
    killall firefox-esr
else
    # Copy locked_user.js to older and newer Firefox configurations, then restart Firefox
    instconf "$RC/locked_user.js" "/etc/firefox/syspref.js" # older
    instconf "$RC/locked_user.js" "/etc/firefox/firefox.js" # newer
    killall firefox
fi

ptodo "Restart Firefox"
psuccess "Configured all Firefox profiles"
