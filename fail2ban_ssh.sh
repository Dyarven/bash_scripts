#!/bin/bash
apt update && apt install -y fail2ban logwatch

# Configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Modify specific options in jail.local
echo -e "[sshd]\nenabled = true\nport = 3022\nfilter = sshd\nmaxretry = 5\nbantime = 2h" >> /etc/fail2ban/jail.local

systemctl enable fail2ban && systemctl start fail2ban

# Keepalive
echo -e "#!/bin/bash\nsystemctl is-active --quiet fail2ban || systemctl restart fail2ban" > /root/scripts/restart_fail2ban.sh
chmod +x /root/scripts/restart_fail2ban.sh
(crontab -l 2>/dev/null; echo "0 2 * * * /root/scripts/restart_fail2ban.sh") | crontab -


