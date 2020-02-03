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

Система разрешения имён тестовой зоны otuslab.ru состоит из двух узлов - ns1 и ns2.  
Сервер ns1 работает в роли master, ns2 slave.  
На серверах установлен keepalived, который управляет выделенным ip (VIP) адресом.  
Для проверки доступности bind используется скрипт check_named.sh.  
<pre><code>
[root@ns1 ~]# ip -4 address show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.11.148/24 brd 192.168.11.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet 192.168.11.147/24 scope global secondary eth1
       valid_lft forever preferred_lft forever


[root@ns1 ~]# systemctl stop named.service

[root@ns1 ~]# tail /var/log/messages 
Feb  3 16:19:35 localhost Keepalived_vrrp[7016]: /usr/libexec/keepalived/check_named.sh exited with status 2
...
</code></pre>

При отказе сервера bind на ns1 VIP мигрирует на на ns2:
<pre><code>
[root@ns2 ~]# grep Keepalived_vrrp /var/log/messages
...
Feb  3 16:19:23 localhost Keepalived_vrrp[6903]: VRRP_Instance(VI_1) Transition to MASTER STATE
Feb  3 16:19:24 localhost Keepalived_vrrp[6903]: VRRP_Instance(VI_1) Entering MASTER STATE
Feb  3 16:19:24 localhost Keepalived_vrrp[6903]: VRRP_Instance(VI_1) setting protocol VIPs.
Feb  3 16:19:24 localhost Keepalived_vrrp[6903]: Sending gratuitous ARP on eth1 for 192.168.11.147
...

[root@ns2 ~]# ip -4 address show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.11.149/24 brd 192.168.11.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet 192.168.11.147/24 scope global secondary eth1
       valid_lft forever preferred_lft forever
</code></pre>
В качестве сервера разрешения имён на узлах стенда используется virtual ip адрес  
keepalived.  
Для зоны consul настроена пересылка на кластер Consul.  

### Consul кластер

Кластер состоих из трёх узлов cl1, cl2, cl3.  
Процесс bootstrap кластера происходит автоматически, опция retry_join = cl.otuslab.ru.  
Статус кластера после запуска:  
<pre><code>
[root@cl1 ~]# consul members
Node            Address              Status  Type    Build  Protocol  DC   Segment
cl1.otuslab.ru  192.168.11.153:8301  alive   server  1.6.2  2         dc1  <all>
cl2.otuslab.ru  192.168.11.154:8301  alive   server  1.6.2  2         dc1  <all>
cl3.otuslab.ru  192.168.11.155:8301  alive   server  1.6.2  2         dc1  <all>


[root@cl1 ~]# consul operator raft list-peers
Node            ID                                    Address              State     Voter  RaftProtocol
cl2.otuslab.ru  7d880512-ae07-c98e-c5ca-b7b2c17d0db2  192.168.11.154:8300  leader    true   3
cl1.otuslab.ru  d22ffe8d-f12b-fac2-4468-66b9c46490c9  192.168.11.153:8300  follower  true   3
cl3.otuslab.ru  443f93be-376b-120b-1b6a-456b0c32eb0d  192.168.11.155:8300  follower  true   3
</code></pre>
Для просмотра статуса кластера можно использовать web интерфейс http://cl.otuslab.ru:8500:  
![веб-интерфейс consul](consul_cluster.png)

### Service Discovery и Health Checking
