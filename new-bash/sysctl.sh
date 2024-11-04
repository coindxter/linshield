#!/bin/bash

# Download files
wget -O "/home/$(logname)/cyberpatriots-scripts/confs/sysctl.conf" "https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/configs/sysctl.conf"
wget -O "/home/$(logname)/cyberpatriots-scripts/confs/access.conf" "https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/configs/access.conf" 
wget -O "/home/$(logname)/cyberpatriots-scripts/confs/limits.conf" "https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/configs/limits.conf"

# Set permissions
chmod 644 /home/$(logname)/cyberpatriots-scripts/confs/sysctl.conf
chmod 644 /home/$(logname)/cyberpatriots-scripts/confs/access.conf
chmod 644 /home/$(logname)/cyberpatriots-scripts/confs/limits.conf 

# Overwrite with downloaded files 
cp /home/$(logname)/cyberpatriots-scripts/confs/sysctl.conf /etc/sysctl.conf
cp /home/$(logname)/cyberpatriots-scripts/confs/access.conf /etc/security/access.conf
cp /home/$(logname)/cyberpatriots-scripts/confs/limits.conf /etc/security/limits.conf

# Apply sysctl changes
sysctl -p /etc/sysctl.conf