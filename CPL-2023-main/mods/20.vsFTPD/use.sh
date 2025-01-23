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

# Define RC (configuration directory)
RC="$(pwd)"

# Allow FTP and FTPS connections through UFW firewall
pinfo "Allowing FTP and FTPS traffic through UFW..."
ufw allow ftp || perror "Failed to allow FTP traffic"
ufw allow ftps || perror "Failed to allow FTPS traffic"

# Install and configure vsftpd using the provided configuration file
pinfo "Configuring vsftpd..."
if [[ -f "$RC/vsftpd.conf" ]]; then
    instconf "$RC/vsftpd.conf" /etc/vsftpd.conf
else
    perror "Configuration file not found: $RC/vsftpd.conf"
fi
psuccess "Configured vsftpd"

# Generate TLS certificate and key for vsftpd if they don't already exist
if [[ ! -f /etc/ssl/private/vsftpd.key ]]; then
    pinfo "Generating TLS certificate and key for vsftpd..."
    mkdir -p /etc/ssl/private || perror "Failed to create /etc/ssl/private directory"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/vsftpd.key \
        -out /etc/ssl/certs/vsftpd.crt \
        -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com" ||
        perror "Failed to generate TLS certificate and key"
fi

# Set appropriate permissions for the TLS certificate and key
pinfo "Setting permissions for TLS files..."
chmod 700 /etc/ssl/{private,certs} || perror "Failed to set permissions on /etc/ssl directories"
chmod 600 /etc/ssl/private/vsftpd.key || perror "Failed to set permissions on vsftpd.key"
chmod 600 /etc/ssl/certs/vsftpd.crt || perror "Failed to set permissions on vsftpd.crt"
psuccess "Configured vsftpd TLS"

# Restart vsftpd service
pinfo "Restarting vsftpd service..."
if systemctl restart vsftpd; then
    psuccess "Restarted vsftpd"
else
    perror "Failed to restart vsftpd"
fi
