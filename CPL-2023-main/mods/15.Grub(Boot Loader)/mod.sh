#!/usr/bin/env bash

# Define helper functions
pinfo() {
    echo "[INFO] $1"
}

psuccess() {
    echo "[SUCCESS] $1"
}

perror() {
    echo "[ERROR] $1" >&2
}

# Define RC variable (update this to your directory containing 40_custom)
RC="$(pwd)"

# Check if the 40_custom file exists
if [[ ! -f "$RC/40_custom" ]]; then
    perror "40_custom file not found in $RC"
    exit 1
fi

pinfo "Setting grub password (password is 'password')"
install -o root -g root -Dm750 $RC/40_custom /etc/grub.d/40_custom

# sed -i 's/^CLASS="--class gnu-linux --class gnu --class os"$/CLASS="--class gnu-linux --class gnu --class os --unrestricted"/' /etc/grub>

pinfo "Updating grub"
update-grub

psuccess "Grub updated and bootloader password applied"
