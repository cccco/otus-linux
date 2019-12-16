
<pre><code>
[root@docker ~]# docker exec -it 1_shell_1 mysqlsh
MySQL Shell 8.0.18

Copyright (c) 2016, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  JS > shell.connect('root@server1:3306', 'root')
Creating a session to 'root@server1:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 590
Server version: 8.0.18 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
<ClassicSession:root@server1:3306>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "a3c5375d4334:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "538870c08687:3306": {
                "address": "538870c08687:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "a3c5375d4334:3306": {
                "address": "a3c5375d4334:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "d1ff513e2f0e:3306": {
                "address": "d1ff513e2f0e:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "a3c5375d4334:3306"
}
 MySQL  server1:3306 ssl  JS > 
</code></pre>

<pre><code>
[root@docker ~]# docker stop 1_server2_1
1_server2_1
</code></pre>

<pre><code>
[root@docker ~]# docker exec -it 1_shell_1 mysqlsh
MySQL Shell 8.0.18

Copyright (c) 2016, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  JS > shell.connect('root@server1:3306', 'root')
Creating a session to 'root@server1:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 1837
Server version: 8.0.18 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
<ClassicSession:root@server1:3306>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "a3c5375d4334:3306", 
        "ssl": "REQUIRED", 
        "status": "OK_NO_TOLERANCE", 
        "statusText": "Cluster is NOT tolerant to any failures. 1 member is not active", 
        "topology": {
            "538870c08687:3306": {
                "address": "538870c08687:3306", 
                "mode": "n/a", 
                "readReplicas": {}, 
                "role": "HA", 
                "shellConnectError": "MySQL Error 2003 (HY000): Can't connect to MySQL server on '538870c08687' (110)", 
                "status": "(MISSING)"
            }, 
            "a3c5375d4334:3306": {
                "address": "a3c5375d4334:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "d1ff513e2f0e:3306": {
                "address": "d1ff513e2f0e:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "a3c5375d4334:3306"
}
 MySQL  server1:3306 ssl  JS > 
</code></pre>

<pre><code>
[root@docker ~]# docker start 1_server2_1
</code></pre>

<pre><code>
 MySQL  server1:3306 ssl  JS > dba.getCluster().status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "a3c5375d4334:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "538870c08687:3306": {
                "address": "538870c08687:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "a3c5375d4334:3306": {
                "address": "a3c5375d4334:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }, 
            "d1ff513e2f0e:3306": {
                "address": "d1ff513e2f0e:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": null, 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.18"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "a3c5375d4334:3306"
}
 MySQL  server1:3306 ssl  JS >
</code></pre>

<pre><code>
[root@docker ~]# mysql -h 127.0.0.1 -P 6446 -uroot -proot
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 2988
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
7 rows in set (0.02 sec)

MySQL [(none)]> 
</code></pre>
