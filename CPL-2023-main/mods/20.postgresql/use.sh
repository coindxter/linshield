#!/usr/bin/env bash

# Define PostgreSQL configuration directory
PG_DIR="/etc/postgresql/14/main"
PG_CONFIG="$PG_DIR/postgresql.conf"
PG_HBA_CONFIG="$PG_DIR/pg_hba.conf"
PG_IDENT_CONFIG="$PG_DIR/pg_ident.conf"

# Verify that the PostgreSQL configuration directory exists
if [[ ! -d $PG_DIR ]]; then
    echo "[ERROR] PostgreSQL configuration directory not found: $PG_DIR"
    exit 1
fi

# Backup configuration files
echo "[INFO] Backing up PostgreSQL configuration files..."
for file in $PG_CONFIG $PG_HBA_CONFIG $PG_IDENT_CONFIG; do
    if [[ -f $file ]]; then
        cp "$file" "$file.bak"
        echo "[INFO] Backed up $file to $file.bak"
    else
        echo "[WARN] Configuration file not found: $file"
    fi
done

# Update PostgreSQL configurations
echo "[INFO] Updating PostgreSQL configurations..."
sed -i "s/#password_encryption =.*$/password_encryption = scram-sha-256/" $PG_CONFIG
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" $PG_CONFIG
echo "host    all    all    127.0.0.1/32    md5" >> $PG_HBA_CONFIG
echo "host    all    all    0.0.0.0/0    reject" >> $PG_HBA_CONFIG

# Restart PostgreSQL
echo "[INFO] Restarting PostgreSQL service..."
if systemctl restart postgresql; then
    echo "[SUCCESS] PostgreSQL service restarted successfully."
else
    echo "[ERROR] Failed to restart PostgreSQL service."
    exit 1
fi

# Verify PostgreSQL status
echo "[INFO] Checking PostgreSQL service status..."
systemctl status postgresql
