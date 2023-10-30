#!/usr/bin/env bash

# Install and configure the WordPress virtual host using the provided configuration file
instconf $RC/wordpress.conf /etc/apache2/sites-available/wordpress.conf

# Enable the WordPress virtual host in Apache
a2ensite wordpress

# Create a separate directory for WordPress within the HTML root
mkdir -p /var/www/html
ln -s /usr/share/wordpress /var/www/html/wordpress

# Set ownership of the WordPress files to the Apache user (www-data)
chown -R www-data /usr/share/wordpress

# Set appropriate permissions for directories within the WordPress installation
find /usr/share/wordpress -type d -exec chmod 775 {} \;
