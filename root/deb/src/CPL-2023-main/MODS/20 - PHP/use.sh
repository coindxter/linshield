#!/usr/bin/env bash

# Get the list of PHP versions installed in /etc/php/
php_vers=(/etc/php/*)

# Copy the php.ini configuration file from the specified location ($RC/php.ini) to the latest PHP version's php.ini file for Apache
instconf $RC/php.ini ${php_vers[-1]}/apache2/php.ini

# ===== PHP =====

# Change ownership of the /etc/php/ directory and its contents to the root user and group
chown -R root:root /etc/php

# Set permissions on the /etc/php/ directory to 755 (owner: read, write, execute; group: read, execute; others: read, execute)
chmod 755 /etc/php
