# Enable UFW
sudo ufw enable
# Remove UFW past configurations
sudo ufw reset
# Set default incoming policy to deny
sudo ufw default deny incoming
# Set default outgoing policy to allow
sudo ufw default allow outgoing
# AppArmor enabled
sudo aa-enforce /etc/apparmor.d/*
# Fail2Ban enabled
sudo systemctl enable fail2ban && sudo systemctl start fail2ban
