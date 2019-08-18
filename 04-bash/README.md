* [parse_nginx_log.sh](parse_nginx_log.sh) - скрипт анализа лог файла веб-сервера nginx  
* [access.log](access.log) - тестовый лог  

Для эмуляции работы по расписанию скрипт считывает случайное количество строк ($RANDOM % 400 + 1000)  
с лог файла, разбирает строки с помошью regex, отправляет отчёт на email root.  
Номер последней считанной строки сохраняется в файл line_last.  
При повторном запуске работа начинается со строки, следующей за строкой, сохранённой в файле line_last.  
Реализованы защита от мультизапуска, перехват сигналов SIGHUP SIGINT SIGQUIT SIGTERM,  
функция для печати отсортированного массива.  


Пример вывода скрипта:

    analyze date range [ 16/Dec/2015:01:10:52 +0100 - 17/Dec/2015:09:06:09 +0100 ]  

    top 10 ip addresses
    ----------------------------------------------------------------
    80.122.17.178                                     	84
    191.184.182.30                                    	37
    151.77.62.101                                     	37
    151.70.18.115                                     	35
    37.1.206.196                                      	20
    190.157.18.55                                     	17
    189.12.82.206                                     	14
    109.60.236.215                                    	14
    94.143.240.18                                     	12
    46.148.230.213                                    	12

    top 10 urls
    ----------------------------------------------------------------
    /administrator/index.php                          	506
    /administrator/                                   	489
    /                                                 	42
    /apache-log/access.log                            	17
    /robots.txt                                       	12
    /images/stories/slideshow/almhuette_raith_05.jpg  	8
    /images/stories/slideshow/almhuette_raith_04.jpg  	8
    /images/stories/slideshow/almhuette_raith_03.jpg  	8
    /images/stories/slideshow/almhuette_raith_02.jpg  	8
    /images/stories/slideshow/almhuette_raith_01.jpg  	8

    top 10 wrong urls (5**,4**)
    ----------------------------------------------------------------
    /templates/_system/css/general.css                	13
    /wp-login.php                                     	11
    /wp-login.php?action=register                     	10
    /media/jui/js/cms.js                              	4
    /favicon.ico                                      	3
    /contact                                          	2
    /wp-admin/wp-login.php                            	1
    /wp-admin/                                        	1
    /apache-log/error.log.20.gz                       	1
    /administrator/                                   	1

    statistics of http codes
    ----------------------------------------------------------------
    200                                               	1284
    404                                               	46
    304                                               	2
    500                                               	1
