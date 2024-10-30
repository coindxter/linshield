# Ubuntu Account Policies Script
# By: Eoin Shearer
# Build: 08,19,24

# Disable Guest account 
sudo sh -c 'echo "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
# Set Root password to 'sigmasauce'
echo -e "sigmasauce\nsigmasauce" | sudo passwd root
# Hash passwords with SHA-512
sudo authconfig --passalgo=sha512 --update
# Set maximum password age to 90 days
sudo chage --maxdays 90 root
# Set minimum password age to 7 days
sudo chage --mindays 7 root
# Set prevoius passwords to be remembered to 5
sudo chage --remember 5 root
# Add dictonary based strength check
sudo sh -c 'echo "password requisite pam_pwquality.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=4" >> /etc/pam.d/common-password'
# Non-dictionary based strength check
sudo sh -c 'echo "password requisite pam_cracklib.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=4" >> /etc/pam.d/common-password'
# GECOS password checks 
sudo sh -c 'echo "password requisite pam_unix.so remember=5 use_authtok sha512 shadow" >> /etc/pam.d/common-password'
# Set password expiration warning to 14 days
sudo chage --warndays 14 root
# Set password inactive to 7 days
sudo chage --inactive 7 root
# Set password lockout to 5 attempts
sudo pam_tally2 -u root -r 5
# Null Passwords don't authenticate
sudo sh -c 'echo "nullok_secure" >> /etc/pam.d/common-auth'
# Null Passwords don't authenticate on insecure consoles
sudo sh -c 'echo "nullok_secure" >> /etc/pam.d/common-auth'
# Configure account lockout policy
sudo sh -c 'echo "auth required pam_tally2.so deny=5 unlock_time=1200 onerr=fail audit even_deny_root" >> /etc/pam.d/common-auth'
# Greeter does not enumerate user accounts
sudo sh -c 'echo "greeter-hide-users=true" >> /etc/lightdm/lightdm.conf.d/50-no-guest.conf'