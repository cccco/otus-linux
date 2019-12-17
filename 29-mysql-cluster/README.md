Стенд InnoDB Cluster состоит из трёх контейнеров docker с сервером mysql,  
контейнера mysql-router и дополнительного контейнера mysql-shell.

Образ [mysql-shell](docker/mysql-shell) сделан на основе  
образа centos:7 и размещён на docker hub https://hub.docker.com/r/halaram/mysql-shell

Стенд разворачивается с помощью docker-compose в shell provisioning Vagrant


Состояние контейнеров после запуска:
<pre><code>
[root@docker ~]# docker ps
CONTAINER ID        IMAGE                       COMMAND                  CREATED              STATUS                           PORTS                                                    NAMES
3df22f984926        mysql/mysql-router:8.0.18   "/run.sh mysqlrouter"    About a minute ago   Up 1 second (health: starting)   6447/tcp, 64460/tcp, 0.0.0.0:6446->6446/tcp, 64470/tcp   docker_router_1
f0dac96c5a68        halaram/mysql-shell:0.1     "/run.sh mysqlsh"        About a minute ago   Up About a minute                                                                         docker_shell_1
86e156f85780        mysql/mysql-server:8.0.18   "/entrypoint.sh my..."   About a minute ago   Up About a minute (healthy)      33060/tcp, 0.0.0.0:33062->3306/tcp                       docker_server2_1
b1c9f621bbf4        mysql/mysql-server:8.0.18   "/entrypoint.sh my..."   About a minute ago   Up About a minute (healthy)      33060/tcp, 0.0.0.0:33061->3306/tcp                       docker_server1_1
55ec7283a9f4        mysql/mysql-server:8.0.18   "/entrypoint.sh my..."   About a minute ago   Up About a minute (healthy)      33060/tcp, 0.0.0.0:33063->3306/tcp                       docker_server3_1
</code></pre>

Проверяем статус кластера:
<pre><code>
[root@docker ~]# docker exec -it docker_shell_1 mysqlsh
MySQL Shell 8.0.18

Copyright (c) 2016, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  JS > shell.connect('root@server1:3306', 'root')
Creating a session to 'root@server1:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 439
Server version: 8.0.18 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
<ClassicSession:root@server1:3306>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "b1c9f621bbf4:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "55ec7283a9f4:3306": {
                "address": "55ec7283a9f4:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "86e156f85780:3306": {
                "address": "86e156f85780:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "b1c9f621bbf4:3306": {
                "address": "b1c9f621bbf4:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "b1c9f621bbf4:3306"
}
 MySQL  server1:3306 ssl  JS ></code></pre>


Выключаем ноду server2:
<pre><code>
[root@docker ~]# docker stop docker_server2_1
docker_server2_1
</code></pre>

Статус кластера:
<pre><code>
[root@docker ~]# docker exec -it docker_shell_1 mysqlsh
MySQL Shell 8.0.18

Copyright (c) 2016, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  JS > shell.connect('root@server1:3306', 'root')
Creating a session to 'root@server1:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 663
Server version: 8.0.18 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
<ClassicSession:root@server1:3306>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "b1c9f621bbf4:3306", 
        "ssl": "REQUIRED", 
        "status": "OK_NO_TOLERANCE", 
        "statusText": "Cluster is NOT tolerant to any failures. 1 member is not active", 
        "topology": {
            "55ec7283a9f4:3306": {
                "address": "55ec7283a9f4:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "86e156f85780:3306": {
                "address": "86e156f85780:3306", 
                "mode": "n/a", 
                "readReplicas": {}, 
                "role": "HA", 
<b>                "shellConnectError": "MySQL Error 2005 (HY000): Unknown MySQL server host '86e156f85780' (2)", </b>
<b>                "status": "(MISSING)"</b>
            }, 
            "b1c9f621bbf4:3306": {
                "address": "b1c9f621bbf4:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "b1c9f621bbf4:3306"
}
 MySQL  server1:3306 ssl  JS >
</code></pre>

Включаем ноду server2:
<pre><code>
[root@docker ~]# docker start docker_server2_1
docker_server2_1
</code></pre>

Статус кластера:
<pre><code>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "b1c9f621bbf4:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "55ec7283a9f4:3306": {
                "address": "55ec7283a9f4:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "86e156f85780:3306": {
                "address": "86e156f85780:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "b1c9f621bbf4:3306": {
                "address": "b1c9f621bbf4:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "b1c9f621bbf4:3306"
}
 MySQL  server1:3306 ssl  JS > 

</code></pre>

Проверка работы mysql-router:
<pre><code>
[root@docker ~]# mysql -h 127.0.0.1 -P 6446 -uroot -proot
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 857
Server version: 8.0.18 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> show databases;
+-------------------------------+
| Database                      |
+-------------------------------+
| information_schema            |
| mysql                         |
| mysql_innodb_cluster_metadata |
| otus                          |
| performance_schema            |
| sys                           |
+-------------------------------+
6 rows in set (0.04 sec)

MySQL [(none)]>
</code></pre>
