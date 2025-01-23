#!/usr/bin/env bash

# Define helper functions
psuccess() {
    echo "[SUCCESS] $1"
}

perror() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Disable guest access in Samba by modifying the smb.conf file
echo "[INFO] Disabling guest access in Samba configuration..."
if [[ -f /etc/samba/smb.conf ]]; then
    sed -i 's/^.*guest ok.*$/    guest ok = no/' /etc/samba/smb.conf
    sed -i 's/^.*usershare allow guests.*$/usershare allow guests = no/' /etc/samba/smb.conf
    psuccess "Guest access disabled in Samba configuration"
else
    perror "Samba configuration file not found: /etc/samba/smb.conf"
fi

# Check if AppArmor is in use and configure its profile for Samba
if command -v apparmor_status &>/dev/null && apparmor_status | grep -q "enabled"; then
    echo "[INFO] Configuring AppArmor profile for Samba..."
    RC="$(pwd)"  # Define RC to the current directory
    if [[ -f "$RC/usr.sbin.smbd" ]]; then
        cp "$RC/usr.sbin.smbd" /etc/apparmor.d/usr.sbin.smbd || perror "Failed to copy AppArmor profile"
        aa-enforce /usr/sbin/smbd || perror "Failed to enforce AppArmor profile"
        apparmor_parser -r /etc/apparmor.d/usr.sbin.smbd || perror "Failed to reload AppArmor profile"
        psuccess "AppArmor profile configured and enforced for Samba"
    else
        echo "[WARN] AppArmor profile file not found: $RC/usr.sbin.smbd"
    fi
else
    echo "[INFO] AppArmor is not enabled or not installed. Skipping AppArmor configuration."
fi

# Restart the Samba services (smbd and nmbd)
echo "[INFO] Restarting Samba services..."
if systemctl restart smbd.service nmbd.service; then
    psuccess "Samba services restarted successfully"
else
    perror "Failed to restart Samba services"
fi
