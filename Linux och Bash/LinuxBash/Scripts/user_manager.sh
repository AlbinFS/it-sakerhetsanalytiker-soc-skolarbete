#!/bin/bash

#Create a menu loop that keeps the menu running unless Exit (5) has been choosen, becuase while true.
#read -p looks fore users choice in the menu and uses that in the case
while true; do
echo "//****** USER MANAGER ******//"
echo "1) Create new user"
echo "2) Remove user"
echo "3) List all users"
echo "4) Add user to group"
echo "5) Exit"
read -rp "Choose one option 1-5: " choice

#Using case, makes it easier than using if elif as each menu options gets its own block where ;; serves the same purpose
#as break does in C-style languages but in bash this is mandatory to prevent fall through.
case $choice in
    1)
        read -rp "Input username: " user
        #Checks if user already exists
        if id "$user" &>/dev/null; then
            echo "[ERROR] Username '$user' already exists."
        else
        #Creates user and home directory - only prints [OK]... if commands was successfull
            sudo useradd -m "$user" && echo "[OK] User '$user' created."
        fi
        ;;
    2)
        read -rp "Input username: " user
        #Asks user to confirm deletion of user by prompting with another input either y(yes) or n(no)
        if id "$user" &>/dev/null; then
            read -rp "Are you sure that you want to remove '$user' (y/n): " confirm
            #If input = y(yes) then delete user and home directory
            [[ "$confirm" == "y" ]] && sudo userdel -r "$user" && echo "[OK] User '$user' has been removed."
        else
            echo "[ERROR] User '$user' does not exist"
        fi
        ;;
    3)
        echo "//***** All users *****//"
        #Contains all local users and extract just the usernames with cut -d: -f1
        cut -d: -f1 /etc/passwd
        ;;
    4)
        read -rp "Input username: " user
        read -rp "Input groupname: " group
        #Check if both user and group exists if it does continue down else gives error
        if id "$user" &>/dev/null && getent group "$group" &>/dev/null; then
        #usermod -aG appends the group without overwriting existing memberships - adds user to group
            sudo usermod -aG "$group" "$user" && echo "[OK] '$user' was added to the group '$group'."
        else
            echo "[ERROR] Invalid user or group."
        fi
        ;;
    5)
        #Breaks the loop - exits
        echo "Exiting"
        break
        ;;
    *)
        #Catches any invalid inputs (not 1-5) and gives an error for the user to make another choice
        echo "[ERROR] Invalid choice, try again."
        ;;
    #Close case
    esac
#Close while true loop (menu loop)
done