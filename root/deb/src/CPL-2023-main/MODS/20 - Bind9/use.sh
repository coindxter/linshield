#!/usr/bin/env bash

# Update the BIND version configuration
sed -i 's/^.*version\s+".*";.*/version none;/' /etc/bind/named.conf.options

# Disable zone transfers
sed -i 's/^.*allow-transfer.*;.*/allow-transfer {none;};/' /etc/bind/named.conf.options

# Restrict permissions on the BIND configuration files
chmod -R o-rwx /etc/bind
