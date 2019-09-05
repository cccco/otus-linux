#!/usr/bin/env bash

yum -y install httpd

sed -i 's/\/etc\/sysconfig\/httpd/\/etc\/sysconfig\/httpd-%I/' /usr/lib/systemd/system/httpd.service
mv /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service

cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
echo 'OPTIONS="-f conf/httpd-first.conf"' >> /etc/sysconfig/httpd-first
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second
echo 'OPTIONS="-f conf/httpd-second.conf"' >> /etc/sysconfig/httpd-second

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-second.conf
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-first.conf
sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd-second.conf
sed -i '/^Listen 8080$/a PidFile \/var\/run\/httpd-second.pid' /etc/httpd/conf/httpd-second.conf

systemctl start httpd@first
systemctl start httpd@second
ss -tnlp | grep httpd
