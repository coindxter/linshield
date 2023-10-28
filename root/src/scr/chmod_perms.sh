chown root:root /boot/grub/grub.cfg 
chmod u-wx,go-rwx /boot/grub/grub.cfg
chown root:root $(readlink -e /etc/issue) 
chmod u-x,go-wx $(readlink -e /etc/issue)
chown root:root $(readlink -e /etc/issue.net) 
chmod u-x,go-wx $(readlink -e /etc/issue.net)
chown root:root /etc/crontab 
chmod og-rwx /etc/crontab 
chown root:root /etc/cron.hourly/ 
chmod og-rwx /etc/cron.hourly/
chown root:root /etc/cron.daily/ 
chmod og-rwx /etc/cron.daily/ 
chown root:root /etc/cron.weekly/ 
chmod og-rwx /etc/cron.weekly/
chown root:root /etc/cron.monthly/ 
chmod og-rwx /etc/cron.monthly/
chown root:root /etc/cron.d/ 
chmod og-rwx /etc/cron.d/
rm /etc/cron.deny
touch /etc/cron.allow
chmod g-wx,o-rwx /etc/cron.allow 
chown root:root /etc/cron.allow


