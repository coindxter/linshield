#!/usr/bin/env bash

# Set root ownership and permissions for the root directory
chown root:root /
chmod 751 /

# Set ownership and permissions for /boot and /boot/grub
chown root:root /boot
chmod 700 /boot
chown -R root:root /boot/grub
chmod 600 /boot/grub/grub.cfg

# Set ownership and permissions for /tmp and /var/tmp
chown root:root /tmp
chmod 1777 /tmp
chown root:root /var/tmp
chmod 1777 /var/tmp

# Set ownership and permissions for /etc and subdirectories
chown root:root /etc
chmod -R o-w /etc
chown -R root:root /etc/default
chmod 755 /etc/default
chmod 644 /etc/default/*
chown -R root:root /etc/grub.d
chmod -R 755 /etc/grub.d/*_*
chown root:root /etc/resolv.conf
chmod 644 /etc/resolv.conf
chown root:root /etc/fstab
chmod 664 /etc/fstab
chown root:root /etc/passwd
chmod 644 /etc/passwd
chown root:root /etc/passwd-
chmod 644 /etc/passwd-
chown root:root /etc/group
chmod 644 /etc/group
chown root:root /etc/group-
chmod 644 /etc/group-
chown root:root /etc/shadow
chmod 600 /etc/shadow
chown root:root /etc/shadow-
chmod 600 /etc/shadow-
chown root:root /etc/gshadow
chmod 600 /etc/gshadow
chown root:root /etc/gshadow-
chmod 600 /etc/gshadow-
chown root:root /etc/opasswd 2>/dev/null
chmod 600 /etc/opasswd 2>/dev/null
chown root:root /etc/security/opasswd
chmod 600 /etc/security/opasswd
chown root:root /etc/login.defs
chmod 644 /etc/login.defs
chown root:root /etc/sudoers
chmod 400 /etc/sudoers
chown -R root:root /etc/sudoers.d
chmod 750 /etc/sudoers.d
find /etc/sudoers.d -type f -exec chmod 400 {} \;
chown -R root:root /etc/pam.d
chmod 755 /etc/pam.d
chmod 644 /etc/pam.d/*

# Set ownership and permissions for /etc/security
chown -R root:root /etc/security
chmod 755 /etc/security
chmod go-w /etc/security

# Set ownership and permissions for cron-related files
chown root:root /etc/anacrontab
chmod 640 /etc/anacrontab
chown root:root /etc/crontab
chmod 640 /etc/crontab
chown -R root:root /etc/cron.hourly
chmod 750 /etc/cron.hourly
chown -R root:root /etc/cron.daily
chmod 750 /etc/cron.daily
chown -R root:root /etc/cron.weekly
chmod 750 /etc/cron.weekly
chown -R root:root /etc/cron.monthly
chmod 750 /etc/cron.monthly
chown -R root:root /etc/cron.d
chmod 750 /etc/cron.d

# Set ownership and permissions for environment-related files
chown root:root /etc/environment
chmod 644 /etc/environment
chown root:root /etc/profile
chmod 644 /etc/profile
chown root:root /etc/bash.*
chmod 644 /etc/bash.*
chown root:root /etc/host*
chmod 644 /etc/host*

# Set permissions for directories
chmod 700 /boot
chmod 700 /usr/src
chmod 700 /lib/modules
chmod 700 /usr/lib/modules
chown root:root /home
chmod 755 /home
chown root:root /root
chmod 700 /root

# Set ownership and permissions for user home directories, .ssh, and .gnupg
for home in /home/*; do
    user=$(basename "$home")
    chown -R "$user:$user" "$home"
    chmod 700 "$home"
    if [[ -d "$home/.ssh" ]]; then
        chmod 700 "$home/.ssh"
        chmod 600 "$home/.ssh/*"
    fi
    if [[ -d "$home/.gnupg" ]]; then
        chmod 700 "$home/.gnupg"
        chmod 600 "$home/.gnupg/*"
    fi
done

psuccess "Corrected common file permissions"
