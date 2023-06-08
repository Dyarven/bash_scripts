#!/bin/bash

backup_path="/opt/backups/minecraft-server"
backup_file="minecraft-backup-$(date +'%H-%M-%d-%m-%Y').tar.gz"
minecraft="/opt/minecraft-server"
world_path="${minecraft}/world"
config_files=("server.properties" "whitelist.json" "banned-ips.json" "banned-players.json")

mkdir -p "/opt/backups/minecraft-server"

# launch backup
tar -czvf "${backup_path}/${backup_file}" -C "${minecraft}" \
  --transform="s,^./,minecraft-backup-$(date +'%H-%M-%d-%m-%Y')/," \
  "$(basename "${world_path}")" \
  $(printf "%s\n" "${config_files[@]/#/${minecraft}/}")