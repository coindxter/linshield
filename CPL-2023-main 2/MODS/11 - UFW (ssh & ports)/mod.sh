#!/usr/bin/env bash

# Set permissions for /lib/ufw
chmod 751 /lib/ufw

# Reset UFW rules
ufw --force reset

# Copy and apply ufw-sysctl.conf
instconf "$RC/ufw-sysctl.conf" "/etc/ufw/sysctl.conf"

# Enable UFW
ufw enable

# Set UFW logging level to high
ufw logging high

# Set default rules for incoming and outgoing traffic
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Deny specific services/ports
ufw deny telnet
ufw deny 2049
ufw deny 515
ufw deny 111

psuccess "Configured UFW"

# See also: 11 - Network Sec
