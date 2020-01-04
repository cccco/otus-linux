
Стенд разворачивается автоматически с помощью Vagrant Ansible Provisioner  

На стенде запускаютя tomcat с тестовым приложением sample.war на порту 8080,  
Golang приложение goweb на порту 9990 и ruby sinatra с помощью uWSGI на порту 8002.

Все сервисы проксируются nginx и доступны по ссылкам:

[Golang goweb](http://192.168.11.150/goweb)
[Tomcat sample](http://192.168.11.150/tomcat/sample/)
[Ruby uWSGI](http://192.168.11.150/ruby)
