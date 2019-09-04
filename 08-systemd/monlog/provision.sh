#!/usr/bin/env bash

cp /vagrant/monlog.service /vagrant/monlog.timer /usr/lib/systemd/system/
cp /vagrant/monlog.sysconfig /etc/sysconfig/monlog

systemctl enable monlog.timer
systemctl start monlog.timer
