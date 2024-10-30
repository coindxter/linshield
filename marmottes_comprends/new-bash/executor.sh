#!/bin/bash

mkdir -p /home/$(logname)/cyberpatriots-scripts/

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/build_configs -O "/home/$(logname)/cyberpatriots-scripts/build-configs"
chmod +x "/home/$(logname)/cyberpatriots-scripts/build-configs"

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/audit -O "/home/$(logname)/cyberpatriots-scripts/audit"
chmod +x "/home/$(logname)/cyberpatriots-scripts/audit"

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/apt -O "/home/$(logname)/cyberpatriots-scripts/apt"
chmod +x "/home/$(logname)/cyberpatriots-scripts/apt"

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/group-audit -O "/home/$(logname)/cyberpatriots-scripts/group-audit"
chmod +x "/home/$(logname)/cyberpatriots-scripts/group-audit"

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/bash/apt.sh -O "/home/$(logname)/cyberpatriots-scripts/apt.sh"
chmod +x "/home/$(logname)/cyberpatriots-scripts/apt.sh"

wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/bash/sysctl.sh -O "/home/$(logname)/cyberpatriots-scripts/sysctl.sh"
chmod +x "/home/$(logname)/cyberpatriots-scripts/sysctl.sh"

cd "/home/$(logname)/cyberpatriots-scripts"