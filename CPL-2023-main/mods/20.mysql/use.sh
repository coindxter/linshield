!/usr/bin/env bash

# Define helper functions
instconf() {
    cp "$1" "$2" && echo "[SUCCESS] Copied $1 to $2" || echo "[ERROR] Failed to copy $1 to $2"
}

psuccess() {
    echo "[SUCCESS] $1"
}

perror() {
    echo "[ERROR] $1" >&2
}

ptodo() {
    echo "[TODO] $1"
}

# Define RC variable (update this to your directory containing the configuration files)
RC="$(pwd)"

# Deny incoming connections to MySQL using the 'ufw' firewall
echo "[INFO] Denying incoming MySQL connections..."
ufw deny mysql || perror "Failed to deny MySQL connections with UFW"

# Copy configuration files
instconf "$RC/my.cnf" "/etc/mysql/mysql.cnf"

# Check if /etc/mysql/my.cnf is not a symbolic link
if [[ ! -L /etc/mysql/my.cnf ]]; then
    instconf "$RC/my.cnf" "/etc/mysql/my.cnf"
fi

instconf "$RC/mysqld.cnf" "/etc/mysql/mysql.conf.d/mysqld.cnf"
instconf "$RC/mysql.cnf" "/etc/mysql/conf.d/mysql.cnf"

# Restart the MySQL service
echo "[INFO] Restarting MySQL service..."
if systemctl restart mysql; then
    psuccess "Restarted MySQL service"
else
    perror "Failed to restart MySQL service"
    exit 1
fi

# Suggest further actions
ptodo "Consider setting up TLS for MySQL"

