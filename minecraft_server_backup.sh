#!/bin/bash

WORLD_DIR="/opt/minecraft-server/world"
BACKUP_DIR="/opt/minecraft-server/backups/current_world"
LOG_DIR="/opt/minecraft-server/logs"
DATE=$(date +"%d-%m-%Y_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

cd "$WORLD_DIR"
zip -r "$BACKUP_DIR/world_backup_$DATE.zip" ./*

# Delete backups older than 14 days
find "$BACKUP_DIR" -type f -name "*.zip" -mtime +14 -exec rm {} \;

# Delete logs older than 14 days
find "$LOG_DIR" -type f -name "*.gz" -mtime +14 -exec rm {} \;
