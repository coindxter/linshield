#!/usr/bin/env bash

# Deny incoming connections to MySQL using the 'ufw' firewall
ufw deny mysql

# Copy the my.cnf configuration file from the specified location to /etc/mysql/mysql.cnf
instconf $RC/my.cnf /etc/mysql/mysql.cnf

# Check if /etc/mysql/my.cnf is not a symbolic link (indicating it's not already configured)
# If it's not a symbolic link, copy the my.cnf configuration file to /etc/mysql/my.cnf
if [[ ! -L /etc/mysql/my.cnf ]];
    instconf $RC/my.cnf /etc/mysql/my.cnf
fi

# Copy the mysqld.cnf configuration file from the specified location to /etc/mysql/mysql.conf.d/mysqld.cnf
instconf $RC/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# Copy the mysql.cnf configuration file from the specified location to /etc/mysql/conf.d/mysql.cnf
instconf $RC/mysql.cnf /etc/mysql/conf.d/mysql.cnf

# Restart the MySQL service using 'systemctl'
systemctl restart mysql && psuccess "Restarted mysql" || perror "Failed to restart mysql"

ptodo "Consider setting up TLS for MySQL"
