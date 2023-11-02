#!/usr/bin/env bash

# Enable incoming HTTP traffic using 'ufw' firewall
ufw enable http

# Enable incoming HTTPS traffic using 'ufw' firewall
ufw enable https

# Change ownership of the /var/www/ directory and its contents to the 'www-data' user and group
chown -R www-data:www-data /var/www/

# Set permissions on directories within /var/www/ to 775 (owner: read, write, execute; group: read, execute; others: read, execute)
find /var/www -type d -exec chmod 775 {} \;
