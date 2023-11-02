#!/usr/bin/env bash

# Disable services using 'disnow'
services=("nfs-server" "rpcbind" "dovecot" "squid" "nis" "snmpd" "rsync" "postfix")
for service in "${services[@]}"; do
    disnow "$service"
done

# Disable postfix using 'update-rc.d'
update-rc.d postfix disable

# Prelink cleanup
prelink -ua

# List of banned hacking tools and unnecessary packages
banned=(
    "hydra" "nmap" "zenmap" "john" "medusa" "vino" "ophcrack" "aircrack-ng" "fcrackzip" "nikto"
    "iodine" "kismet" "packit" "pcmpem" "goldeneye" "themole" "empathy" "prelink" "minetest"
    "snmp" "nfs-kernel-server" "rsh-client" "talk" "squid" "nis" "portmap" "ldap-utils" "slapd"
    "tightvncserver" "inspircd" "ircd-hybrid" "ircd-irc2" "ircd-ircu" "ngircd" "tircd" "znc"
    "sqwebmail" "cyrus-imapd" "dovecot-imapd"
)

# Check if packages are installed and remove them
for package in "${banned[@]}"; do
    if ! apt-cache madison "$package" &>/dev/null; then
        echo "$package"
    fi
done

apt remove -y "${banned[@]}" || pwarn "Retrying removal in filtered mode" && aptr "${banned[@]}" || perror "Failed to remove banned packages"

aptar
