#!/usr/bin/env bash

# Copy configuration files
copy_config() {
    instconf "$RC/$1" "/etc/$1"
}

copy_config "interfaces"
copy_config "nsswitch.conf"
copy_config "host.conf"
copy_config "hosts"

# Append localhost entry to hosts file
echo "127.0.0.1 localhost $(hostname)" >> /etc/hosts

# Copy resolved.conf and remove resolved.conf.d directory
instconf "$RC/resolved.conf" "/etc/systemd/resolved.conf"
rm -rf "/etc/systemd/resolved.conf.d"

# Restart systemd-resolved
systemctl restart systemd-resolved && psuccess "systemd-resolved restarted" || perror "Failed to restart systemd-resolved"

# Remove rsh artifacts from user home directories
rm -f /home/*/.{netrc,forward,rhosts}
psuccess "Removed rsh artifacts"

# See also: 11 - UFW