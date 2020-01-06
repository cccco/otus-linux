
Стенд разворачивается автоматически с помощью Vagrant Ansible Provisioner  


### server

Просмотр настроек firewalld:
<pre><code>
[root@server ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: ssh dhcpv6-client nfs mountd rpc-bind kerberos kadmin
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
</code></pre>

Список экспортируемых каталогов nfs сервера:
<pre><code>
[root@server ~]# exportfs -s
/mnt/nfs_share  *(sync,wdelay,hide,no_subtree_check,sec=krb5,rw,secure,no_root_squash,no_all_squash)
</code></pre>

Записи в базе данных Kerberos, видны principal сервисов nfs:
<pre><code>
[root@server ~]# kadmin.local 
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
host/client.example.com@EXAMPLE.COM
host/server.example.com@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/server.example.com@EXAMPLE.COM
kiprop/server.example.com@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
<b>nfs/client.example.com@EXAMPLE.COM</b>
<b>nfs/server.example.com@EXAMPLE.COM</b>
root/admin@EXAMPLE.COM
</code></pre>

Статистика сервера nfs, клиент использует версию 3:
<pre><code>
[root@server ~]# nfsstat -l
nfs v3 server        total:       18 
------------- ------------- --------
nfs v3 server         null:        2 
nfs v3 server      getattr:        5 
nfs v3 server      setattr:        1 
nfs v3 server       lookup:        1 
nfs v3 server       access:        1 
nfs v3 server        write:        1 
nfs v3 server       create:        1 
nfs v3 server  readdirplus:        1 
nfs v3 server       fsstat:        2 
nfs v3 server       fsinfo:        2 
nfs v3 server     pathconf:        1 
</code></pre>

Информация rpc.mountd о клиентах:
<pre><code>
[root@server ~]# cat /var/lib/nfs/rmtab 
192.168.11.151:/mnt/nfs_share:0x00000001
</code></pre>

### client

Список экспортируемых каталогов сервера nfs:
<pre><code>
[root@client ~]# showmount -e server.example.com
Export list for server.example.com:
/mnt/nfs_share *
</code></pre>

Информация о смонтированных каталогах на сервере nfs:
<pre><code>
[root@client ~]# showmount -a server.example.com
All mount points on server.example.com:
192.168.11.151:/mnt/nfs_share
</code></pre>

Файл fstab клиента:
<pre><code>
[root@client ~]# cat /etc/fstab 

#
# /etc/fstab
# Created by anaconda on Sat Jun  1 17:13:31 2019
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870 /                       xfs     defaults        0 0
/swapfile none swap defaults 0 0
server.example.com:/mnt/nfs_share /mnt/nfs_share nfs vers=3,soft,timeo=100,_netdev,rw,sec=krb5 0 0
</code></pre>

Опции монтирования nfs каталога на клиенте:
<pre><code>
[root@client ~]# grep nfs_share /etc/mtab
server.example.com:/mnt/nfs_share /mnt/nfs_share nfs rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,soft,proto=tcp,timeo=100,retrans=2,sec=krb5,mountaddr=192.168.11.150,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.11.150 0 0
</code></pre>

Информация о файловых системах на клиенте:
<pre><code>
[root@client ~]# df -hT
Filesystem                        Type      Size  Used Avail Use% Mounted on
/dev/sda1                         xfs        40G  2.9G   38G   8% /
devtmpfs                          devtmpfs  236M     0  236M   0% /dev
tmpfs                             tmpfs     244M     0  244M   0% /dev/shm
tmpfs                             tmpfs     244M  4.5M  240M   2% /run
tmpfs                             tmpfs     244M     0  244M   0% /sys/fs/cgroup
tmpfs                             tmpfs      49M     0   49M   0% /run/user/1000
server.example.com:/mnt/nfs_share nfs        40G  3.1G   37G   8% /mnt/nfs_share
</code></pre>

Проверка доступности каталога nfs для записи на клиенте:
<pre><code>
[root@client ~]# cp ~/anaconda-ks.cfg /mnt/nfs_share/
[root@client ~]# ls -l /mnt/nfs_share/
total 8
-rw-------. 1 nfsnobody nfsnobody 5570 Jan  6 11:16 anaconda-ks.cfg
</code></pre>
