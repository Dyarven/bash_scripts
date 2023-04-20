#!/bin/bash
apt update && apt install -y fail2ban logwatch

#configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i '/\[sshd\]/a enabled = true' /etc/fail2ban/jail.local
sed -i '/\[sshd\]/a port = 3022' /etc/fail2ban/jail.local
sed -i '/\[sshd\]/a filter = sshd' /etc/fail2ban/jail.local
sed -i '/\[sshd\]/a maxretry = 5' /etc/fail2ban/jail.local
sed -i '/\[sshd\]/a bantime = 2h' /etc/fail2ban/jail.local

LOGWATCH_CONF="/etc/logwatch/conf/logwatch.conf"
LOGWATCH_CRON="/etc/cron.daily/00logwatch"
#specify the discord channel ID as well on the webhook
DISCORD="https://discord.com/api/webhooks/xxx"

#logwatch alerts on discord
sed -i "s/^MailTo.*/MailTo = /" $LOGWATCH_CONF
sed -i "/^mailer =/a Format = html" $LOGWATCH_CONF
sed -i "/^mailer =/a Output = stdout" $LOGWATCH_CONF
sed -i "/^mailer =/a MailFrom = logwatch@$HOSTNAME" $LOGWATCH_CONF
sed -i "/^mailer =/a MailSubject = Logwatch en servidor $HOSTNAME" $LOGWATCH_CONF
echo "MailTo = $DISCORD" >> $LOGWATCH_CONF

#test webhook
curl -H "Content-Type: application/json" -d '{"content":"Logwatch configurado correctamente"}' $DISCORD

#add to crontab
$LOGWATCH_CRON

systemctl enable fail2ban && systemctl start fail2ban
systemctl enable logwatch && systemctl start logwatch


