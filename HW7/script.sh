sudo su
echo 'WORD="failed"
LOG=/var/log/watchlog.log' >> /etc/sysconfig/watchlog
touch /var/log/watchlog.log
echo 'failed
done
done
open
failed' >> /var/log/watchlog.log
touch /opt/watchlog.sh 
chmod +x /opt/watchlog.sh 
echo '#!/bin/bash
WORD=failed
LOG=/var/log/watchlog.log
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi' >> /opt/watchlog.sh
touch /etc/systemd/system/watchlog.service
echo '[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG' >> /etc/systemd/system/watchlog.service
touch /etc/systemd/system/watchlog.timer
echo '
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target' >> /etc/systemd/system/watchlog.timer
systemctl start watchlog.service
tail -n 10 /var/log/messages
echo ============================================================================
echo 'watchlog done! Continue! ^_^'
echo ============================================================================
sleep 5
yum install wget httpd -y
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sed -i 's:/etc/sysconfig/httpd:/etc/sysconfig/httpd-%I:' /etc/systemd/system/httpd@.service
touch /etc/sysconfig/httpd-first
echo 'OPTIONS=-f conf/first.conf' >> /etc/sysconfig/httpd-first
touch /etc/sysconfig/httpd-second
echo 'OPTIONS=-f conf/second.conf' >> /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's:Listen 80:Listen 8080:' /etc/httpd/conf/second.conf
echo PidFile /var/run/httpd-second.pid >> /etc/httpd/conf/second.conf
systemctl daemon-reload 
systemctl start httpd@first
systemctl start httpd@second
ss -tnulp | grep httpd
echo ============================================================================
echo 'httpd done! Continue! ^_^'
echo ============================================================================
sleep 5
yum install -y fontconfig java wget
wget с --progress=bar:force https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-4.7.1.tar.gz
mkdir /opt/atlassian/
tar -xf atlassian-servicedesk-4.7.1.tar.gz
mv atlassian-jira-servicedesk-4.7.1-standalone/ /opt/atlassian/jira/
useradd jira
chown -R jira /opt/atlassian/jira/
chmod -R u=rwx,go-rwx /opt/atlassian/jira/
mkdir /home/jira/jirasoftware-home
chown -R jira /home/jira/jirasoftware-home
chmod -R u=rwx,go-rwx /home/jira/jirasoftware-home
touch /lib/systemd/system/jira.service
chmod 664 /lib/systemd/system/jira.service
echo '[Unit] 
Description=Atlassian Jira
After=network.target
[Service] 
Type=forking
User=jira
PIDFile=/opt/atlassian/jira/work/catalina.pid
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
MemoryLimit=100M
TasksMax=15
CPUQuota=30%
Slice=user-1000.slice
Restart=always
[Install] 
WantedBy=multi-user.target' >> /lib/systemd/system/jira.service
systemctl daemon-reload
systemctl enable jira.service
systemctl start jira.service
systemctl status jira.service
echo ============================================================================
echo 'All work done! ^_^'
echo ============================================================================
