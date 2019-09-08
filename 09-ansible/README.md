* [nginx.yml](nginx.yml) - playbook ansible с использованием роли
* [roles/nginx](roles/nginx) - роль ansible. Установка и настройка nginx

Playbook запускается автоматически через provision в Vagrantfile.

Параметры по умолчанию задаются в roles/nginx/defaults, при необходимости их  
можно переопределить в roles/nginx/vars, например порт 8080.
