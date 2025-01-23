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

# Define RC (configuration directory) and BACKUP paths
RC="$(pwd)"
BACKUP="/var/backups"

# Allow FTP and FTPS connections through UFW firewall
echo "[INFO] Allowing FTP and FTPS traffic..."
ufw allow ftp || perror "Failed to allow FTP traffic"
ufw allow ftps || perror "Failed to allow FTPS traffic"

# Create a directory for ProFTPD logs and set up a TLS log file
echo "[INFO] Setting up ProFTPD log directory and files..."
mkdir -p /var/log/proftpd/
touch /var/log/proftpd/tls.log
chown proftpd:root /var/log/proftpd/tls.log
psuccess "Created ProFTPD log file"

# Install and configure ProFTPD using the provided configuration file
echo "[INFO] Configuring ProFTPD..."
if [[ ! -f "$RC/proftpd.conf" ]]; then
    perror "Configuration file not found: $RC/proftpd.conf"
fi
instconf "$RC/proftpd.conf" /etc/proftpd/proftpd.conf

# Backup existing ProFTPD configuration files
echo "[INFO] Backing up existing ProFTPD configuration files..."
mkdir -p "$BACKUP/proftpd"
if [[ -d /etc/proftpd/conf.d ]]; then
    mv /etc/proftpd/conf.d/* "$BACKUP/proftpd" || echo "[WARN] No configuration files to move"
else
    echo "[WARN] /etc/proftpd/conf.d does not exist"
fi
psuccess "Configured ProFTPD"

# Install and configure TLS for ProFTPD
echo "[INFO] Configuring TLS for ProFTPD..."
if [[ ! -f "$RC/tls.conf" ]]; then
    perror "TLS configuration file not found: $RC/tls.conf"
fi
instconf "$RC/tls.conf" /etc/proftpd/tls.conf

# Generate a self-signed SSL/TLS certificate if it doesn't already exist
if [[ ! -f /etc/ssl/private/proftpd.key ]]; then
    echo "[INFO] Generating self-signed SSL/TLS certificate..."
    mkdir -p /etc/ssl/private
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/proftpd.key \
        -out /etc/ssl/certs/proftpd.crt \
        -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com" ||
        perror "Failed to generate SSL/TLS certificate"
fi

# Set appropriate permissions for the SSL/TLS certificate files
echo "[INFO] Setting permissions for SSL/TLS certificate files..."
chmod 700 /etc/ssl/{private,certs}
chmod 600 /etc/ssl/private/proftpd.key
chmod 600 /etc/ssl/certs/proftpd.crt
psuccess "Configured ProFTPD TLS"

# Restart ProFTPD service
echo "[INFO] Restarting ProFTPD service..."
systemctl restart proftpd && psuccess "Restarted ProFTPD" || perror "Failed to restart ProFTPD"
