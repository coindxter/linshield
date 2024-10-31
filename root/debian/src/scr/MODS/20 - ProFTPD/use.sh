#!/usr/bin/env bash
# TODO: Visit http://www.proftpd.org/docs/howto/TLS.html for more information on configuring TLS

# Allow FTP and FTPS connections through UFW firewall
ufw allow ftp
ufw allow ftps

# Create a directory for ProFTPD logs and set up a TLS log file
mkdir -p /var/log/proftpd/
touch /var/log/proftpd/tls.log
chown proftpd:root /var/log/proftpd/tls.log
psuccess "Created log file"

# Install and configure ProFTPD using the provided configuration file
instconf $RC/proftpd.conf /etc/proftpd/proftpd.conf
mkdir -p $BACKUP/proftpd
mv /etc/proftpd/conf.d/* $BACKUP/proftpd
psuccess "Configured proftpd"

# Install and configure TLS for ProFTPD
instconf $RC/tls.conf /etc/proftpd/tls.conf

# Generate a self-signed SSL/TLS certificate if it doesn't already exist
if ! [[ -f /etc/ssl/private/proftpd.key ]]; then
    mkdir -p /etc/ssl/private
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com"
fi

# Set appropriate permissions for the SSL/TLS certificate files
chmod 700 /etc/ssl/{private,certs}
chmod 600 /etc/ssl/private/proftpd.key
chmod 600 /etc/ssl/certs/proftpd.crt
psuccess "Configured proftpd TLS"

# Restart ProFTPD service
systemctl restart proftpd && psuccess "Restarted proftpd" || perror "Failed to restart proftpd"
