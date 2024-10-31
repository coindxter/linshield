#!/usr/bin/env bash

# Copy the jail.local configuration file from the specified location to /etc/fail2ban/jail.local
instconf $RC/jail.local /etc/fail2ban/jail.local

# Restart the fail2ban service using 'systemctl' if available, or fall back to 'service' if not.
systemctl restart fail2ban || service fail2ban restart || perror "Failed to restart fail2ban"

psuccess "Configured fail2ban"
