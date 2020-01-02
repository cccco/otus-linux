
### общая схема стенда

				     |port 5000
				+----+----+
				| haproxy |
				+----+----+
				     |
				     |
		+--------------------+--------------------+
		|                    |                    |
		|                    |                    |
	 +------|-------+     +------|-------+     +------|-------+
	 |      |6432   |     |      |6432   |     |      |6432   |
	 | +----+-----+ |     | +----+-----+ |     | +----+-----+ |
	 | |pgbouncer | |     | |pgbouncer | |     | |pgbouncer | |
	 | +----+-----+ |     | +----+-----+ |     | +----+-----+ |
	 |      |       |     |      |       |     |      |       |
	 |      |5432   |     |      |5432   |     |      |5432   |
	 | +----------+ |     | +----------+ |     | +----------+ |
	 | |PostgreSQL| |     | |PostgreSQL| |     | |PostgreSQL| |
	 | | patroni  | |     | | patroni  | |     | | patroni  | |
	 | +----+-----+ |     | +----+-----+ |     | +----+-----+ |
	 |      |       |     |      |       |     |      |       |
	 |      |2379   |     |      |2379   |     |      |2379   |
	 | +----+-----+ |     | +----+-----+ |     | +----+-----+ |
	 | |  etcd    +---------+  etcd    +---------+  etcd    | |
	 | +----------+ |     | +----------+ |     | +----------+ |
	 +--------------+     +--------------+     +--------------+

### servera

