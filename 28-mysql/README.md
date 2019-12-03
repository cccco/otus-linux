
[конфигурация master](provisioning/master/my.cnf.d)  
[конфигурация slave](provisioning/slave/my.cnf.d)

После автоматического развертывания стенда проверяем статус master сервера:
<pre><code>
mysql> show master status\G
*************************** 1. row ***************************
             File: mysql-bin.000002
         Position: 119461
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-39
1 row in set (0.00 sec)
</code></pre>

Таблицы в БД bet на master:
<pre><code>
mysql> show tables;
+------------------+
| Tables_in_bet    |
+------------------+
| bookmaker        |
| competition      |
| events_on_demand |
| market           |
| odds             |
| outcome          |
| v_same_event     |
+------------------+
7 rows in set (0.00 sec)
</code></pre>

Вставляем строку в таблицу bookmaker на master:
<pre><code>
mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
<b>|  1 | 1xbet          |</b>
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
</code></pre>


Статус slave сервера, GTID репликация работает:
<pre><code>
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
<b>       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event</b>
...
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
<b>           Retrieved_Gtid_Set: cfdec08a-1543-11ea-9d9b-5254008afee6:1-40</b>
<b>            Executed_Gtid_Set: 1b4ff99c-1544-11ea-a093-5254008afee6:1,</b>
<b>cfdec08a-1543-11ea-9d9b-5254008afee6:1-40</b>
               Auto_Position: 1
...
1 row in set (0.00 sec)
</code></pre>

Таблицы bet.events_on_demand и bet.v_same_event отсутствуют в БД bet на slave,  
 так как включены в replicate-ignore-table:
<pre><code>
mysql> show tables;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+
5 rows in set (0.00 sec)
</code></pre>

Изменения в таблице bookmaker на slave:
<pre><code>
mysql> select * from bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
<b>|  1 | 1xbet          |</b>
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
</code></pre>

С помощью утилиты mysqlbinlog можно посмотреть изменения, приходящие с master в binary логах slave:
<pre><code>
[root@slave ~]# mysqlbinlog /var/lib/mysql/slave-relay-bin.000002 | grep INSERT | tail -1
INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet')
</code></pre>
