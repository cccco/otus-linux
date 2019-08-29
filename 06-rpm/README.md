* [proc-bash-utils.spec](proc-bash-utils.spec) - spec файл для создания пакета rpm с bash скриптами ps-ax.sh и lsof.sh
* [simple.repo](simple.repo) - конфигурационный файл репозитория "simple"
* [Dockerfile](Dockerfile) - Dockerfile для создания образа с добавленными bash скриптами ps-ax.sh и lsof.sh


Создание rpm-пакета:  
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}  
    cp /vagrant/proc-bash-utils.spec ~/rpmbuild/SPECS/  
    rpmbuild -ba ~/rpmbuild/SPECS/proc-bash-utils.spec  

Настройка репозитория:  
    mkdir -p /usr/share/nginx/html/repos/simple  
    cp /home/vagrant/rpmbuild/RPMS/noarch/proc-bash-utils-0-1.el7.centos.noarch.rpm /usr/share/nginx/html/repos/simple
    createrepo /usr/share/nginx/html/repos/simple
    cp /vagrant/simple.repo /etc/yum.repos.d/

Необходимо поправить конфигурационный файл /etc/nginx/nginx.conf, добавить опцию "autoindex on;" в секцию location /
и запустить nginx:  
    systemctl start nginx


Репозиторий "simple" появится в списке доступных:  
    [root@rpm ~]# yum repolist
    Loaded plugins: fastestmirror
    Loading mirror speeds from cached hostfile
    * base: mirror.sale-dedic.com
    * epel: mirror.datacenter.by
    * extras: mirror.reconn.ru
    * updates: mirror.docker.ru
    repo id                       repo name                                                    status
    base/7/x86_64                 CentOS-7 - Base                                              10,019
    epel/x86_64                   Extra Packages for Enterprise Linux 7 - x86_64               13,367
    extras/7/x86_64               CentOS-7 - Extras                                               435
    simple                       sipmle repo                                                       1
    updates/7/x86_64              CentOS-7 - Updates                                            2,500
    repolist: 26,322


Создание docker образа  

Запустить docker:  
    systemctl start docker

Перейти в каталог /vagrant, в котором находится Dockerfile, создать образ:  
    docker pull centos  
    docker build -t centos:a1 .  


Вывод команды запуска контейнера:  
    [root@rpm docker]# docker run -t -i centos:a1
    PID TTY      STAT   TIME COMMAND
      1 pts/1    Ss+    0:00 bash /usr/bin/ps-ax.sh 
      7 ?        S      0:00 bash /usr/bin/ps-ax.sh 
      8 ?        S      0:00 bash /usr/bin/ps-ax.sh 
      9 ?        S      0:00 bash /usr/bin/ps-ax.sh