<pre><code>
[root@servera ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 |        | running |  1 |         0 |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  1 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  1 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
</code></pre>

### haproxy

Веб-интерфейс доступен по адресу http://192.168.11.153:7000

![веб-интерфейс haproxy](haproxy.png)

<pre><code>
[root@haproxy ~]# psql -h 192.168.11.153 -p 5000 -U postgres

postgres=# select slot_name,slot_type,active from pg_replication_slots;
 slot_name | slot_type | active 
-----------+-----------+--------
 serverb   | physical  | t
 servera   | physical  | t
(2 rows)
</code></pre>

<pre><code>
postgres=# select usename,application_name,client_addr,state from pg_stat_replication;
-[ RECORD 1 ]----+---------------
usename          | replicator
application_name | servera
client_addr      | 192.168.11.150
state            | streaming
-[ RECORD 2 ]----+---------------
usename          | replicator
application_name | serverb
client_addr      | 192.168.11.151
state            | streaming
</code></pre>

<pre><code>
postgres=# create database otus;
CREATE DATABASE
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
otus=# create table dz (k serial, v varchar);
CREATE TABLE
otus=# insert into dz (v) values ('a');
INSERT 0 1
otus=# select * from dz;
 k | v 
---+---
 1 | a
(1 row)
</code></pre>

### servera

<pre><code>
[root@servera ~]# psql -h 192.168.11.150 -p 6432 -U postgres
Password for user postgres: 
psql (12.1)
Type "help" for help.
</code></pre>

<pre><code>
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
otus=# select * from dz;
 k | v 
---+---
 1 | a
(1 row)
</code></pre>

<pre><code>
otus=# select pg_is_in_recovery();
 pg_is_in_recovery 
-------------------
 t
(1 row
</code></pre>

### pgbouncer (serverc Leader)

<pre><code>
[root@serverc ~]# psql -h 127.0.0.1 -p 6432 -U postgres pgbouncer

pgbouncer=# show version;
     version      
------------------
 PgBouncer 1.12.0
(1 row)
</code></pre>

<pre><code>
pgbouncer=# show pools;
 database  |   user    | cl_active | cl_waiting | sv_active | sv_idle | sv_used | sv_tested | sv_login | maxwait | maxwait_us | pool_mode 
-----------+-----------+-----------+------------+-----------+---------+---------+-----------+----------+---------+------------+-----------
 otus      | postgres  |         1 |          0 |         0 |       0 |       0 |         0 |        0 |       0 |          0 | session
 pgbouncer | pgbouncer |         1 |          0 |         0 |       0 |       0 |         0 |        0 |       0 |          0 | statement
 postgres  | postgres  |         0 |          0 |         0 |       0 |       0 |         0 |        0 |       0 |          0 | session
(3 rows)
</code></pre>

<pre><code>
pgbouncer=# show clients;
-[ RECORD 1 ]+------------------------
type         | C
user         | postgres
database     | otus
state        | active
addr         | 192.168.11.153
port         | 60256
local_addr   | 192.168.11.152
local_port   | 6432
connect_time | 2020-01-02 20:42:05 UTC
request_time | 2020-01-02 20:42:05 UTC
wait         | 0
wait_us      | 0
close_needed | 0
ptr          | 0x124a230
link         | 
remote_pid   | 0
tls          | 
-[ RECORD 2 ]+------------------------
type         | C
user         | postgres
database     | pgbouncer
state        | active
addr         | 127.0.0.1
port         | 47372
local_addr   | 127.0.0.1
local_port   | 6432
connect_time | 2020-01-02 20:52:50 UTC
request_time | 2020-01-02 20:53:46 UTC
wait         | 52
wait_us      | 62803
close_needed | 0
ptr          | 0x124a448
link         | 
remote_pid   | 0
tls          | 
</code></pre>


### switchover/failover

#### switchover

<pre><code>
[root@servera ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml switchover
Master [serverc]: 
Candidate ['servera', 'serverb'] []: servera
When should the switchover take place (e.g. 2020-01-02T21:55 )  [now]: 
Current cluster topology
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 |        | running |  1 |         0 |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  1 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  1 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
Are you sure you want to switchover cluster patroni_cluster_otus, demoting current master serverc? [y/N]: y
2020-01-02 20:56:06.85421 Successfully switched over to "servera"
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 | Leader | running |  1 |           |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  1 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 |        | stopped |    |   unknown |
+----------------------+---------+----------------+--------+---------+----+-----------+
[root@servera ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 | Leader | running |  2 |         0 |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  2 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 |        | running |  2 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
</code></pre>

#### failover

<pre><code>
[root@serverc ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 | Leader | running |  2 |         0 |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  2 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 |        | running |  2 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
</code></pre>

<pre><code>
[root@servera ~]# systemctl stop patroni.service
</code></pre>

<pre><code>
[root@serverc ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 |        | stopped |    |   unknown |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  3 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  3 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+

[root@serverc ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  3 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  3 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
</code></pre>

<pre><code>
[root@servera ~]# systemctl start patroni.service
</code></pre>

<pre><code>
[root@serverc ~]# patronictl -c /opt/app/patroni/etc/postgresql.yml list
+----------------------+---------+----------------+--------+---------+----+-----------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB |
+----------------------+---------+----------------+--------+---------+----+-----------+
| patroni_cluster_otus | servera | 192.168.11.150 |        | running |  3 |         0 |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  3 |         0 |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  3 |         0 |
+----------------------+---------+----------------+--------+---------+----+-----------+
</code></pre>

### change configuration

#### without restart

<pre><code>
[root@serverb ~]# psql -h 127.0.0.1 -p 6432 -U postgres
postgres=# show temp_buffers;
 temp_buffers 
--------------
 8MB
(1 row)
</code></pre>

<pre><code>
[root@servera etc]# patronictl -c /opt/app/patroni/etc/postgresql.yml edit-config
--- 
+++ 
@@ -3,6 +3,7 @@
 postgresql:
   parameters:
     wal_keep_segments: 100
+    temp_buffers: 16MB
   use_pg_rewind: true
   use_slots: true
 retry_timeout: 10

Apply these changes? [y/N]: y
Configuration changed
</code></pre>

<pre><code>
[root@serverb ~]# psql -h 127.0.0.1 -p 6432 -U postgres
Password for user postgres: 
psql (12.1)
Type "help" for help.

postgres=# show temp_buffers;
 temp_buffers 
--------------
 16MB
(1 row)
</code></pre>

#### with restart

<pre><code>
[root@serverc data]# psql -h 127.0.0.1 -p 6432 -U postgres
Password for user postgres: 
psql (12.1)
Type "help" for help.

postgres=# show shared_buffers;
 shared_buffers 
----------------
 128MB
(1 row)
</code></pre>

<pre><code>
[root@servera data]# patronictl -c /opt/app/patroni/etc/postgresql.yml edit-config
--- 
+++ 
@@ -4,6 +4,7 @@
   parameters:
     temp_buffers: 16MB
     wal_keep_segments: 100
+    shared_buffers: 256MB
   use_pg_rewind: true
   use_slots: true
 retry_timeout: 10

Apply these changes? [y/N]: y
Configuration changed
</code></pre>

<pre><code>
[root@servera data]# patronictl -c /opt/app/patroni/etc/postgresql.yml restart patroni_cluster_otus
When should the restart take place (e.g. 2020-01-02T22:34)  [now]: 
+----------------------+---------+----------------+--------+---------+----+-----------+-----------------+
|       Cluster        |  Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+----------------------+---------+----------------+--------+---------+----+-----------+-----------------+
| patroni_cluster_otus | servera | 192.168.11.150 |        | running |  3 |         0 |        *        |
| patroni_cluster_otus | serverb | 192.168.11.151 |        | running |  3 |         0 |        *        |
| patroni_cluster_otus | serverc | 192.168.11.152 | Leader | running |  3 |         0 |        *        |
+----------------------+---------+----------------+--------+---------+----+-----------+-----------------+
Are you sure you want to restart members servera, serverb, serverc? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []:   
Success: restart on member servera
Success: restart on member serverb
Success: restart on member serverc
</code></pre>

<pre><code>
[root@serverc data]# psql -h 127.0.0.1 -p 6432 -U postgres
Password for user postgres: 
psql (12.1)
Type "help" for help.

postgres=# show shared_buffers;
 shared_buffers 
----------------
 256MB
(1 row)
</code></pre>

<pre><code>
[root@serverb ~]# psql -h 127.0.0.1 -p 6432 -U postgres
Password for user postgres: 
psql (12.1)
Type "help" for help.

postgres=# show shared_buffers;
 shared_buffers 
----------------
 256MB
(1 row)
</code></pre>
