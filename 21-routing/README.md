
### cхема стенда

Для работы ansible на хост системе необходимо наличие модуля python3-netaddr.  
Конфигурационные файлы zebra.conf и ospfd.conf формируются из шаблонов на основе описания в Vagrantfile.



       172.16.0.1/24                         172.16.1.1/24
      +-------------+         linkAB        +-------------+
      |             |1   192.168.255.0/30  2|             |
      |   routerA   +-----------------------+   routerB   |
      |             |cost10           cost10|             |
      +--------+----+                       +----+--------+
              10\                               /5
          cost20 \                             /cost 10
                  \                           /
                   \                         /
                    \                       /
                     \                     /
                      \                   /
           linkCA      \                 /   linkBC
      192.168.255.8/30  \               /192.168.255.4/30
                         \             /
                          \           /
                    cost10 \         /cost20
                          9 \       /6
                         +---+-----+---+
                         |             |
                         |   routerC   |
                         |             |
                         +-------------+
                          172.16.2.1/24


### Асимметричный роутинг

У линка linkCA на роутере routerA и у линка linkBC на роутере routerC увеличены стоимости (ip ospf cost 20)  
 для создания асимметричного роутинга.

На всех интерфейсах отключен rp_filter для работы асимметричного роутинга.


Видно, что маршрут на routerA в сторону routerC 192.168.255.6 идёт через routerB (192.168.255.4/30 via 192.168.255.2)

    [root@routerA ~]# ip r
    default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    172.16.0.0/24 dev eth3 proto kernel scope link src 172.16.0.1 metric 103 
    172.16.1.0/24 via 192.168.255.2 dev eth1 proto zebra metric 20 
    172.16.2.0/24 proto zebra metric 30 
	    nexthop via 192.168.255.9 dev eth2 weight 1 
	    nexthop via 192.168.255.2 dev eth1 weight 1 
    192.168.255.0/30 dev eth1 proto kernel scope link src 192.168.255.1 metric 101 
    192.168.255.4/30 via 192.168.255.2 dev eth1 proto zebra metric 20 
    192.168.255.8/30 dev eth2 proto kernel scope link src 192.168.255.10 metric 102 

    [root@routerA ~]# tracepath 192.168.255.6
     1?: [LOCALHOST]                                         pmtu 1500
     1:  192.168.255.2                                         0.670ms 
     1:  192.168.255.2                                         1.259ms 
     2:  192.168.255.6                                         1.072ms reached
	 Resume: pmtu 1500 hops 2 back 1 



Маршрут на routerС в сторону routerA 192.168.255.1 идёт через routerA (192.168.255.0/30 via 192.168.255.10)

    [root@routerC ~]# ip r
    default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    172.16.0.0/24 via 192.168.255.10 dev eth2 proto zebra metric 20 
    172.16.1.0/24 proto zebra metric 30 
	    nexthop via 192.168.255.5 dev eth1 weight 1 
	    nexthop via 192.168.255.10 dev eth2 weight 1 
    172.16.2.0/24 dev eth3 proto kernel scope link src 172.16.2.1 metric 103 
    192.168.255.0/30 via 192.168.255.10 dev eth2 proto zebra metric 20 
    192.168.255.4/30 dev eth1 proto kernel scope link src 192.168.255.6 metric 101 
    192.168.255.8/30 dev eth2 proto kernel scope link src 192.168.255.9 metric 102 


    [root@routerC ~]# tracepath -n 192.168.255.1
     1?: [LOCALHOST]                                         pmtu 1500
     1:  192.168.255.1                                         1.003ms reached
     1:  192.168.255.1                                         0.750ms reached
	 Resume: pmtu 1500 hops 1 back 1 


### Cимметричный роутинг

Для создания симметричного роутинга изменим стоимости на интерфейсах routerC,  
linkBC cost 10, linkCA cost 20:

    routerC# conf t
    routerC(config)# interface eth1
    routerC(config-if)# ip ospf cost 10
    routerC(config-if)# interface eth2
    routerC(config-if)# ip ospf cost 20
    routerC(config-if)# 


Маршрут на routerС в сторону routerA 192.168.255.1 идёт через routerB (192.168.255.0/30 via 192.168.255.5)

    [root@routerC ~]# ip r
    default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    172.16.0.0/24 proto zebra metric 30 
	    nexthop via 192.168.255.10 dev eth2 weight 1 
	    nexthop via 192.168.255.5 dev eth1 weight 1 
    172.16.1.0/24 via 192.168.255.5 dev eth1 proto zebra metric 20 
    172.16.2.0/24 dev eth3 proto kernel scope link src 172.16.2.1 metric 103 
    192.168.255.0/30 via 192.168.255.5 dev eth1 proto zebra metric 20 
    192.168.255.4/30 dev eth1 proto kernel scope link src 192.168.255.6 metric 101 
    192.168.255.8/30 dev eth2 proto kernel scope link src 192.168.255.9 metric 102 

    [root@routerC ~]# tracepath -n 192.168.255.1
     1?: [LOCALHOST]                                         pmtu 1500
     1:  192.168.255.5                                         1.000ms 
     1:  192.168.255.5                                         0.528ms 
     2:  192.168.255.1                                         0.880ms reached
	 Resume: pmtu 1500 hops 2 back 2 

