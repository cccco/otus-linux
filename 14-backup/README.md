
Стенд с сервером и клиентом bacula разворачивается автоматически с помощью Vagrant Ansible Provisioner.

На сервере настроены bacula-dir с политикой бэкапа директории /etc с клиента  
и bacula-sd, на клиенте bacula-fd.

### Конфигурациионные файлы, сформированные из шаблонов ansible:

* [result/bacula-dir.conf](bacula-dir.conf) - Bacula Director
* [result/bacula-sd.conf](bacula-sd.conf) - Bacula Storage Daemon
* [result/bconsole.conf](bconsole.conf) - Bacula Console
* [result/bacula-fd.conf](bacula-fd.conf) - Bacula File Daemon

### список заданий


### список файлов в задании
