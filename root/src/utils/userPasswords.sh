#!/bin/bash

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
    if [[ ! " ${authorizedUsers[@]} " =~ " $user " ]] && ! [[ " ${defaultAccounts[@]} " =~ " $user " ]]; then
        unauthorizedUsers+=("$user")
    fi
done

for user in "${authorizedUsers[@]}"; do
    if [[ ! " ${currentUsers[@]} " =~ " $user " ]]; then
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
read -p "Would you like to fix these issues? (yes/no): " consent

if [ "$consent" == "yes" ]; then
    # Remove unauthorized users
    for user in "${unauthorizedUsers[@]}"; do
        sudo userdel -r "$user"
    done

    # Remove unauthorized admins from sudo group
    for admin in "${unauthorizedAdmins[@]}"; do
        sudo deluser "$admin" sudo
    done

    # Add missing users
    for user in "${missingUsers[@]}"; do
        sudo useradd -m "$user"
    done

    # Add missing admins to sudo group
    for admin in "${missingAdmins[@]}"; do
        sudo usermod -aG sudo "$admin"
    done

    # Change passwords for all users
    newPassword="ThisIsASecurePassword12345!"
    for user in "${currentUsers[@]}"; do
        echo -e "$newPassword\n$newPassword" | sudo passwd "$user"
        echo "Password changed for: $user"
    done

    # Disable password aging for all users
    for user in "${currentUsers[@]}"; do
        sudo chage -I 1 -m 1 -M 30 -E 7 "$user"
        echo "Password aging disabled for: $user"
    done

    echo "Passwords updated and password aging disabled for all users."

fi

# Save the new password for all users to a file
echo "$newPassword" | sudo tee /etc/secure_password.txt > /dev/null

echo "New password saved to /etc/secure_password.txt"
