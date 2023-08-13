systemctl unmask ufw.service
systemctl --now enable ufw.service
ufw enable
ufw allow in on lo 
ufw allow out on lo 
ufw deny in from 127.0.0.0/8 
ufw deny in from ::1
ufw allow out on all
ufw default deny incoming 
ufw default allow outgoing 
ufw default deny routed
