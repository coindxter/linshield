#!/bin/bash

# Determine OS number and version
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)

# Create backups directory if not present
[ ! -d "../backups" ] && mkdir -p "../backups"

# Update the package list if Ubuntu and supported version
if [[ "$OS_NAME" == "Ubuntu" ]]; then
    if [[ -s "../support-files/apt_sources/$OS_VERSION" ]]; then
        sudo cp /etc/apt/sources.list ../backups/sources.list.$(date +%Y-%m-%d)
        sudo cat "../support-files/apt_sources/$OS_VERSION" > /etc/apt/sources.list
    else
        echo "$OS_NAME is supported but $OS_VERSION is not supported"
    fi
else
    echo "OS $OS_NAME not supported"
fi

# List and potentially remove files in /etc/apt/sources.list.d
if [[ -n "$(ls /etc/apt/sources.list.d 2>/dev/null)" ]]; then
    echo "The following files exist in /etc/apt/sources.list.d"
    for file in /etc/apt/sources.list.d/*; do
        echo -n "Do you want to remove $file? (y/n) " && read REMOVE_FILE
        if [[ "$REMOVE_FILE" == "y" ]]; then
            sudo cp -r "$file" "../backups/sources.list.d.$(date +%Y-%m-%d)"
            sudo rm -r "$file"
        else
            echo "Skipping $file"
        fi
    done
fi

# Update the package list
sudo apt-get update

# Upgrade APT package itself
sudo apt-get install --only-upgrade apt

# Install security tools
sudo apt-get install -y apparmor apparmor-utils apparmor-profiles fail2ban libpam-pwquality unattended-upgrades
