#!/usr/bin/env bash

#Essentially runs an integrity checker everyday at 5 AM
aideinit
crontab -l | { cat; echo "0 5 * * * /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"; } | crontab -

