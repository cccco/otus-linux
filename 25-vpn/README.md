## схема стенда:


                                   |br0
                                   |192.168.200.100/24
                               +---+---------+
                               |             |
                               |   server    |
                               |             |
                               +------+------+
                                      |eth1
                                      |192.168.254.100/32
                                      |
                                      |int_net
    +-------------+                   |                  +-------------+
    |             |eth1               |              eth1|             |
    |   client1   +-------------------+------------------+   client2   |
    |     tap     |172.16.1.100/32        172.16.2.100/32|     tun     |
    +------+------+                                      +------+------+
           |br0                                                 |br0
           |192.168.200.101/24                                  |192.168.100.101/24

### tun tap


[root@server ~]# ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:8a:fe:e6 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:29:8b:ca brd ff:ff:ff:ff:ff:ff
4: br0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether b6:dc:ef:cd:aa:3d brd ff:ff:ff:ff:ff:ff
5: tap0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UNKNOWN mode DEFAULT group default qlen 100
    link/ether b6:dc:ef:cd:aa:3d brd ff:ff:ff:ff:ff:ff
6: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 100
    link/none 

[root@server server]# ping 192.168.200.101
PING 192.168.200.101 (192.168.200.101) 56(84) bytes of data.
64 bytes from 192.168.200.101: icmp_seq=1 ttl=64 time=2.75 ms
64 bytes from 192.168.200.101: icmp_seq=2 ttl=64 time=1.02 ms
64 bytes from 192.168.200.101: icmp_seq=3 ttl=64 time=1.02 ms
^C
--- 192.168.200.101 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.020/1.598/2.751/0.816 ms



[root@client1 ~]# ping 192.168.200.100
PING 192.168.200.100 (192.168.200.100) 56(84) bytes of data.
64 bytes from 192.168.200.100: icmp_seq=1 ttl=64 time=1.42 ms
64 bytes from 192.168.200.100: icmp_seq=2 ttl=64 time=0.650 ms
64 bytes from 192.168.200.100: icmp_seq=3 ttl=64 time=0.730 ms
^C
--- 192.168.200.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.650/0.933/1.420/0.346 ms

[root@client1 ~]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 101 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 101 
172.16.1.100 dev eth1 proto kernel scope link src 172.16.1.100 metric 100 
192.168.200.0/24 dev br0 proto kernel scope link src 192.168.200.101 metric 425 
192.168.254.100 dev eth1 scope link 


[root@client1 ~]# tracepath -n 192.168.200.100
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.200.100                                       0.705ms reached
 1:  192.168.200.100                                       0.426ms reached
     Resume: pmtu 1500 hops 1 back 1 


[root@client1 ~]# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.ea4737f823bb	no		tap0




[root@client2 ~]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
172.16.2.100 dev eth1 proto kernel scope link src 172.16.2.100 metric 101 
172.29.0.1 dev tun0 proto kernel scope link src 172.29.0.2 
192.168.100.0/24 dev br0 proto kernel scope link src 192.168.100.101 metric 425 
192.168.254.100 dev eth1 scope link 


[root@server ~]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 101 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 101 
172.16.1.100 dev eth1 scope link 
172.16.2.100 dev eth1 scope link 
172.29.0.2 dev tun0 proto kernel scope link src 172.29.0.1 
192.168.100.0/24 via 172.29.0.2 dev tun0 
192.168.200.0/24 dev br0 proto kernel scope link src 192.168.200.100 metric 425 
192.168.254.100 dev eth1 proto kernel scope link src 192.168.254.100 metric 100

server-tun.conf
route 192.168.100.0 255.255.255.0

[root@server ~]# ping 192.168.100.101
PING 192.168.100.101 (192.168.100.101) 56(84) bytes of data.
64 bytes from 192.168.100.101: icmp_seq=1 ttl=64 time=1.54 ms
64 bytes from 192.168.100.101: icmp_seq=2 ttl=64 time=1.29 ms
64 bytes from 192.168.100.101: icmp_seq=3 ttl=64 time=1.31 ms
^C
--- 192.168.100.101 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 1.298/1.385/1.544/0.116 ms

### OpenVPN RAS

root $openvpn --config client.conf
Tue Nov 26 22:16:16 2019 OpenVPN 2.4.8 x86_64-redhat-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Nov  1 2019
Tue Nov 26 22:16:16 2019 library versions: OpenSSL 1.1.1d FIPS  10 Sep 2019, LZO 2.08
Tue Nov 26 22:16:16 2019 TCP/UDP: Preserving recently used remote address: [AF_INET]127.0.0.1:1195
...
Tue Nov 26 22:16:20 2019 /sbin/ip route add 192.168.200.0/24 via 192.168.90.5
...
Tue Nov 26 22:16:20 2019 Initialization Sequence Completed


root $ip route
...
192.168.90.1 via 192.168.90.5 dev tun0 
192.168.90.5 dev tun0 proto kernel scope link src 192.168.90.6 
...
192.168.200.0/24 via 192.168.90.5 dev tun0


root $ping 192.168.200.100
PING 192.168.200.100 (192.168.200.100) 56(84) bytes of data.
64 bytes from 192.168.200.100: icmp_seq=1 ttl=64 time=1.10 ms
64 bytes from 192.168.200.100: icmp_seq=2 ttl=64 time=0.946 ms
64 bytes from 192.168.200.100: icmp_seq=3 ttl=64 time=0.990 ms
^C
--- 192.168.200.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.946/1.011/1.097/0.063 ms


### OpenConnect VPN Server

root $openconnect 127.0.0.1:4430 -c client.p12 
POST https://127.0.0.1:4430/
Connected to 127.0.0.1:4430
Using client certificate 'client'
SSL negotiation with 127.0.0.1
Server certificate verify failed: signer not found

Certificate from VPN server "127.0.0.1" failed verification.
Reason: signer not found
To trust this server in future, perhaps add this to your command line:
--servercert pin-sha256:9H1mN2bvbhGScjrygfjEOD1ZdMaUgfZCUb1Y554ehMY=
Enter 'yes' to accept, 'no' to abort; anything else to view: yes
Connected to HTTPS on 127.0.0.1
XML POST enabled
SSL negotiation with 127.0.0.1
Server certificate verify failed: signer not found
Connected to HTTPS on 127.0.0.1
Got CONNECT response: HTTP/1.1 200 CONNECTED
CSTP connected. DPD 90, Keepalive 32400
DTLS handshake failed: Error in the push function.
(Is a firewall preventing you from sending UDP packets?)
Set up UDP failed; using SSL instead
Connected as 192.168.80.176, using SSL, with DTLS disabled
Error: any valid prefix is expected rather than "dev".


root $ip route
...
192.168.80.0/24 dev tun0 scope link 
...
192.168.200.0/24 dev tun0 scope link 


root $ping 192.168.200.100
PING 192.168.200.100 (192.168.200.100) 56(84) bytes of data.
64 bytes from 192.168.200.100: icmp_seq=1 ttl=64 time=1.36 ms
64 bytes from 192.168.200.100: icmp_seq=2 ttl=64 time=0.958 ms
64 bytes from 192.168.200.100: icmp_seq=3 ttl=64 time=0.949 ms
^C
--- 192.168.200.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.949/1.089/1.360/0.191 ms
