#!/bin/bash
apt update && apt install -y fail2ban logwatch

# Configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Modify specific options in jail.local
echo -e "[sshd]\nenabled = true\nport = 3022\nfilter = sshd\nmaxretry = 5\nbantime = 2h" >> /etc/fail2ban/jail.local

LOGWATCH_CONF="/etc/logwatch/conf/logwatch.conf"
# Specify the discord channel ID as well on the webhook
DISCORD="https://discord.com/api/webhooks/xxx"

# Logwatch alerts on discord
cat <<EOF > $LOGWATCH_CONF
MailTo = $DISCORD
mailer = "sendmail -t"
Format = html
Output = stdout
MailFrom = logwatch@$HOSTNAME
MailSubject = Logwatch en servidor $HOSTNAME
Threshold = 2
EOF

# Test webhook
curl -H "Content-Type: application/json" -d '{"content":"Logwatch configurado correctamente"}' $DISCORD

# Add to crontab
$LOGWATCH_CRON

systemctl enable fail2ban && systemctl start fail2ban
systemctl enable logwatch && systemctl start logwatch
