#!/bin/bash
apt update && apt install -y fail2ban logwatch

#configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl start fail2ban
systemctl enable fail2ban

LOGWATCH_CONF="/etc/logwatch/conf/logwatch.conf"
LOGWATCH_CRON="/etc/cron.daily/00logwatch"
#specify the discord channel ID as well on the webhook
DISCORD="https://discord.com/api/webhooks/YOUR_DISCORD_WEBHOOK_URL_HERE"

#logwatch alerts on discord
sed -i "s/^MailTo.*/MailTo = /" $LOGWATCH_CONF
sed -i "/^mailer =/a Format = html" $LOGWATCH_CONF
sed -i "/^mailer =/a Output = stdout" $LOGWATCH_CONF
sed -i "/^mailer =/a MailFrom = logwatch@$HOSTNAME" $LOGWATCH_CONF
sed -i "/^mailer =/a MailSubject = Logwatch for $HOSTNAME" $LOGWATCH_CONF
echo "MailTo = $DISCORD" >> $LOGWATCH_CONFIG

#test webhook
curl -H "Content-Type: application/json" -d '{"content":"Logwatch configurado correctamente"}' $DISCORD

#add to crontab
$LOGWATCH_CRON

systemctl restart fail2ban
systemctl restart logwatch
