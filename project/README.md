### Кластер Consul с функциями обнаружения и проверки работоспособности сервисов, интегрированный с отказоустойчивым рекурсивным DNS на основе bind и keepalived.

### Описание стенда

Основная часть стенда состоит из пяти ВМ:  

ns1.otuslab.ru - master сервер bind, узел keepalived  
ns2.otuslab.ru - slave сервер bind, узел keepalived  
cl1.otuslab.ru - сервер кластера Consul  
cl2.otuslab.ru - сервер кластера Consul  
cl3.otuslab.ru - сервер кластера Consul  

Дополнительно в стенде используются две ВМ для демонстрации  
функций Service Discovery и Health Checking Consul:  

srv1.otuslab.ru - сервер Nginx и PostgreSQL  
srv2.otuslab.ru - сервер Nginx и PostgreSQL  

### DNS

### Consul кластер

### Service Discovery и Health Checking
