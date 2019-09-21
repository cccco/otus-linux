* [aaa.yml](aaa.yml) - playbook ansible с ролями pam_exec_ssh и sudoers
* [roles/pam_exec_ssh](roles/pam_exec_ssh) - роль ansible. Настройка модуля pam_exec.so для sshd,  
    добавление bash скрипта проверки группы пользователя и дней надели из шаблона.  
    Группа и дни недели задаются в переменных роли.
* [roles/sudoers](roles/sudoers) - роль ansible. Добавление пользователей в sudoers без необходимости ввода пароля  
    Пользователи задаются в переменных роли.

Playbook запускается автоматически через provision в Vagrantfile.
