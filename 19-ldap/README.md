Стенд с сервером и клиентом FreeIPA разворачивается автоматически с помощью Vagrant Ansible Provisioner.


### Роль ipa-server
* [ipa-server](roles/ipa-server)

Устанавливает и настраивает FreeIPA сервер, формирует файл /etc/hosts.



### Роль ipa-client
* [ipa-client](roles/ipa-client)

Устанавливает и настраивает FreeIPA клиент, формирует файл /etc/hosts.
Задача [ipa-user-create](roles/ipa-client/tasks/ipa-user-create.yml) генерирует rsa ключи, добавляет тестового пользователя.



Проверка авторизации по ssh-ключу тестового пользователя:

    [root@client ~]# ssh -i ~/.ssh/id_rsa_jonh_smith john.smith@server.example.local
    Creating home directory for john.smith.
    -sh-4.2$ id
    uid=323600001(john.smith) gid=323600001(john.smith) groups=323600001(john.smith) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
    -sh-4.2$

