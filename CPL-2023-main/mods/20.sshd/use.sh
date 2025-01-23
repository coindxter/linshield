#!/usr/bin/env bash

# Define helper functions
instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

psuccess() {
    echo "[SUCCESS] $1"
}

perror() {
    echo "[ERROR] $1" >&2
    exit 1
}

pinfo() {
    echo "[INFO] $1"
}

backup() {
    local file="$1"
    local backup_file="${file}.bak"
    cp "$file" "$backup_file" && pinfo "Backup created: $backup_file" || perror "Failed to create backup for $file"
}

# Define RC and BACKUP variables
RC="$(pwd)"
BACKUP="/var/backups"

# Ensure the sshd_config file exists in RC
if [[ ! -f "$RC/sshd_config" ]]; then
    perror "Configuration file not found: $RC/sshd_config"
fi

# Install and configure sshd using the provided configuration file
pinfo "Configuring sshd..."
instconf "$RC/sshd_config" /etc/ssh/sshd_config

# Create a backup directory and move any existing sshd configuration files
pinfo "Backing up existing sshd configuration files..."
mkdir -p "$BACKUP/sshd" || perror "Failed to create backup directory"
if [[ -d /etc/ssh/sshd_config.d ]]; then
    mv /etc/ssh/sshd_config.d/*.conf "$BACKUP/sshd" 2>/dev/null || echo "[INFO] No additional configuration files to backup"
fi

# Set ownership and permissions for sshd configuration files
pinfo "Setting ownership and permissions for sshd configuration files..."
chown -R root:root /etc/ssh || perror "Failed to set ownership"
chmod 755 /etc/ssh || perror "Failed to set permissions on /etc/ssh"
chmod 644 /etc/ssh/* || perror "Failed to set permissions on ssh configuration files"

# Restart sshd service
pinfo "Restarting sshd service..."
if systemctl restart sshd; then
    psuccess "Restarted sshd service"
else
    perror "Could not restart sshd service"
fi

# Remove short moduli from moduli file if it exists
if [[ -f /etc/ssh/moduli ]]; then
    pinfo "Removing short moduli entries..."
    backup /etc/ssh/moduli
    awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp > /dev/null
    mv /etc/ssh/moduli.tmp /etc/ssh/moduli || perror "Failed to update /etc/ssh/moduli"
    psuccess "Updated /etc/ssh/moduli"
else
    echo "[INFO] /etc/ssh/moduli does not exist, skipping"
fi
