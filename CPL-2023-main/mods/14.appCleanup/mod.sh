#!/usr/bin/env bash

# Helper functions
disnow() {
    systemctl stop "$1" 2>/dev/null && systemctl disable "$1" && echo "[INFO] Disabled $1" || echo "[WARN] Could not disable $1"
}

pwarn() {
    echo "[WARNING] $1"
}

perror() {
    echo "[ERROR] $1" >&2
}

# Disable services
services=("nfs-server" "rpcbind" "dovecot" "squid" "nis" "snmpd" "rsync" "postfix")
for service in "${services[@]}"; do
    disnow "$service"
done

# Disable postfix using 'update-rc.d'
if command -v update-rc.d &>/dev/null; then
    update-rc.d postfix disable && echo "[INFO] Disabled postfix via update-rc.d"
else
    pwarn "update-rc.d not found; postfix may not be disabled"
fi

# Prelink cleanup (skip if prelink is not installed)
if command -v prelink &>/dev/null; then
    prelink -ua && echo "[INFO] Prelink cleanup completed"
else
    pwarn "Prelink is not installed; skipping"
fi

# List of banned hacking tools and unnecessary packages
banned=(
    "hydra" "nmap" "zenmap" "john" "medusa" "vino" "ophcrack" "aircrack-ng" "fcrackzip" "nikto"
    "iodine" "kismet" "packit" "pcmpem" "goldeneye" "themole" "empathy" "prelink" "minetest"
    "snmp" "nfs-kernel-server" "rsh-client" "talk" "squid" "nis" "portmap" "ldap-utils" "slapd"
    "tightvncserver" "inspircd" "ircd-hybrid" "ircd-irc2" "ircd-ircu" "ngircd" "tircd" "znc"
    "sqwebmail" "cyrus-imapd" "dovecot-imapd"
)

# Check if packages are installed and remove them
for package in "${banned[@]}"; do
    if dpkg -l | grep -qw "$package"; then
        echo "[INFO] $package is installed; removing..."
        apt-get remove -y "$package" && echo "[INFO] Removed $package" || perror "Failed to remove $package"
    else
        echo "[INFO] $package is not installed"
    fi
done

echo "[SUCCESS] Removal of banned packages completed"
