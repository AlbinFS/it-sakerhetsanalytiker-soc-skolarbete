#!/bin/bash

#If you want to run the script with cron scheduling run script with aruument --setup-cron also explained bellow in cron section

#Create log file for storing cronjob logs
log_file="$HOME/Linux-inlamning/logs/monitor_disk.log"
#Create log file for storing disk satus reports
disk_status_file="$HOME/Linux-inlamning/logs/disk_status.log"

#ANIS color code
red="\e[31m"
green="\e[32m"
reset="\e[0m"

#If script is run with argument "--setup-cron" this ensures the script will schedule itself as a daily cron job
#Prevents duplicates by checking if the current cron job already exists, if not appends the new entry into crontab
#This also logs any everything, so we can see if a cronjob already exists, if it was sucessfull or failed
if [ "$1" == "--setup-cron" ]; then
    cron_backup="0 6,9,12,15,18,20 * * * $(realpath "$0")"
    if ! crontab -l 2>/dev/null | grep -F "$cron_backup" >/dev/null; then
        if (crontab -l 2>/dev/null; echo "$cron_backup") | crontab -; then
            echo "[$(date)] [OK] Cron job successfully scheduled at every third hour where the last report is generated at 20:00 and the first resumes at 06:00" | tee -a "$log_file"
        else
            echo "[$(date)] [ERROR] Failed to setup a scheduled cron job" | tee -a "$log_file"
            exit 1
        fi
    else
        echo "[$(date)] [INFO] A scheduled cron job already exists: $cron_backup" | tee -a "$log_file"
    fi
    exit 0
fi

echo -e "//***** DISK MONITORING *****//" | tee -a "$disk_status_file"


#Get disk status
df -h --output=target,pcent | tail -n +2 | while read -r mount usage; do
    #Remove % from usage so comparison is possible as a pure number value 
    percent=${usage%\%} 
    #Use if else loop inorder to use red or green depending on if the % is '<' or '>' than 90%
    if [ "$percent" -ge 90 ]; then
        echo -e "$mount : ${red}$usage [WARNING]${reset}" | tee -a "$disk_status_file"

    else
        echo -e "$mount : ${green}$usage [OK]${reset}" | tee -a "$disk_status_file"

    fi
done

echo "[$(date)] [OK] Disk status report has been saved to $disk_status_file" | tee -a "$disk_status_file"

