
Стенд с сервером и клиентом bacula разворачивается автоматически с помощью Vagrant Ansible Provisioner.

На сервере настроены bacula-dir с политикой бэкапа директории /etc с клиента  
и bacula-sd, на клиенте bacula-fd.

### Конфигурациионные файлы, сформированные из шаблонов ansible:

* [bacula-dir.conf](result/bacula-dir.conf) - Bacula Director
* [bacula-sd.conf](result/bacula-sd.conf) - Bacula Storage Daemon
* [bconsole.conf](result/bconsole.conf) - Bacula Console
* [bacula-fd.conf](result/bacula-fd.conf) - Bacula File Daemon

### Список заданий

    *list jobs
    +-------+---------------+---------------------+------+-------+----------+------------+-----------+
    | jobid | name          | starttime           | type | level | jobfiles | jobbytes   | jobstatus |
    +-------+---------------+---------------------+------+-------+----------+------------+-----------+
    |     1 | backup client | 2019-10-01 15:35:35 | B    | F     |    2,392 | 27,190,395 | T         |
    |     2 | backup client | 2019-10-01 15:45:02 | B    | I     |        2 |      1,747 | T         |
    |     3 | backup client | 2019-10-01 15:55:02 | B    | I     |        0 |          0 | T         |
    |     4 | backup client | 2019-10-01 16:00:02 | B    | D     |        2 |      1,747 | T         |
    |     5 | backup client | 2019-10-01 16:05:02 | B    | I     |        0 |          0 | T         |
    |     6 | backup client | 2019-10-01 16:15:02 | B    | I     |        0 |          0 | T         |
    |     7 | backup client | 2019-10-01 16:25:02 | B    | I     |        0 |          0 | T         |
    |     8 | backup client | 2019-10-01 16:30:02 | B    | D     |        2 |      1,747 | T         |
    |     9 | backup client | 2019-10-01 16:35:02 | B    | I     |        0 |          0 | T         |
    |    10 | backup client | 2019-10-01 16:45:02 | B    | I     |        0 |          0 | T         |
    |    11 | backup client | 2019-10-01 16:55:02 | B    | I     |        2 |      4,096 | T         |
    |    12 | backup client | 2019-10-01 17:00:02 | B    | D     |        6 |      5,513 | T         |
    |    13 | backup client | 2019-10-01 17:05:02 | B    | I     |        0 |          0 | T         |
    |    14 | backup client | 2019-10-01 17:15:02 | B    | I     |        0 |          0 | T         |
    |    15 | backup client | 2019-10-01 17:25:02 | B    | I     |        0 |          0 | T         |
    |    16 | backup client | 2019-10-01 17:30:02 | B    | D     |        6 |      5,513 | T         |
    |    17 | backup client | 2019-10-01 17:35:02 | B    | I     |        2 |      1,665 | T         |
    |    18 | backup client | 2019-10-01 17:45:02 | B    | I     |        0 |          0 | T         |
    +-------+---------------+---------------------+------+-------+----------+------------+-----------+



### Список файлов в задании

    *list files jobid=12
    +--------------------------+
    | filename                 |
    +--------------------------+
    | /etc/rsyslog.conf        |
    | /etc/                    |
    | /etc/rsyncd.conf         |
    | /etc/nsswitch.conf       |
    | /etc/sysconfig/firewalld |
    | /etc/sysconfig/          |
    +--------------------------+
