#!/usr/bin/env bash

# Set the directory path
dir="/etc/apt/apt.conf.d"

# Create the directory if it doesn't exist, it should tho
mkdir -p "$dir" || pinfo "directory already exists"

# Copy configuration files
instconf "$RC/10periodic" "$dir/10periodic"
instconf "$RC/50unattended-upgrades" "$dir/50unattended-upgrades"
instconf "$RC/50unattended-upgrades" "$dir/20auto-upgrades"

psuccess "APT Unattended Upgrades configured"
