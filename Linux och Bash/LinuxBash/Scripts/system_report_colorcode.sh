#!/bin/bash

#If you want to run the script with cron scheduling run script with aruument --setup-cron also explained bellow in cron section

#Create log file for storing cronjob logs
log_file="$HOME/Linux-inlamning/logs/system_report_color_code.log"
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
echo "//***** SYSTEM REPORT *****//" > "$report" #Append to report
echo "Generated: $(date)" >> "$report"
printf '\n' #Used to get a blank row in the report to separate

#Show the last 10 failed logins
echo "//***** Last 10 failed login attempts *****//" >> "$report"
#Using journalctl - reads loggs from systemd-journal | tail -n 10 (ger senaste 10)
journalctl -u ssh | grep "Failed password" | tail -n 10 >> "$report"
printf '\n'

#List the 5 latest created users
echo "//***** The 5 most recently created users *****//" >> "$report"
# Specifiy field separator as ":" in /etc/passwd print $1 $3 prints out the username in field 1 and UID in field 3
#sort -k2 -n sorts UID alphabeticaly
awk -F: '{print $1, $3}' /etc/passwd | sort -k2 -n | tail -n 5 >> "$report"
printf '\n'

#Sudo uses in the last 24h
echo "//***** Sudo usage in the last 24 hours *****//" >> "$report"
#Filter proccessname sudo with _COMM=sudo and use --since "24 hours ago" to limit to the last 24 hours
journalctl _COMM=sudo --since "24 hours ago" >> "$report"
printf '\n'

#SSH-connection per IP (the last 100 rows)
echo "//***** SSH connections per IP last 100 log lines *****//" >> "$report"
#I use -u ssh to filter on ssh, awk $11 to print out the IP adress, uniq -c is used to count how many time each IP shows in SSH-log
#and sort -nr sorts in numerical order
journalctl -u ssh --since "7 days ago" | grep "Accepted" | tail -n 100 | awk '{print $11}' | sort | uniq -c | sort -nr >> "$report"
printf '\n'

#Diskspace warning if > 80%
echo "//***** Disk usage *****//"
printf '\n'
} > "$report"

{
# ANSI color codes (use \033 instead of \e for awk compatibility (not used in monitor_disk.sh))
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"
#df is used to show diskspace and -h for a 'human' readbale so Gigabytes or Megabytes which pipes to awk to mark for Warning if > 80%
#pipe into awk passing in color code (-v lets me assign values to awk variables before awk runs), NR==1 used to keep header row so the column titles are shown 
df -h | awk -v red="$red" -v green="$green" -v yellow="$yellow" -v reset="$reset" '
NR==1 {print $0; next}
{   
    #Remove the % sign from column 5 and convert to number
    usage=$5+0
    #If usase is > 90 mark CRITICAL in red and yellow for WARNING and green for OK
    if (usage > 90) {
        print $0, red "[CRITICAL]" reset
    } else if (usage > 80) {
        print $0, yellow "[WARNING]" reset
    } else {
        print $0, green "[OK]" reset
    }
}' 
printf '\n'
} | tee -a "$report" #Used to check for color coding correctly in terminal window aswell as append text to report file
#Endmessage
echo "[INFO] Report saved to $report" | tee -a "$log_file"