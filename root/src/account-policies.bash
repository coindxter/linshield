# Create the directory for LightDM configuration if it does not exist
sudo mkdir -p /etc/lightdm/lightdm.conf.d/
# Disable Guest account
sudo sh -c 'echo "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
# Set Root password (use a strong password)
echo "root:Student123!" | sudo chpasswd
# Ensure SHA-512 is used for password hashing
sudo sed -i 's/^password.*pam_unix.so/password    [success=1 default=ignore]    pam_unix.so sha512/' /etc/pam.d/common-password
# Set maximum password age to 90 days
sudo chage --maxdays 90 root
# Set minimum password age to 7 days
sudo chage --mindays 7 root
# Set previous passwords to be remembered to 5
sudo sed -i '/pam_unix.so/ s/$/ remember=5/' /etc/pam.d/common-password
# Add dictionary-based strength check
sudo sh -c 'echo "password requisite pam_pwquality.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=4" >> /etc/pam.d/common-password'
# GECOS password checks (use pam_unix.so with SHA-512 and shadow)
sudo sh -c 'echo "password requisite pam_unix.so remember=5 use_authtok sha512 shadow" >> /etc/pam.d/common-password'
# Set password expiration warning to 14 days
sudo chage --warndays 14 root
# Set password inactive to 7 days
sudo chage --inactive 7 root
# Configure account lockout policy using pam_faillock
sudo sh -c 'echo "auth required pam_faillock.so preauth silent audit deny=5 unlock_time=1200" >> /etc/pam.d/common-auth'
sudo sh -c 'echo "auth required pam_faillock.so authfail audit deny=5 unlock_time=1200" >> /etc/pam.d/common-auth'
# Greeter does not enumerate user accounts
sudo sh -c 'echo "greeter-hide-users=true" >> /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
