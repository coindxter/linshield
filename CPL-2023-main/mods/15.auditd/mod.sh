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
}

# Define RC variable (update this to your directory containing audit configuration files)
RC="$(pwd)"

# Check if required files exist
if [[ ! -f "$RC/auditd.conf" ]] || [[ ! -f "$RC/audit.rules" ]]; then
    perror "Missing audit configuration files in $RC"
    exit 1
fi

# Copy configuration files
instconf "$RC/auditd.conf" "/etc/audit/auditd.conf"
instconf "$RC/audit.rules" "/etc/audit/rules.d/audit.rules"

# Validate and load audit rules
if augenrules --load; then
    echo "[INFO] Audit rules loaded successfully."
else
    perror "Failed to load audit rules. Check /etc/audit/rules.d/audit.rules for syntax errors."
    exit 1
fi

# Reload the auditd service
if systemctl reload auditd; then
    psuccess "Audit daemon reloaded successfully."
else
    perror "Failed to reload audit daemon."
    exit 1
fi

psuccess "Audit daemon configured."
