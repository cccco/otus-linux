
[postgresql.conf master](provisioning/master/postgresql.conf)  
[pg_hba.conf master](provisioning/master/pg_hba.conf)  
[конфигурация barman для master](provisioning/backup/master.conf.j2)  

Начиная с PostgreSQL версии 12 настройки репликации прописываются  
в основном конфигурационном файле postgresql.conf.  
Отдельный файл recovery.conf не используется.

Резервное копирование master сервера осуществляется с использованием слота  
по сценарию streaming-only, который не требует ssh соединения на backup сервер.


###master

Список используемых для репликации слотов:
<pre><code>
postgres=# select slot_name,slot_type,active from pg_replication_slots;
 slot_name  | slot_type | active 
------------+-----------+--------
 slave_slot | physical  | f
 barman     | physical  | t
</code></pre>

Статус репликации:
<pre><code>
postgres=# select usename,application_name,client_addr,state from pg_stat_replication;
-[ RECORD 1 ]----+-------------------
usename          | replica
application_name | walreceiver
client_addr      | 192.168.11.151
state            | streaming
-[ RECORD 2 ]----+-------------------
usename          | barman_streaming
application_name | barman_receive_wal
client_addr      | 192.168.11.152
state            | streaming
</code></pre>

Добавление записи в тестовую таблицу для проверки репликации:
<pre><code>
otus=# insert into dz (v) values ('a');
INSERT 0 1

otus=# select * from dz;
 k | v 
---+---
 1 | a
(1 row
</code></pre>

###slave

Standby cервер slave находится в процессе восстановления:
<pre><code>
postgres=# select pg_is_in_recovery();
 pg_is_in_recovery 
-------------------
 t
(1 row)
</code></pre>

Проверка изменений, пришедших с master сервера:
<pre><code>
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
otus=# select * from dz;
 k | v 
---+---
 1 | a
(1 row)
</code></pre>


###backup

Проверка состояния резервируемого master сервера:
<pre><code>
-bash-4.2$ barman check master 
Server master:
	PostgreSQL: OK
	is_superuser: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archiver errors: OK
</code></pre>

Просмотр статуса репликации:
<pre><code>
-bash-4.2$ barman replication-status  master 
Status of streaming clients for server 'master':
  Current LSN on master: 0/110000C8
  Number of streaming clients: 2

  1. Async standby
     Application name: walreceiver
     Sync stage      : 5/5 Hot standby (max)
     Communication   : TCP/IP
     IP Address      : 192.168.11.151 / Port: 42172 / Host: -
     User name       : replica
     Current state   : streaming (async)
     WAL sender PID  : 7411
     Started at      : 2019-12-28 20:17:35.592412+00:00
     Sent LSN   : 0/110000C8 (diff: 0 B)
     Write LSN  : 0/110000C8 (diff: 0 B)
     Flush LSN  : 0/110000C8 (diff: 0 B)
     Replay LSN : 0/110000C8 (diff: 0 B)

  2. Async WAL streamer
     Application name: barman_receive_wal
     Sync stage      : 3/3 Remote write
     Communication   : TCP/IP
     IP Address      : 192.168.11.152 / Port: 54818 / Host: -
     User name       : barman_streaming
     Current state   : streaming (async)
     Replication slot: barman
     WAL sender PID  : 26760
     Started at      : 2019-12-28 22:22:02.531418+00:00
     Sent LSN   : 0/110000C8 (diff: 0 B)
     Write LSN  : 0/110000C8 (diff: 0 B)
     Flush LSN  : 0/11000000 (diff: -200 B)
</code></pre>

Создание резервной копии master:
<pre><code>
-bash-4.2$ barman backup master --wait
Starting backup using postgres method for server master in /var/lib/barman/master/base/20191228T223619
Backup start at LSN: 0/F000148 (00000001000000000000000F, 00000148)
Starting backup copy via pg_basebackup for 20191228T223619
Copy done (time: 1 second)
Finalising the backup.
This is the first backup for server master
WAL segments preceding the current backup have been found:
	00000001000000000000000E from server master has been removed
Backup size: 31.1 MiB
Backup end at LSN: 0/11000000 (000000010000000000000010, 00000000)
Backup completed (start time: 2019-12-28 22:36:19.223783, elapsed time: 1 second)
Waiting for the WAL file 000000010000000000000010 from server 'master'
Processing xlog segments from streaming for master
	00000001000000000000000F
Processing xlog segments from streaming for master
	000000010000000000000010
</code></pre>

Статус master сервера:
<pre><code>
-bash-4.2$ barman status master 
Server master:
	Description: master server
	Active: True
	Disabled: False
	PostgreSQL version: 12.1
	Cluster state: in production
	pgespresso extension: Not available
	Current data size: 31.4 MiB
	PostgreSQL Data directory: /var/lib/pgsql/12/data
	Current WAL segment: 000000010000000000000011
	Passive node: False
	Retention policies: not enforced
<b>	No. of available backups: 1</b>
	First available backup: 20191228T223619
	Last available backup: 20191228T223619
	Minimum redundancy requirements: satisfied (1/0)
</code></pre>
