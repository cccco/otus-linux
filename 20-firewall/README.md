
### cхема стенда


                            |                               |
                            | uplink                        | uplink
                            | eth0 nat                      | eth0 nat
                     +------+------+                 +------+------+
                     |             |                 |             |
                     | inetRouter  |                 | inetRouter2 |
                     |             |                 |             |
                     +------+------+                 +------+------+
                            | eth1                          | eth1
                            | 192.168.255.1/30              | 192.168.255.5/30
                            |                               |
                            |router-net                     |router2-net
                            |                               |
                            |                               |
                            |                               |
                            |                               |
                            |        +-------------+        |
                        eth1|        |             |        |eth2
            192.168.255.2/30+--------+centralRouter+--------+192.168.255.2/30
                                     |             |
                                     +------+------+
                                            |eth3
                                            |192.168.0.1/28
                                            |
                                            |dir-net
                                            |
                                            |eth1
                                            |192.168.0.2/28
                                     +------+------+
                                     |             |
                                     |centralServer|
                                     |             |
                                     +-------------+


### описание

На inetRouter с помощью iptables настроен port knocking для ssh.
Проверка доступа с centralRouter, knock.sh для port knocking:

    [root@centralRouter ~]# /vagrant/knock.sh 192.168.255.1 8881 7777 9991

    Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 19:29 UTC
    Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
    Nmap scan report for 192.168.255.1
    Host is up (0.00031s latency).
    PORT     STATE    SERVICE
    8881/tcp filtered unknown
    MAC Address: 08:00:27:3F:8C:12 (Cadmus Computer Systems)

    Nmap done: 1 IP address (1 host up) scanned in 0.19 seconds

    Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 19:29 UTC
    Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
    Nmap scan report for 192.168.255.1
    Host is up (0.00032s latency).
    PORT     STATE    SERVICE
    7777/tcp filtered cbt
    MAC Address: 08:00:27:3F:8C:12 (Cadmus Computer Systems)

    Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds

    Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 19:29 UTC
    Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
    Nmap scan report for 192.168.255.1
    Host is up (0.00034s latency).
    PORT     STATE    SERVICE
    9991/tcp filtered issa
    MAC Address: 08:00:27:3F:8C:12 (Cadmus Computer Systems)

    Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds



    [root@centralRouter ~]# ssh root@192.168.255.1
    The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
    RSA key fingerprint is SHA256:tiVhUS2j9SWf55A2V3osS4q5iZhb096x7ZU2cOU887E.
    RSA key fingerprint is MD5:c6:a8:51:0b:fd:74:17:88:c8:d3:84:fb:c1:f1:7c:8d.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.255.1' (RSA) to the list of known hosts.
    root@192.168.255.1's password: 
    [root@inetRouter ~]# 




На inetRouter2 настроен проброс порта 8080 на centralServer порт 80, где запущет nginx.
Проверка доступа с centralRouter:

    [root@centralRouter ~]# telnet 192.168.255.5 8080
    Trying 192.168.255.5...
    Connected to 192.168.255.5.
    Escape character is '^]'.
    GET /index.html
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
      <title>Welcome to CentOS</title>
        <style rel="stylesheet" type="text/css"> 
        ...

Доступ в internet для centralServer настроен через inetRouter:

    [root@centralServer ~]# tracepath -n 8.8.8.8
    1?: [LOCALHOST]                                         pmtu 1500
    1:  192.168.0.1                                           0.624ms 
    1:  192.168.0.1                                           0.472ms 
    2:  192.168.255.1                                         0.787ms 
    ^C
