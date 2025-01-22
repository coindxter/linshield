#!/usr/bin/env bash

# Define helper functions
instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

psuccess() {
    echo "[SUCCESS] $1"
}

ptodo() {
    echo "[TODO] $1"
}

perror() {
    echo "[ERROR] $1" >&2
}

# Define RC variable (path to configuration files)
RC="$(pwd)/rc"

# Check if required files exist
required_files=(
    "$RC/apache2.conf" "$RC/envvars" "$RC/security.conf"
    "$RC/modsecurity.conf" "$RC/crs-setup.conf" "$RC/security2.conf"
)
for file in "${required_files[@]}"; do
    if [[ ! -f $file ]]; then
        perror "Missing required configuration file: $file"
        exit 1
    fi
done

# Install configuration files
instconf "$RC/apache2.conf" /etc/apache2/apache2.conf
instconf "$RC/envvars" /etc/apache2/envvars
instconf "$RC/security.conf" /etc/apache2/conf-available/security.conf
instconf "$RC/modsecurity.conf" /etc/modsecurity/modsecurity.conf
instconf "$RC/crs-setup.conf" /usr/share/modsecurity-crs/crs-setup.conf
instconf "$RC/security2.conf" /etc/apache2/mods-available/security2.conf

# Set up log files for ModSecurity
mkdir -p /opt/modsecurity/var/log/
touch /opt/modsecurity/var/log/debug.log
chown www-data:root /opt/modsecurity/var/log/debug.log

# Apache2 directory permissions
chown -R root:root /etc/apache2
chmod 755 /etc/apache2
find /etc/apache2/bin /etc/apache2/conf -type d -exec chmod 750 {} \;

# Web root directory permissions
chown -R www-data:www-data /var/www/
find /var/www -type d -exec chmod 775 {} \;

# Enable and disable Apache2 modules/sites
echo "[INFO] Configuring Apache2 modules and sites..."
a2enconf security || perror "Failed to enable 'security' configuration"
a2dissite 000-default || perror "Failed to disable '000-default' site"
a2enmod rewrite security2 evasive headers unique_id || perror "Failed to enable required modules"
a2dismod -f include imap info userdir autoindex dav dav_fs || perror "Failed to disable unnecessary modules"

# Set up ModSecurity cache
mkdir -p /var/cache/modsecurity/uploads
chmod -R 750 /var/cache/modsecurity

# Allow HTTP and HTTPS through UFW
echo "[INFO] Configuring firewall rules..."
ufw allow http || perror "Failed to allow HTTP through UFW"
ufw allow https || perror "Failed to allow HTTPS through UFW"

# Reload Apache2
echo "[INFO] Reloading Apache2..."
if systemctl reload apache2; then
    psuccess "Reloaded Apache2"
else
    perror "Failed to reload Apache2"
    exit 1
fi

# Check and upgrade Log4j if installed
if dpkg -s apache-log4j2 &>/dev/null; then
    ptodo "Patch or upgrade apache-log4j2"
fi

# TODO: Final checks
ptodo "Check enabled modules"
ptodo "Check enabled sites"
ptodo "Check enabled configs"
ptodo "Inspect web root files"

psuccess "Apache2 configuration completed successfully."
