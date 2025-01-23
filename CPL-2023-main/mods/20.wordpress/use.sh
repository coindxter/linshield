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

# Define RC variable (update to the directory containing the configuration file)
RC="$(pwd)"

# Ensure the WordPress Apache configuration file exists
if [[ ! -f "$RC/wordpress.conf" ]]; then
    perror "Configuration file not found: $RC/wordpress.conf"
fi

# Install and configure the WordPress virtual host using the provided configuration file
pinfo "Configuring WordPress virtual host..."
instconf "$RC/wordpress.conf" /etc/apache2/sites-available/wordpress.conf

# Enable the WordPress virtual host in Apache
pinfo "Enabling WordPress site..."
if a2ensite wordpress; then
    psuccess "Enabled WordPress site"
else
    perror "Failed to enable WordPress site"
fi

# Create a separate directory for WordPress within the HTML root
pinfo "Creating WordPress directory in HTML root..."
mkdir -p /var/www/html
if [[ -d /usr/share/wordpress ]]; then
    ln -sf /usr/share/wordpress /var/www/html/wordpress || perror "Failed to create symbolic link for WordPress"
    psuccess "Symbolic link created for WordPress"
else
    perror "WordPress directory not found: /usr/share/wordpress"
fi

# Set ownership of the WordPress files to the Apache user (www-data)
pinfo "Setting ownership of WordPress files..."
chown -R www-data:www-data /usr/share/wordpress || perror "Failed to set ownership of WordPress files"

# Set appropriate permissions for directories within the WordPress installation
pinfo "Setting permissions for WordPress directories..."
find /usr/share/wordpress -type d -exec chmod 775 {} \; || perror "Failed to set permissions for WordPress directories"

# Restart Apache to apply changes
pinfo "Restarting Apache service..."
if systemctl restart apache2; then
    psuccess "Apache restarted successfully"
else
    perror "Failed to restart Apache"
fi
