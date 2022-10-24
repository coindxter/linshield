#!/bin/bash
apt install plocate
apt install vim
apt install aide aide-common
apt purge prelink
apt purge apport
apt purge autofs
apt install chrony
systemctl stop systemd-timesyncd.service
systemctl -now mask systemd-timesyncd.service
apt purge ntp
apt purge xserver-xorg*
systemctl stop avahi-daemon.service
systemctl stop avahi-daemon.socket
apt purge avahi-daemon
apt purge cups
apt purge isc-dhcp-server
apt purge slapd
apt purge nfs-kernel-server
apt purge bind9
apt purge vsftpd
apt purge apache2
apt purge dovecot-imapd dovecot-pop3d
apt purge samba
apt purge squid
apt purge snmp
apt purge nis
apt purge mariadb
apt purge rsync
apt purge rsh-client
apt purge talk
apt purge telnet
apt purge ldap-utils
apt purge rpcbind
apt install ufw
apt purge iptables-persistent
systemctl unmask ufw.service
apt install auditd audispd-plugins
systemctl -now enable auditd
apt install systemd-journal-remote
apt install sudo
sudo apt autoremove


