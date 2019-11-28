
[конфигурация postfix](provisioning/main.cf)  
[конфигурация dovecot](provisioning/dovecot.conf)

Порт 1025 прокинут с хоста на порт smtp 25 ВМ,  
порт 1110 на порт pop3 110.

Отправка письма:

<pre><code>
user $telnet 127.0.0.1 1025
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
220 mail.localdomain ESMTP Postfix
helo localdomain
250 mail.localdomain
mail from:root
250 2.1.0 Ok
rcpt to:user
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
Hello, user!
test text
.
250 2.0.0 Ok: queued as 228CA1AA
quit
221 2.0.0 Bye
Connection closed by foreign host.
</code></pre>

Получение письма:

<pre><code>
user $telnet 127.0.0.1 1110
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
+OK Dovecot ready.
user user
+OK
pass 123456
+OK Logged in.
list
+OK 1 messages:
1 278
.
top 1 10
+OK
Return-Path: <root@mail.localdomain>
X-Original-To: user
Delivered-To: user@mail.localdomain
Received: from localdomain (gateway [10.0.2.2])
    by mail.localdomain (Postfix) with SMTP id 228CA1AA
    for <user>; Thu, 28 Nov 2019 18:35:15 +0000 (UTC)
	
Hello, user!
test text
.
dele 1
+OK Marked to be deleted.
list
+OK 0 messages:
.
quit
+OK Logging out, messages deleted.
Connection closed by foreign host.
</code></pre>
