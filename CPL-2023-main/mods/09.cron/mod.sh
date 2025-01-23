#!/usr/bin/env bash

# Define logging functions
psuccess() { echo "[SUCCESS] $1"; }
perror() { echo "[ERROR] $1" >&2; }
ptodo() { echo "[TODO] $1"; }

# Backup existing cron files
BACKUP=${BACKUP:-"/backup"}
mkdir -p "$BACKUP/quarantine"
cp -ar /var/spool/cron/ "$BACKUP/quarantine" 2>/dev/null || pwarn "No cron files to backup"

# Remove all user crontabs
if [[ -d /var/spool/cron/crontabs ]]; then
    rm /var/spool/cron/crontabs/* || perror "Failed to remove user crontabs"
else
    pwarn "/var/spool/cron/crontabs does not exist or is already empty"
fi

# Only allow root to use cron and at
echo "root" > /etc/cron.allow
echo "root" > /etc/at.allow
chmod 644 /etc/{cron,at}.allow

# Restart cron daemon
if systemctl restart cron; then
    psuccess "Restarted cron daemon"
else
    perror "Failed to restart cron daemon"
fi

# Print to-do messages for inspection
ptodo "Inspect original crontabs in $BACKUP/quarantine"
ptodo "Inspect /var/spool/anacron /etc/crontab /etc/anacrontab /etc/cron.* etc"

psuccess "Configured cron"
