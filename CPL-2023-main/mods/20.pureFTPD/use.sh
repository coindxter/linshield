#!/usr/bin/env bash

# Define helper functions
instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

psuccess() {
    echo "[SUCCESS] $1"
}

pinfo() {
    echo "[INFO] $1"
}

perror() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Define RC (configuration directory)
RC="$(pwd)"

# Allow FTP and FTPS connections through UFW firewall
pinfo "Allowing FTP and FTPS traffic through UFW..."
ufw allow ftp || perror "Failed to allow FTP traffic"
ufw allow ftps || perror "Failed to allow FTPS traffic"

# Install and configure Pure-FTPd using the provided configuration file
pinfo "Configuring Pure-FTPd..."
if [[ -f "$RC/pure-ftpd.conf" ]]; then
    instconf "$RC/pure-ftpd.conf" /etc/pure-ftpd/pure-ftpd.conf
else
    perror "Configuration file not found: $RC/pure-ftpd.conf"
fi

# Create a directory for Pure-FTPd transfer logs
pinfo "Setting up transfer logs..."
mkdir -p /var/log/pure-ftpd/
touch /var/log/pure-ftpd/transfer.log || perror "Failed to create transfer log file"

# Remove existing configuration directory and create a new one
pinfo "Resetting Pure-FTPd configuration directory..."
rm -rf /etc/pure-ftpd/conf || perror "Failed to remove existing configuration directory"
mkdir -p /etc/pure-ftpd/conf || perror "Failed to create configuration directory"

# Configure Pure-FTPd options using the echo command
pinfo "Configuring Pure-FTPd options..."
echo "2" > /etc/pure-ftpd/conf/TLS
echo "yes" > /etc/pure-ftpd/conf/NoAnonymous
echo "no" > /etc/pure-ftpd/conf/AnonymousOnly
echo "no" > /etc/pure-ftpd/conf/UnixAuthentication
echo "yes" > /etc/pure-ftpd/conf/PAMAuthentication
echo "no" > /etc/pure-ftpd/conf/ChrootEveryone
echo "HIGH" > /etc/pure-ftpd/conf/TLSCipherSuite
echo "/etc/pure-ftpd/pureftpd.pdb" > /etc/pure-ftpd/conf/PureDB
echo "clf:/var/log/pure-ftpd/transfer.log" > /etc/pure-ftpd/conf/AltLog
echo "UTF-8" > /etc/pure-ftpd/conf/FSCharset
echo "1000" > /etc/pure-ftpd/conf/MinUID
psuccess "Configured Pure-FTPd options"

# Generate TLS certificate and key if they don't already exist
if [[ ! -f /etc/ssl/private/pure-ftpd.pem ]]; then
    pinfo "Generating TLS certificate and key..."
    mkdir -p /etc/ssl/private || perror "Failed to create private directory"
    openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048 || perror "Failed to generate DH parameters"
    openssl req -x509 -nodes -days 7300 -newkey rsa:2048 \
        -keyout /etc/ssl/private/pure-ftpd.pem \
        -out /etc/ssl/private/pure-ftpd.pem \
        -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com" ||
        perror "Failed to generate TLS certificate"
    psuccess "Generated TLS certificate and key"
fi

# Set appropriate permissions for the TLS certificate and key
pinfo "Setting permissions for TLS files..."
chmod 700 /etc/ssl/private/ || perror "Failed to set permissions on /etc/ssl/private/"
chmod 600 /etc/ssl/private/*.pem || perror "Failed to set permissions on TLS files"

# Restart Pure-FTPd service
pinfo "Restarting Pure-FTPd service..."
if systemctl restart pure-ftpd; then
    psuccess "Restarted Pure-FTPd service"
else
    perror "Failed to restart Pure-FTPd service"
fi
