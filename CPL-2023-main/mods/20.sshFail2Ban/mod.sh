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

# Define RC variable (update this to your configuration directory)
RC="$(pwd)"

# Ensure the jail.local configuration file exists in RC
if [[ ! -f "$RC/jail.local" ]]; then
    perror "Configuration file not found: $RC/jail.local"
fi

# Copy the jail.local configuration file to /etc/fail2ban/jail.local
echo "[INFO] Configuring fail2ban..."
instconf "$RC/jail.local" /etc/fail2ban/jail.local

# Restart the fail2ban service
echo "[INFO] Restarting fail2ban service..."
if command -v systemctl &>/dev/null; then
    systemctl restart fail2ban || perror "Failed to restart fail2ban using systemctl"
elif command -v service &>/dev/null; then
    service fail2ban restart || perror "Failed to restart fail2ban using service"
else
    perror "Service management command not found (systemctl or service)"
fi

psuccess "Configured and restarted fail2ban successfully"
