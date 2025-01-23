#!/usr/bin/env bash

# Helper function for error handling
perror() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Enable incoming HTTP traffic
echo "[INFO] Allowing HTTP traffic through UFW..."
ufw allow http || perror "Failed to allow HTTP traffic"

# Enable incoming HTTPS traffic
echo "[INFO] Allowing HTTPS traffic through UFW..."
ufw allow https || perror "Failed to allow HTTPS traffic"

# Change ownership of the /var/www/ directory and its contents
echo "[INFO] Changing ownership of /var/www/ to www-data:www-data..."
chown -R www-data:www-data /var/www || perror "Failed to change ownership of /var/www"

# Set permissions on directories within /var/www/ to 775
echo "[INFO] Setting permissions on directories in /var/www/ to 775..."
find /var/www -type d -exec chmod 775 {} \; || perror "Failed to set permissions on directories in /var/www"

echo "[SUCCESS] HTTP and HTTPS traffic enabled, and /var/www permissions configured."
