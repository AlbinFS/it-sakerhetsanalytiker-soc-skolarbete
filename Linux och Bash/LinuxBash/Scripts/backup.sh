#!/bin/bash

#If you want to run the script with cron scheduling run script with aruument --setup-cron also explained bellow in cron section

#Source folder
source_dir="/srv/developers"
#Backup folder
backup_dir="/backup"
#Logfile where log operations are written to (this is hardcoded due to running this commands with sudo(nessecary since this writes to backup and developers under /root)
#would otherwise change $HOME to be root and therefore not beeing able to find the /Linux-inlamning/logs/ path where logs are to be saved.)
log_file="/home/albin/Linux-inlamning/logs/backup.log"
#How many days should the backups retain before deletion
retention_days=7
#Date and time used in the file name
date=$(date '+%Y%m%d_%H%M%S')

#If script is run with argument "--setup-cron" this ensures the script will schedule itself as a daily cron job
#Prevents duplicates by checking if the current cron job already exists, if not appends the new entry into crontab
#This also logs any everything, so we can see if a cronjob already exists, if it was sucessfull or failed
if [ "$1" == "--setup-cron" ]; then
    cron_backup="0 0 * * * $(realpath "$0")"
    if ! crontab -l 2>/dev/null | grep -F "$cron_backup" >/dev/null; then
        if (crontab -l 2>/dev/null; echo "$cron_backup") | crontab -; then
            echo "[$(date)] [OK] Cron job successfully scheduled for every Day at 00:00" | tee -a "$log_file"
        else
            echo "[$(date)] [ERROR] Failed to setup a scheduled cron job" | tee -a "$log_file"
            exit 1
        fi
    else
        echo "[$(date)] [INFO] A scheduled cron job already exists: $cron_backup" | tee -a "$log_file"
    fi
    exit 0
fi

#Create backup dir
mkdir -p "$backup_dir"

#Create filename with date:developers_YYYYMMDD_HHMMSS.tar.gz
base_name=$(basename "$source_dir")
backup_file="$backup_dir/${base_name}_${date}.tar.gz"

#Create compressed backup with tar using relative paths, extract the parent directory (/srv) and then the folder name
#(developers) temporarily changes working dir to (/srv) runs tar on developers then returns to original working dir. (Subshell)
if (cd "$(dirname "$source_dir")" && tar -czf "$backup_file" "$(basename "$source_dir")"); then
    size=$(du -h "$backup_file" | cut -f1)
    echo "[$(date)] [INFO] Backup created: $backup_file (Size: $size)" | tee -a "$log_file"
else
    echo "[$(date)] [WARNING] Failed to create backup: $backup_file (Size: $size)" | tee -a "$log_file"
    exit 1
fi

#Find and remove old backups
deleted=$(find "$backup_dir" -name "${base_name}_*.tar.gz" -mtime +$retention_days -print -delete | wc -l)
echo "[$(date)] [INFO] Cleared $deleted old backups (> $retention_days days)" | tee -a "$log_file"

