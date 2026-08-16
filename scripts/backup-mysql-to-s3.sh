#!/bin/bash

set -e

MYSQL_CONTAINER="student-notes-mysql"
MYSQL_DATABASE="student_notes"
MYSQL_USER="root"
MYSQL_PASSWORD="root"

S3_BUCKET="student-notes-mysql-backup-651706778443"

BACKUP_DIR="backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

BACKUP_FILE="${BACKUP_DIR}/student_notes_${TIMESTAMP}.sql"

echo "======================================"
echo "Starting MySQL backup"
echo "======================================"

echo "Checking MySQL container..."

if ! docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
    echo "ERROR: MySQL container is not running."
    exit 1
fi

echo "MySQL container is running."

echo "Creating MySQL dump..."

docker exec "$MYSQL_CONTAINER" \
    mysqldump \
    --single-transaction \
    --set-gtid-purged=OFF \
    -u "$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    "$MYSQL_DATABASE" > "$BACKUP_FILE"

echo "MySQL dump created:"
echo "$BACKUP_FILE"

echo "Uploading backup to S3..."

aws s3 cp \
    "$BACKUP_FILE" \
    "s3://${S3_BUCKET}/backups/"

echo "Backup uploaded successfully."

echo "======================================"
echo "Backup completed successfully"
echo "======================================"