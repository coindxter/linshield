#!/bin/bash

mkdir -p /home/$(logname)/cyberpatriots-scripts/confs/
mkdir -p /home/$(logname)/cyberpatriots-scripts/backups/

DISTRO=$(lsb_release -i | cut -d ":" -f2 | xargs)

if [ "$DISTRO" == "LinuxMint" ]; then
    echo "Mint detected"
    wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/apt-baselines/mint -O "/home/$(logname)/cyberpatriots-scripts/confs/mint"
    tar -xzf /home/$(logname)/cyberpatriots-scripts/confs/mint -C /home/$(logname)/cyberpatriots-scripts/confs/
elif [ "$DISTRO" == "Ubuntu" ]; then
    echo "Ubuntu detected"
    wget https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/apt-baselines/ubuntu -O "/home/$(logname)/cyberpatriots-scripts/confs/ubuntu"
    tar -xzf /home/$(logname)/cyberpatriots-scripts/confs/ubuntu -C /home/$(logname)/cyberpatriots-scripts/confs/
else
    echo "Unsupported distribution: $DISTRO"
    exit 1
fi

tar -czf /home/$(logname)/cyberpatriots-scripts/backups/apt-back.gz /etc/apt/
echo "Backup of /etc/apt/ created at apt-back.gz"

rm -r /etc/apt/
cp -r /home/$(logname)/cyberpatriots-scripts/confs/etc/apt/ /etc/apt
echo "New /etc/apt/ created"

echo "Updating package lists..."
apt update