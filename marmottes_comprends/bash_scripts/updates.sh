# Ubuntu Operating System Updates Script
# By: Eoin Shearer
# Build: 08,19,24

# Check automatically for updates daily
sudo dpkg-reconfigure -plow unattended-upgrades
# Install updates from important security updates
sudo unattended-upgrades --dry-run --debug
# update bash
sudo apt-get install --only-upgrade bash
# update openssl
sudo apt-get install --only-upgrade openssl
# update glibc
sudo apt-get install --only-upgrade glibc
# update busybox
sudo apt-get install --only-upgrade busybox
# update 7zip
sudo apt-get install --only-upgrade p7zip
# update apache2
sudo apt-get install --only-upgrade apache2
# update nginx
sudo apt-get install --only-upgrade nginx
# update bluefish
sudo apt-get install --only-upgrade bluefish
# update bind9
sudo apt-get install --only-upgrade bind9
# update bind9utils
sudo apt-get install --only-upgrade bind9utils
# update FileZilla
sudo apt-get install --only-upgrade filezilla
# update Firefox
sudo apt-get install --only-upgrade firefox
# update GIMP
sudo apt-get install --only-upgrade gimp
# update icewweasel
sudo apt-get install --only-upgrade iceweasel
# update LibreOffice
sudo apt-get install --only-upgrade libreoffice
# update openssh
sudo apt-get install --only-upgrade openssh
# update php
sudo apt-get install --only-upgrade php
# update php5
sudo apt-get install --only-upgrade php5
# update postgreSQL
sudo apt-get install --only-upgrade postgresql
# update ProFTP daemon
sudo apt-get install --only-upgrade proftpd
# update PureFTP
sudo apt-get install --only-upgrade pure-ftpd
# update Samba
sudo apt-get install --only-upgrade samba
# update Thunderbird
sudo apt-get install --only-upgrade thunderbird
# update Tilda
sudo apt-get install --only-upgrade tilda
# update vsftpd
sudo apt-get install --only-upgrade vsftpd
# update wordpress
sudo apt-get install --only-upgrade wordpress