#!/usr/bin/env bash

# Define paths
RC="$(pwd)"  # Update this to the directory with configuration files
BACKUP="/var/backups"  # Update this to the backup directory

#bacakups

sudo cp /etc/security/access.conf /etc/security/access.conf.bak
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
sudo cp /etc/security/limits.conf /etc/security/limits.conf.bak

# Custom functions
instsecret() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

psuccess() {
    echo "[SUCCESS] $1"
}

perror() {
    echo "[ERROR] $1" >&2
}

pinfo() {
    echo "[INFO] $1"
}

# Load nf_conntrack_ftp module
echo 'nf_conntrack_ftp' >> /etc/modules

# Copy and apply sysctl.conf
instsecret "$RC/sysctl.conf" "/etc/sysctl.conf"
sysctl -e -p /etc/sysctl.conf

# Backup and replace sysctl.d files
mkdir -p "$BACKUP/sysctl"
mv /etc/sysctl.d/* "$BACKUP/sysctl" 2>/dev/null

# Copy limits.conf and access.conf
instconf "$RC/limits.conf" "/etc/security/limits.conf"
instconf "$RC/access.conf" "/etc/security/access.conf"

psuccess "Installed system security configurations"

# Remove ld.so.preload if it exists
if [[ -f /etc/ld.so.preload ]]; then
    rm /etc/ld.so.preload && psuccess "Removed system-wide LD_PRELOAD"
fi

# Secure RNG
echo "HRNGDEVICE=/dev/urandom" >> /etc/default/rng-tools
systemctl restart rng-tools && psuccess "RNG service setup successful" || perror "Failed to set up RNG service"

# Disable unnecessary protocols and kernel modules
pinfo "Disabling unnecessary protocols / kernel modules"
# List of modules to disable
mods=(uvcvideo freevxfs jffs2 hfs hfsplus udf cramfs vivid bluetooth btusb dccp sctp rds tipc n-hdlc ax25 netrom x25 rose decnet econet af>

# Disable and remove unnecessary modules
for mod in "${mods[@]}"; do
    echo "install $mod /bin/false" >> "/etc/modprobe.d/$mod.conf"
    if lsmod | grep -q "^$mod"; then
        rmmod "$mod" -v && psuccess "Removed module: $mod" || perror "Failed to remove module: $mod"
    else
        pinfo "Module $mod not loaded, skipping removal"
    fi
done

psuccess "Disabled unnecessary kernel modules"
