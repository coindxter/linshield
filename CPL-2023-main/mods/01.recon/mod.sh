#!/usr/bin/env bash

pwarn() { echo "[WARN] $1"; }
pignore() { echo "[INFO] $1"; }
perror() { echo "[ERROR] $1" >&2; }
mod() { echo "[MOD] Placeholder for $1"; }
todo() { echo "[TODO] $1"; }

pkgchk() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; then
        if (($# > 1)); then
            pwarn "$1 is INSTALLED and $2 is $(systemctl is-active "$2" 2>/dev/null)"
        else
            pwarn "$1 is INSTALLED"
        fi
    else
        pignore "$1 is not installed"
    fi
}

pkgchk openssh-server sshd
pkgchk apache2 apache2
pkgchk mysql mysql
pkgchk php
pkgchk wordpress
pkgchk vsftpd vsftpd
pkgchk proftpd proftpd
pkgchk pure-ftpd pure-ftpd
pkgchk samba smbd
pkgchk bind9 named
pkgchk nginx nginx
pkgchk postgresql postgresql
pkgchk postfix postfix

if [[ -d /var/www ]]; then
    pwarn "/var/www found"
else
    pignore "/var/www not found"
fi

if command -v snap &>/dev/null; then
    pwarn "snap exists"
else
    pignore "snap does not exist"
fi

check_duplicates() {
    local file="$1"
    local field="$2"
    local name="$3"
    cat "$file" | cut -f"$field" -d":" | sort -n | uniq -c | while read -r line; do
        [[ -z $line ]] && break
        set - $line
        if (( $1 > 1 )); then
            values=$(awk -F: '($'$field' == n) { print $1 }' n=$2 "$file" | xargs)
            perror "Duplicate $name ($2): $values"
        fi
    done
}

check_duplicates /etc/passwd 3 "UID"
check_duplicates /etc/group 3 "GID"
check_duplicates /etc/passwd 1 "User Name"
check_duplicates /etc/group 1 "Group Name"

if grep -q "^shadow:[^:]*:[^:]*:[^:]+" /etc/group; then
    perror "Shadow group has users. Remove!!"
fi

if awk -F: '($4 == "42") { print }' /etc/passwd | grep -Eq '.*'; then
    perror "Shadow group has users. Remove!!"
fi

mod manual-pkgs
mod default-config

todo "Read recon report above (reminder: duplicate users/groups are best removed immediately)"
