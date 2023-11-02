#!/usr/bin/env bash

# Configuration files installation
instconf $RC/apache2.conf /etc/apache2/apache2.conf
instconf $RC/envvars /etc/apache2/envvars
instconf $RC/security.conf /etc/apache2/conf-available/security.conf
instconf $RC/modsecurity.conf /etc/modsecurity/modsecurity.conf
instconf $RC/crs-setup.conf /usr/share/modsecurity-crs/crs-setup.conf
instconf $RC/security2.conf /etc/apache2/mods-available/security2.conf

# Log file setup
mkdir -p /opt/modsecurity/var/log/
touch /opt/modsecurity/var/log/debug.log
chown www-data:root /opt/modsecurity/var/log/debug.log

# Apache2 directory permissions
chown -R root:root /etc/apache2
chmod 755 /etc/apache2
chmod -R 750 /etc/apache2/bin
chmod -R 750 /etc/apache2/conf

# Web root directory permissions
chown -R www-data:www-data /var/www/
find /var/www -type d -exec chmod 775 {} \;

# Apache2 configuration changes
a2enconf security
a2dissite 000-default
a2enmod rewrite security2 evasive headers unique_id
a2dismod -f include imap info userdir autoindex dav dav_fs

# ModSecurity setup
mkdir -p /var/cache/modsecurity/uploads
chmod -R 750 /var/cache/modsecurity

# Firewall rules
ufw allow http
ufw allow https

# Reload Apache2
systemctl reload apache2 && psuccess "Reloaded Apache2" || perror "Failed to reload Apache2"

# TODO: Check enabled modules, sites, configs, and web root files
ptodo "Check enabled modules"
ptodo "Check enabled sites"
ptodo "Check enabled configs"
ptodo "Inspect web root files"

# Check and patch/upgrade apache-log4j2 if installed
if dpkg -s apache-log4j2 &>/dev/null; then
    ptodo "Patch / upgrade apache-log4j2"
fi

psuccess "Configured Apache2"
