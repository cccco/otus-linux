

Результат запуска двух экземпляров httpd:

    ss -tnlp | grep httpd
    LISTEN     0      128         :::8080                    :::*                   users:(("httpd",pid=4002,fd=4),("httpd",pid=4001,fd=4),("httpd",pid=4000,fd=4),("httpd",pid=3999,fd=4),("httpd",pid=3998,fd=4),("httpd",pid=3997,fd=4))
    LISTEN     0      128         :::80                      :::*                   users:(("httpd",pid=3995,fd=4),("httpd",pid=3994,fd=4),("httpd",pid=3993,fd=4),("httpd",pid=3992,fd=4),("httpd",pid=3991,fd=4),("httpd",pid=3990,fd=4))
