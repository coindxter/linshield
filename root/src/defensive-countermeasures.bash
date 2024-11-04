# Enable and reset UFW to ensure a clean slate
sudo ufw reset
sudo ufw enable

# Set default policies for enhanced security
sudo ufw default deny incoming    
sudo ufw default allow outgoing  
sudo ufw default deny routed     

# Allow essential loopback interface traffic
sudo ufw allow in on lo           
sudo ufw allow out on lo

# Prevent spoofing by blocking loopback traffic from external sources
sudo ufw deny in from 127.0.0.0/8 
sudo ufw deny in from ::1         

# Reinforce security with AppArmor
sudo aa-enforce /etc/apparmor.d/*

# Enable and start Fail2Ban for intrusion prevention
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Ensure UFW is enabled at startup and running
sudo systemctl unmask ufw.service
sudo systemctl --now enable ufw.service

# Verify UFW status and active rules for confirmation
sudo ufw status verbose
