* [aaa.yml](aaa.yml) - playbook ansible с ролями pam_exec_ssh и sudoers
* [roles/pam_exec_ssh](roles/pam_exec_ssh) - роль ansible
* [roles/sudoers](roles/sudoers) - роль ansible

Playbook запускается автоматически через provision в Vagrantfile.

### Роль pam_exec_ssh

 Использует модули ansible template, pamd, group, user

 Создаёт скрипт /usr/local/bin/test_login.sh из шаблона test_login.sh.j2 в соответсвии с заданными переменными:

    wheel_group: admin
    deny_days: [6,7]

 Добавляет строку "account required pam_exec.so /usr/local/bin/test_login.sh" в файл /etc/pam.d/sshd.  
 Создаёт группу admin и пользователей admin1 и user1.  
 Пользователям, входящим в группу admin, а также пользователю vagrant разрешён логин в любое время, всем остальным запрёщен логин в выходные.  

### Роль sudoers

  Использует модуль ansible lineinfile

  Добавляет пользователей в sudoers без необходимости ввода пароля  
  Пользователи задаются в переменной sudo_users:

    sudo_users: [admin1,admin2]
