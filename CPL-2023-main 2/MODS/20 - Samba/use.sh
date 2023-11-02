#!/usr/bin/env bash

# Disable guest access in Samba by modifying the smb.conf file
sed -i 's/^.*guest ok.*$/    guest ok = no/' /etc/samba/smb.conf

# Disable allowing guests in user shares in Samba
sed -i 's/^.*usershare allow guests.*$/usershare allow guests = no/' /etc/samba/smb.conf

# If AppArmor is in use, configure and enforce Samba's AppArmor profile
if use apparmor; then
    # Install and configure the AppArmor profile for smbd
    instconf $RC/usr.sbin.smbd /etc/apparmor.d/usr.sbin.smbd

    # Enforce the AppArmor profile for smbd
    aa-enforce /usr/sbin/smbd

    # Reload the updated AppArmor profile
    cat /etc/apparmor.d/usr.sbin.smbd | apparmor_parser -r
fi

# Restart the Samba services (smbd and nmbd)
systemctl restart smbd.service nmbd.service && psuccess "Restarted samba" || perror "Failed to restart samba"
