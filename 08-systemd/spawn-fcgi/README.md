* [provision.sh](provision.sh) - shell provisioning
* [spawn-fcgi.service](spawn-fcgi.service) - unit файл spawn-fcgi

Раскомментировать опции SOCKET и OPTIONS в файле /etc/sysconfig/spawn-fcgi  
Установить unit файл spawn-fcgi.service

    cp /vagrant/spawn-fcgi.service /usr/lib/systemd/system/
    systemctl enable spawn-fcgi

Запустить spawn-fcgi

    systemctl start spawn-fcgi
