#!/bin/bash
# -------------------------------------------------------------------------
# Secure MySQL Backup Script with Rotation
# -------------------------------------------------------------------------

# Configuration
DB_USER="admin_user"
DB_PASS="StrongAdminPass1!"
DB_PORT="3307"
BACKUP_DIR="/backup/mysql"
DATE=$(date +%F_%H-%M)
RETENTION_DAYS=7

# Ensure backup directory exists
mkdir -p $BACKUP_DIR
chmod 700 $BACKUP_DIR

echo "Starting backup for $DATE..." >> $BACKUP_DIR/backup_log.txt

# Execute Dump
# --single-transaction: Ensures no locking on InnoDB tables
# --routines: Exports stored procedures
# --triggers: Exports triggers
mysqldump -u $DB_USER -p$DB_PASS --port=$DB_PORT \
    --single-transaction --routines --triggers --all-databases \
    > $BACKUP_DIR/full_backup_$DATE.sql

# Check status and compress
if [ $? -eq 0 ]; then
    echo "Dump successful. Compressing..." >> $BACKUP_DIR/backup_log.txt
    gzip $BACKUP_DIR/full_backup_$DATE.sql
    
    # Secure the file (Read/Write for root only)
    chmod 600 $BACKUP_DIR/full_backup_$DATE.sql.gz
    echo "Backup Complete: full_backup_$DATE.sql.gz" >> $BACKUP_DIR/backup_log.txt
else
    echo "CRITICAL: Backup Failed for $DATE" >> $BACKUP_DIR/backup_log.txt
    # In a real scenario, you would add an email alert here
    exit 1
fi

# Maintenance: Remove backups older than 7 days
find $BACKUP_DIR -type f -name "*.gz" -mtime +$RETENTION_DAYS -delete