
В конфигурации nginx используется редирект для установки куки notbot, если её нет,  
затем редирект на основную страницу.

Порт 8080 прокинут с хоста на порт 80 ВМ.

<pre><code>
user $curl -v -L 127.0.0.1:8080
*   Trying 127.0.0.1:8080...
* TCP_NODELAY set
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.66.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
<b>< HTTP/1.1 302 Moved Temporarily</b>
< Server: nginx/1.16.1
< Date: Wed, 27 Nov 2019 19:52:11 GMT
< Content-Type: text/html
< Content-Length: 145
< Connection: keep-alive
<b>< Location: http://127.0.0.1:8080/setcookie</b>
< 
* Ignoring the response-body
* Connection #0 to host 127.0.0.1 left intact
* Issue another request to this URL: 'http://127.0.0.1:8080/setcookie'
* Found bundle for host 127.0.0.1: 0x5567f8d90400 [serially]
* Can not multiplex, even if we wanted to!
* Re-using existing connection! (#0) with host 127.0.0.1
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET /setcookie HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.66.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
<b>< HTTP/1.1 302 Moved Temporarily</b>
< Server: nginx/1.16.1
< Date: Wed, 27 Nov 2019 19:52:11 GMT
< Content-Type: text/html
< Content-Length: 145
< Connection: keep-alive
<b>< Location: http://127.0.0.1:8080/</b>
* Added cookie notbot="true" for domain 127.0.0.1, path /, expire 0
<b>< Set-Cookie: notbot=true</b>
< 
* Ignoring the response-body
* Connection #0 to host 127.0.0.1 left intact
* Issue another request to this URL: 'http://127.0.0.1:8080/'
* Found bundle for host 127.0.0.1: 0x5567f8d90400 [serially]
* Can not multiplex, even if we wanted to!
* Re-using existing connection! (#0) with host 127.0.0.1
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.66.0
> Accept: */*
<b>> Cookie: notbot=true</b>
> 
* Mark bundle as not supporting multiuse
<b>< HTTP/1.1 200 OK</b>
< Server: nginx/1.16.1
< Date: Wed, 27 Nov 2019 19:52:11 GMT
< Content-Type: text/html
< Content-Length: 4833
< Last-Modified: Fri, 16 May 2014 15:12:48 GMT
< Connection: keep-alive
< ETag: "53762af0-12e1"
< Accept-Ranges: bytes
< 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
    <style rel="stylesheet" type="text/css">
...
</body>
</html>
* Connection #0 to host 127.0.0.1 left intact
</code></pre>
