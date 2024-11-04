#!/bin/bash

# validate user is root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Part 1: Modify /etc/login.defs for password aging and login parameters
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/; s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/; s/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/; s/^LOGIN_RETRIES.*/LOGIN_RETRIES 3/; s/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT 60/' /etc/login.defs

# Ensure SHA512 is used for password encryption
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
else
    echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
fi

# Part 2: Disable password and shell for system accounts (except 'sync')
while IFS=: read -r username _ uid _ _ _ shell; do
    if [ "$uid" -ge 1 ] && [ "$uid" -le 999 ] && [ "$username" != "sync" ]; then
        sudo passwd -l "$username"
        sudo sed -i '/'^$username'/ s#'$shell'#/bin/nologin#' /etc/passwd
    fi
done < /etc/passwd

# Part 3: Change passwords for all users except the currently logged-in user
current_user=$(logname)
new_password="ThisIsASecurePassword12345!"

while IFS=: read -r username _ uid _ _ _ _; do
    if ([ "$uid" -eq 0 ] || ([ "$uid" -ge 1000 ] && [ "$uid" -le 2000 ])) && [ "$username" != "$current_user" ]; then
        echo "Changing password for $username (UID: $uid)"
        echo "$username:$new_password" | sudo chpasswd
    fi
done < /etc/passwd

# Part 4: Set individual user login settings (min, max, warn ages)
min_uid=1000
max_uid=2000
while IFS=: read -r username _ uid _ _ _ _; do
    if [ "$uid" -eq 0 ] || ([ "$uid" -ge "$min_uid" ] && [ "$uid" -le "$max_uid" ]); then
        sudo sed -i '/'^$username':/ s/\([^:]*:[^:]*:[^:]*:\)[^:]*:[^:]*:[^:]*:\([^:]*\)/\17:90:14:\2/' /etc/shadow
    fi
done < /etc/passwd

# Part 5: Configure PAM settings for password strength and lockout policies
# Install necessary packages

# Ask if APT is functioning on this system
if ! dpkg -s apt &> /dev/null; then
    echo "APT is not functioning on this system."
    exit 1
fi

apt-get install libpam-pwquality -y
apt-get install --reinstall libpam-modules -y

# Configure pam_pwquality for password strength
# Including checks similar to gecos and dictcheck, with additional complexity rules
sed -i '/pam_pwquality.so/ s/$/ retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=3 maxrepeat=2 enforce_for_root gecoscheck=1 dictcheck=1/' /etc/pam.d/common-password

# Configure pam_unix for secure password hashing and password history
sed -i '/pam_unix.so/ s/$/ rounds=8000 shadow remember=7/' /etc/pam.d/common-password

# Configure account lockout policy
echo "auth required pam_tally2.so audit silent deny=5 unlock_time=900" >> /etc/pam.d/common-auth

# Disable null password authentication
sed -i '/nullok/d' /etc/pam.d/common-auth
sed -i '/nullok/d' /etc/pam.d/common-password

# Part 6: Session Timeout for Inactive Users
sed -i '/TMOUT/d' /etc/profile
echo "TMOUT=300" >> /etc/profile
echo "readonly TMOUT" >> /etc/profile
echo "export TMOUT" >> /etc/profile

# Part 7: Configure Secure umask for Default Permissions
sed -i '/umask/d' /etc/profile
echo "umask 027" >> /etc/profile

# Part 8: Audit Logins and Login Failures
echo "auth required pam_tally2.so file=/var/log/tallylog deny=5 even_deny_root unlock_time=900" >> /etc/pam.d/common-auth
