
Стенд с сервером и клиентом bacula разворачивается автоматически с помощью Vagrant Ansible Provisioner.

На сервере настроены bacula-dir с политикой бэкапа директории /etc с клиента  
и bacula-sd, на клиенте bacula-fd.

### Конфигурациионные файлы, сформированные из шаблонов ansible:

* [bacula-dir.conf](result/bacula-dir.conf) - Bacula Director
* [bacula-sd.conf](result/bacula-sd.conf) - Bacula Storage Daemon
* [bconsole.conf](result/bconsole.conf) - Bacula Console
* [bacula-fd.conf](result/bacula-fd.conf) - Bacula File Daemon

### список заданий


### список файлов в задании
