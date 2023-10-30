#!/usr/bin/env bash

# Backup existing cron files
cp -ar /var/spool/cron/ "$BACKUP/quarantine"

# Remove all user crontabs
rm /var/spool/cron/crontabs/*

# Only allow root to use cron and at
echo "root" > /etc/cron.allow
echo "root" > /etc/at.allow
chmod 644 /etc/{cron,at}.allow

# Restart cron daemon
systemctl restart cron && psuccess "Restarted cron daemon" || perror "Failed to restart cron daemon"

# Print to-do messages for inspection
ptodo "Inspect original crontabs"
ptodo "Inspect /var/spool/anacron /etc/crontab /etc/anacrontab /etc/cron.* etc"

psuccess "Configured cron"
