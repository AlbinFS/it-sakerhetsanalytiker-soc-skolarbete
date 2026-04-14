#!/bin/bash

#If you want to run the script with cron scheduling run script with aruument --setup-cron also explained bellow in cron section

#Create log file for storing cronjob logs
log_file="$HOME/Linux-inlamning/logs/system_report.log"
#Create filname with datestamp
report="$HOME/Linux-inlamning/reports/system_report_$(date +%Y%m%d_%H%M%S).log"

#If script is run with argument "--setup-cron" this ensures the script will schedule itself as a daily cron job
#Prevents duplicates by checking if the current cron job already exists, if not appends the new entry into crontab
#This also logs any everything, so we can see if a cronjob already exists, if it was sucessfull or failed
if [ "$1" == "--setup-cron" ]; then
    cron_backup="0 0 * * * $(realpath "$0")"
    if ! crontab -l 2>/dev/null | grep -F "$cron_backup" >/dev/null; then
        if (crontab -l 2>/dev/null; echo "$cron_backup") | crontab -; then
            echo "[$(date)] [OK] Cron job successfully scheduled daily at 00:00" | tee -a "$log_file"
        else
            echo "[$(date)] [ERROR] Failed to setup a scheduled cron job" | tee -a "$log_file"
            exit 1
        fi
    else
        echo "[$(date)] [INFO] A scheduled cron job already exists: $cron_backup" | tee -a "$log_file"
    fi
fi

#Begin system report
{
echo "//***** SYSTEM REPORT *****//" 
echo "Generated: $(date)"
echo  #Used to get a blank row in the report to separate

#Show the last 10 failed logins
echo "//***** Last 10 failed login attempts *****//" 
#Using journalctl - reads loggs from systemd-journal | tail -n 10 (ger senaste 10)
journalctl -u ssh | grep "Failed password" | tail -n 10 
echo 

#List the 5 latest created users
echo "//***** The 5 most recently created users *****//"
# Specifiy field separator as ":" in /etc/passwd print $1 $3 prints out the username in field 1 and UID in field 3
#sort -k2 -n sorts UID alphabeticaly
awk -F: '{print $1, $3}' /etc/passwd | sort -k2 -n | tail -n 5
echo 


#Sudo uses in the last 24h
echo "//***** Sudo usage in the last 24 hours *****//" 
#Filter proccessname sudo with _COMM=sudo and use --since "24 hours ago" to limit to the last 24 hours
journalctl _COMM=sudo --since "24 hours ago" 
echo 

#SSH-connection per IP (the last 100 rows)
echo "//***** SSH connections per IP last 100 log lines *****//"
#I use -u ssh to filter on ssh, awk $11 to print out the IP adress, uniq -c is used to count how many time each IP shows in SSH-log
#and sort -nr sorts in numerical order
journalctl -u ssh | grep "Accepted" | tail -n 100 | awk '{print $11}' | sort | uniq -c | sort -nr 
echo 

#Diskspace warning if > 80%
echo "//***** Disk usage *****//"
#df is used to show diskspace and -h for a 'human' readbale so Gigabytes or Megabytes which pipes to awk to mark for Warning if > 80%
df -h | awk 'NR==1 || $5+0 > 80 {print $0, ($5+0 > 80? " [WARNING]" : "")}'
echo 
} > "$report"

#Endmessage
echo "[INFO] Report saved to $report" | tee -a "$log_file"