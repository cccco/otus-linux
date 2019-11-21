
# схема стенда:

                                        |
                                        | uplink
                                        | eth0 nat
                                 +------+------+
                                 | inetRouter  |
                                 +----+---+----+
                                  eth1|   |eth2
                                      |   |
                                      |   |
                                      |   |router-net teaming
                                      |   |192.168.255.0/30
                                      |   |
                                      |   |
                                  eth1|   |eth2
                                 +----+---+----+
                                 |centralRouter|
                                 +------+------+
                                        |eth2
                                        |
                                        |central-router-net
                                        |192.168.255.4/28
                                        |
                                        |eth1
                                 +------+------+
                                 |office1Router|
                                 +----+---+----+
                          netns vrf101|   |netns vrf102
                                      |   |
                                      |   |
                    +-----------------+   +---------------+
                    |                                     |
       10.10.10.2/24|                                     |10.10.10.2/24
           +--------+---------+                  +--------+---------+
           |                  |                  |                  |
    +------+------+    +------+------+    +------+------+    +------+------+
    | testServer1 |    | testClient1 |    | testServer2 |    | testClient2 |
    +----+---+----+    +----+---+----+    +----+---+----+    +----+---+----+



###
    [root@centralRouter ~]# teamdctl team0 state
    setup:
      runner: loadbalance
    ports:
      eth1
	link watches:
	  link summary: up
	  instance[link_watch_0]:
	    name: ethtool
	    link: up
	    down count: 0
       eth2
	 link watches:
	   link summary: up
	   instance[link_watch_0]:
	     name: ethtool
	     link: up
	     down count: 0

    [root@centralRouter ~]# ip link set dev eth2 down

    [root@centralRouter ~]# tracepath -n 8.8.8.8
     1?: [LOCALHOST]                                         pmtu 1500
     1:  192.168.255.1                                         0.791ms 
     1:  192.168.255.1                                         0.495ms 
    ^C

    [root@centralRouter ~]# ping 8.8.8.8
    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=47.8 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=48.1 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=61 time=51.1 ms
    64 bytes from 8.8.8.8: icmp_seq=4 ttl=61 time=48.1 ms
    64 bytes from 8.8.8.8: icmp_seq=5 ttl=61 time=48.1 ms
    ^C
    --- 8.8.8.8 ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4010ms
    rtt min/avg/max/mdev = 47.889/48.703/51.172/1.269 ms

    [root@centralRouter network-scripts]# teamdctl team0 state
    setup:
      runner: loadbalance
    ports:
      eth1
	link watches:
	  link summary: up
	  instance[link_watch_0]:
	    name: ethtool
	    link: up
	    down count: 0
      eth2
	 link watches:
	   link summary: down
	   instance[link_watch_0]:
	   name: ethtool
	   link: down
	   down count: 1

###

    [root@office1Router ~]# ip netns 
    vrf102 (id: 1)
    vrf101 (id: 0)


    [root@office1Router ~]# ip netns exec vrf101 iptables -nL -t nat
    Chain PREROUTING (policy ACCEPT)
    target     prot opt source               destination         
    NETMAP     all  --  0.0.0.0/0            10.10.101.0/24      10.10.10.0/24

    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination         

    Chain OUTPUT (policy ACCEPT)
    target     prot opt source               destination         

    Chain POSTROUTING (policy ACCEPT)
    target     prot opt source               destination         
    NETMAP     all  --  10.10.10.0/24        0.0.0.0/0           10.10.101.0/24



    [root@office1Router ~]# ip netns exec vrf101 ip -4 a
    5: eth2.101@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000 link-netnsid 0
	inet 10.10.10.2/24 scope global eth2.101
	   valid_lft forever preferred_lft forever
    7: veth101@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000 link-netnsid 0
	inet 172.29.101.2/30 scope global veth101
	   valid_lft forever preferred_lft forever 




    [root@office1testServer1 ~]# ip -4 a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
	inet 127.0.0.1/8 scope host lo
	   valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
	inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
	   valid_lft 85577sec preferred_lft 85577sec
    4: eth1.101@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
	inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth1.101
	   valid_lft forever preferred_lft forever



    [root@office1testServer1 ~]# ping 8.8.8.8
    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=55 time=49.7 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=55 time=50.1 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=55 time=61.5 ms
    64 bytes from 8.8.8.8: icmp_seq=4 ttl=55 time=49.6 ms
    64 bytes from 8.8.8.8: icmp_seq=5 ttl=55 time=50.5 ms
    ^C
    --- 8.8.8.8 ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4009ms
    rtt min/avg/max/mdev = 49.692/52.334/61.543/4.614 ms


    [root@office1testServer1 ~]# tracepath -n 8.8.8.8
     1?: [LOCALHOST]                                         pmtu 1500
     1:  10.10.10.2                                            0.739ms 
     1:  10.10.10.2                                            0.452ms 
     2:  172.29.101.1                                          0.447ms 
     3:  192.168.255.5                                         0.888ms 
     4:  192.168.255.1                                         1.268ms 
     ^C


    [root@office1testServer1 ~]# ip r
    default via 10.10.10.2 dev eth1.101 
    default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    10.10.10.0/24 dev eth1.101 proto kernel scope link src 10.10.10.1 metric 400 


    [root@office1testServer1 ~]# ping 10.10.10.254
    PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
    64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.492 ms
    64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.521 ms
    64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.578 ms
    64 bytes from 10.10.10.254: icmp_seq=4 ttl=64 time=0.521 ms
    64 bytes from 10.10.10.254: icmp_seq=5 ttl=64 time=0.571 ms
    ^C
    --- 10.10.10.254 ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4003ms
    rtt min/avg/max/mdev = 0.492/0.536/0.578/0.041 ms

###

    [root@office1testClient2 ~]# ip r
    default via 10.10.10.2 dev eth1.102 
    default via 10.0.2.2 dev eth0 proto dhcp metric 101 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 101 
    10.10.10.0/24 dev eth1.102 proto kernel scope link src 10.10.10.254 metric 400 

    [root@office1testClient2 ~]# tracepath -n 8.8.8.8
     1?: [LOCALHOST]                                         pmtu 1500
     1:  10.10.10.2                                            0.699ms 
     1:  10.10.10.2                                            0.611ms 
     2:  172.29.102.1                                          0.600ms 
     3:  192.168.255.5                                         1.037ms 
     4:  192.168.255.1                                         1.380ms 
    ^C

    [root@office1testClient2 ~]# ping 10.10.10.254
    PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
    64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.021 ms
    64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.058 ms
    64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.058 ms
    64 bytes from 10.10.10.254: icmp_seq=4 ttl=64 time=0.060 ms
    ^C
    --- 10.10.10.254 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 2999ms
    rtt min/avg/max/mdev = 0.021/0.049/0.060/0.017 ms


    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=55 time=50.1 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=55 time=49.3 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=55 time=51.5 ms
    64 bytes from 8.8.8.8: icmp_seq=4 ttl=55 time=49.6 ms
    64 bytes from 8.8.8.8: icmp_seq=5 ttl=55 time=49.1 ms
    ^C
    --- 8.8.8.8 ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4008ms
    rtt min/avg/max/mdev = 49.101/49.955/51.553/0.886 ms
###
