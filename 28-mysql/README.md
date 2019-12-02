


mysql> show master status\G
*************************** 1. row ***************************
             File: mysql-bin.000002
         Position: 119461
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-39
1 row in set (0.00 sec)


mysql> show slave status\G
...
Retrieved_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-39
Executed_Gtid_Set: 1b4ff99c-1544-11ea-a093-5254008afee6:1,
           cfdec08a-1543-11ea-9d9b-5254008afee6:1-39
...

master
mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

mysql> show slave status\G

Relay_Log_File: slave-relay-bin.000002
...
Retrieved_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-40
Executed_Gtid_Set: 1b4ff99c-1544-11ea-a093-5254008afee6:1,
           cfdec08a-1543-11ea-9d9b-5254008afee6:1-40
...


slave
mysql> select * from bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)


[root@slave ~]# mysqlbinlog /var/lib/mysql/slave-relay-bin.000002 | grep INSERT | tail -1
INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet'




mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.11.150
                  Master_User: repl
...
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 119757
               Relay_Log_File: slave-relay-bin.000002
...
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
...
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event
...
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
           Retrieved_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-40
            Executed_Gtid_Set: 1b4ff99c-1544-11ea-a093-5254008afee6:1,
cfdec08a-1543-11ea-9d9b-5254008afee6:1-40
               Auto_Position: 1
...
1 row in set (0.00 sec)
