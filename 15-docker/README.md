
### Сборка образов nginx и php-fpm

* [Dockerfile](docker/nginx/Dockerfile) - Dockerfile образа nginx
* [Dockerfile](docker/php/Dockerfile) - Dockerfile образа php-fpm

Каталоги docker/log и docker/www используются как постоянные хранилища для контейнеров.

#### nginx

Собрать образ nginx на основе alpine:

    cd /vagrant/docker/nginx
    docker build -t nginx .

Запустить контейнер для проверки можно командой:

    docker run --rm -p 80:80 -p 443:443 -d -v /vagrant/docker/log:/var/log/nginx:z -v /vagrant/docker/www:/www:z nginx

#### php-fpm

Собрать образ php-fpm на основе alpine:

    cd /vagrant/docker/php
    docker build -t php .

Запустить контейнер для проверки можно командой:

    docker run --rm -p 9000:9000 -d -v /vagrant/docker/www:/www:z nginx


### Загрузка образов на Docker Hub

Вывести список локальных образов:

    docker images

Назначить теги локальным образам:

    docker tag 99025b6bfd52 halaram/nginx
    docker tag b27d8dd457a9 halaram/php-fpm

Загрузить образы на Docker Hub:

    docker login --username=halaram
    docker push halaram/nginx
    docker push halaram/php-fpm

Cсылка на репозиторий Docker Hub - https://hub.docker.com/u/halaram/

### Docker Compose

* [docker-compose.yml](docker/docker-compose.yml) - файл docker-compose

С помощью docker-compose c использованием образов на Docker Hub
запускаются контейнеры при старте vagrant:

    docker-compose -f /vagrant/docker/docker-compose.yml up -d


Посмотреть результат(php info) можно по адресу http://192.168.11.101/



###
Определите разницу между контейнером и образом:

Образ это набор слоёв, доступных только для чтения.
Контейнер это изолированное пространство процессов с добавленным сверху слоем, доступным для записи.

Можно ли в контейнере собрать ядро?

Да.
