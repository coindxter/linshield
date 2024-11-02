# X Server does not allow TCP connections
sudo sh -c 'echo "nolisten tcp" >> /etc/X11/xinit/xserverrc'
# Address space layout randomization enabled
sudo sh -c 'echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf'
# IPv4 TCP SYN cookies enabled
sudo sh -c 'echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf'
# IPv4 TCP SYN,ACK retries reduced
sudo sh -c 'echo "net.ipv4.tcp_synack_retries = 3" >> /etc/sysctl.conf'
# IPv4 TIME-WAIT assassination protection enabled
sudo sh -c 'echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.conf'
# IPv4 forwarding has been disabled
sudo sh -c 'echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf'
# IPv4 sending ICMP redirects disabled
sudo sh -c 'echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf'
# IPv4 accept ICMP redirects disabled
sudo sh -c 'echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf'
# IPv4 accept source routing disabled
sudo sh -c 'echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf'
# IPv4 source route verification enabled
sudo sh -c 'echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf'
# Ignore bogus ICMP errors enabled
sudo sh -c 'echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf'
# Ignore broadcast ICMP echo requests enabled
sudo sh -c 'echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf'
# Kernel pointers hidden from unprivileged users
sudo sh -c 'echo "kernel.kptr_restrict = 1" >> /etc/sysctl.conf'
# Magic SysRq key disabled
sudo sh -c 'echo "kernel.sysrq = 0" >> /etc/sysctl.conf'
# Only root may create new namespaces
sudo sh -c 'echo "kernel.unprivileged_userns_clone = 0" >> /etc/sysctl.conf'
# Restrict unpacking of compressed kernel syslog
sudo sh -c 'echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf'
# Logging of martian packets enabled
sudo sh -c 'echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf'
# Sudo requires a password
sudo sh -c 'echo "Defaults        rootpw" >> /etc/sudoers' && sudo sh -c 'sed -i "/NOPASSWD: ALL/d" /etc/sudoers'