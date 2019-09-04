
Список таймеров systemd:

    [root@systemd vagrant]# systemctl list-timers 
    NEXT                         LEFT          LAST                         PASSED   UNIT                         ACTIVATES
    Wed 2019-09-04 17:12:30 UTC  5s ago        Wed 2019-09-04 17:12:35 UTC  53ms ago monlog.timer                 monlog.service
    Wed 2019-09-04 17:15:05 UTC  2min 30s left n/a                          n/a      systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

    2 timers listed.
    Pass --all to see loaded but inactive timers, too.

Статус таймера monlog.timer:

    [root@systemd vagrant]# systemctl status monlog.timer 
    ● monlog.timer - Execute monlog.service every 30 sec
       Loaded: loaded (/usr/lib/systemd/system/monlog.timer; enabled; vendor preset: disabled)
       Active: active (waiting) since Wed 2019-09-04 17:00:53 UTC; 13min ago

    Sep 04 17:00:53 systemd systemd[1]: Started Execute monlog.service every 30 sec.
    Sep 04 17:00:53 systemd systemd[1]: Starting Execute monlog.service every 30 sec.


Часть лога поиска слова в файле, заданных в /etc/sysconfig/monlog (OPTIONS="-f /var/log/messages -w systemd"):

    [root@systemd vagrant]# tail -10 /vagrant/monlog.log 
    word "systemd" found in /var/log/messages: Sep  4 17:11:51 localhost systemd: Starting Monitor log...
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Started Monitor log.
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Starting Monitor log...
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Created slice User Slice of vagrant.
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Starting User Slice of vagrant.
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Started Session 6 of user vagrant.
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd-logind: New session 6 of user vagrant.
    word "systemd" found in /var/log/messages: Sep  4 17:12:20 localhost systemd: Starting Session 6 of user vagrant.
    word "systemd" found in /var/log/messages: Sep  4 17:12:35 localhost systemd: Started Monitor log.
    word "systemd" found in /var/log/messages: Sep  4 17:12:35 localhost systemd: Starting Monitor log..
