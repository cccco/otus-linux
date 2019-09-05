* [provision.sh](provision.sh) - shell provisioning

Заменить строку /etc/sysconfig/httpd на /etc/sysconfig/httpd-%I в файле /usr/lib/systemd/system/httpd.service  
Переименовать unit файл httpd.service в httpd@.service  

Создать файлы /etc/sysconfig/httpd-first и /etc/sysconfig/httpd-second  
с OPTIONS="-f conf/httpd-first.conf" и OPTIONS="-f conf/httpd-second.conf"  

Создать файлы /etc/httpd/conf/httpd-first.conf и /etc/httpd/conf/httpd-second.conf  
В /etc/httpd/conf/httpd-second.conf добавить опцию "PidFile /var/run/httpd-second.pid"  
и изменить порт на 8080 (Listen 8080)

Запустить два сервера httpd:

    systemctl start httpd@first
    systemctl start httpd@second

Результат запуска:

    ss -tnlp | grep httpd
    LISTEN     0      128         :::8080                    :::*                   users:(("httpd",pid=4002,fd=4),("httpd",pid=4001,fd=4),("httpd",pid=4000,fd=4),("httpd",pid=3999,fd=4),("httpd",pid=3998,fd=4),("httpd",pid=3997,fd=4))
    LISTEN     0      128         :::80                      :::*                   users:(("httpd",pid=3995,fd=4),("httpd",pid=3994,fd=4),("httpd",pid=3993,fd=4),("httpd",pid=3992,fd=4),("httpd",pid=3991,fd=4),("httpd",pid=3990,fd=4))
