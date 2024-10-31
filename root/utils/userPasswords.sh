#!/bin/bash

# Define auto-login user
read -p "Please enter the auto-login user (the user you want to exclude from changes): " autoLoginUser

# Define authorized users and admins
read -p "Please enter the authorized users (comma-separated, no spaces): " authorizedUsers
read -p "Please enter the authorized admins (comma-separated, no spaces): " authorizedAdmins

IFS=',' read -ra authorizedUsers <<< "$authorizedUsers"
IFS=',' read -ra authorizedAdmins <<< "$authorizedAdmins"

defaultAccounts=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "systemd-timesync" "messagebus" "avahi" "cups" "ssl-cert" "avahi-autoipd" "usbmux" "pulse" "rtkit" "saned" "whoopsie" "kernoops" "speech-dispatcher" "hplip" "sshd" "geoclue" "gnome-initial-setup" "gdm" "mysql")

# Get current users and admins
currentUsers=($(getent passwd | awk -F: '($3 >= 1000) && ($3 < 65534) { print $1 }'))
currentAdmins=($(getent group sudo | cut -d: -f4 | tr ',' ' '))

# Find unauthorized and missing users and admins
unauthorizedUsers=()
missingUsers=()
unauthorizedAdmins=()
missingAdmins=()

for user in "${currentUsers[@]}"; do
    if [[ ! " ${authorizedUsers[@]} " =~ " $user " ]] && ! [[ " ${defaultAccounts[@]} " =~ " $user " ]] && [ "$user" != "$autoLoginUser" ]; then
        unauthorizedUsers+=("$user")
    fi
done

for user in "${authorizedUsers[@]}"; do
    if [[ ! " ${currentUsers[@]} " =~ " $user " ]] && [ "$user" != "$autoLoginUser" ]; then
        missingUsers+=("$user")
    fi
done

for admin in "${currentAdmins[@]}"; do
    if [[ ! " ${authorizedAdmins[@]} " =~ " $admin " ]]; then
        unauthorizedAdmins+=("$admin")
    fi
done

for admin in "${authorizedAdmins[@]}"; do
    if [[ ! " ${currentAdmins[@]} " =~ " $admin " ]]; then
        missingAdmins+=("$admin")
    fi
done

# Print unauthorized and missing users and admins
echo "Unauthorized users: ${unauthorizedUsers[*]}"
echo "Missing users: ${missingUsers[*]}"
echo "Unauthorized admins: ${unauthorizedAdmins[*]}"
echo "Missing admins: ${missingAdmins[*]}"

# Ask for consent to fix issues
read -p "Would you like to fix these issues? (y/n): " consent

if [ "$consent" == "y" ]; then
    # Remove unauthorized users from sudo group
    for user in "${unauthorizedUsers[@]}"; do
        sudo deluser "$user" 
    done

    # Add missing users
    for user in "${missingUsers[@]}"; do
        sudo useradd -m "$user"
    done

    # Add missing admins to sudo group
    for admin in "${missingAdmins[@]}"; do
        sudo usermod -aG sudo "$admin"
    done
    
    # Remove unauthorized admins from sudo group
    for admin in "${unauthorizedAdmins[@]}"; do
        sudo deluser "$admin" sudo
        echo "Removed admin: $admin from sudo group"
    done


    # Change passwords for all users
    newPassword="Student123!"
    for user in "${currentUsers[@]}"; do
        if [ "$user" != "$autoLoginUser" ]; then
            echo -e "$newPassword\n$newPassword" | sudo passwd "$user"
            echo "Password changed for: $user"
        fi
    done

    # Disable password aging for all users
    for user in "${currentUsers[@]}"; do
        if [ "$user" != "$autoLoginUser" ]; then
            sudo chage -I -1 -m 0 -M 99999 -E -1 "$user"
            echo "Password aging disabled for: $user"
        fi
    done

    echo "Changes applied."

else
    echo "Nothing changed"
fi
