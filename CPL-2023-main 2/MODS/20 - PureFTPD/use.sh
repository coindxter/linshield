#!/usr/bin/env bash

# Allow FTP and FTPS connections through UFW firewall
ufw allow ftp
ufw allow ftps

# Install and configure Pure-FTPd using the provided configuration file
instconf $RC/pure-ftpd.conf /etc/pure-ftpd/pure-ftpd.conf

# Create a directory for Pure-FTPd transfer logs
mkdir -p /var/log/pure-ftpd/transfer.log

# Remove existing configuration directory and create a new one
rm -rf /etc/pure-ftpd/conf
mkdir -p /etc/pure-ftpd/conf

# Configure Pure-FTPd options using the echo command
echo "2" > /etc/pure-ftpd/conf/TLS
echo "yes" > /etc/pure-ftpd/conf/NoAnonymous
echo "no" > /etc/pure-ftpd/conf/AnonymousOnly
echo "no" > /etc/pure-ftpd/conf/UnixAuthentication
echo "yes" > /etc/pure-ftpd/conf/PAMAuthentication
echo "no" > /etc/pure-ftpd/conf/ChrootEveryone
echo "HIGH" > /etc/pure-ftpd/conf/TLSCipherSuite
echo "/etc/pure-ftpd/pureftpd.pdb" > /etc/pure-ftpd/conf/PureDB
echo "clf:/var/log/pure-ftpd/transfer.log" > /etc/pure-ftpd/conf/AltLog
echo "UTF-8" > /etc/pure-ftpd/conf/FSCharset
echo "1000" > /etc/pure-ftpd/conf/MinUID
psuccess "Configured pure-ftpd"

# Generate TLS certificate and key if they don't already exist
if ! [[ -f /etc/ssl/private/pure-ftpd.pem ]]; then
    mkdir -p /etc/ssl/private
    pinfo "Generate Diffie-Hellman Parameters"
    openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048
    pinfo "Generate TLS certificate and key"
    openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com"
    psuccess "Configured pure-ftpd TLS"
fi

# Set appropriate permissions for the TLS certificate and key
chmod 700 /etc/ssl/private/
chmod 600 /etc/ssl/private/*.pem

# Restart Pure-FTPd service
systemctl restart pure-ftpd && psuccess "Restarted pure-ftpd" || perror "Failed to restart pure-ftpd"
