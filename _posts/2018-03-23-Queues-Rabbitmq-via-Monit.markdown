---
layout: post
title: Queues Rabbitmq via Monit
author: Galuh D Wijatmiko
categories: ['MessageBroker','Server']
tags: [rabbitmq,centos7]
---


## CGI BIN BASH  ##


Install HTTPD


`yum install httpd`


Start HTTPD

`systemctl start httpd`

Enable Startup

`systemctl enable httpd`

create file _check-rabbitmq_ in /var/www/cgi-bin

```bash
  #!/bin/bash
  echo "Content-type: text/html"
  echo '<html><head>'
  echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
  PATH="/bin:/usr/bin:/usr/ucb:/usr/opt/bin"
  export $PATH
  echo '<title>System Uptime</title>'
  echo '</head>'
  echo '<body>'
  b=$(echo $QUERY_STRING | cut -d'=' -f2 )
  /usr/bin/sudo /usr/sbin/rabbitmqctl list_queues > /var/www/cgi-bin/data_queque
  data=$(cat /var/www/cgi-bin/data_queque | grep -v "Listing queues"| grep $b | awk '{print $2}' | sed "s/ //")
  if [ $data -gt 5 ]; then
  	echo "warning"
  else
  	echo "ok"
  fi 
  echo '</body>'
  echo '</html>'
  exit 0
```

create file data_queque in  /var/www/cgi-bin/

`touch /var/www/cgi-bin/data_queque`

in /etc/monit.d/ create file for queques one by one.
example : queues_redis

check host queues_redis with address localhost
```
if failed
	port 80
	protocol http
	request "/cgi-bin/bismillah.sh?data=queues_redis"
	content = "ok"
then alert
```

##FLOW TASK##

Monit execute url http:///cgi-bin/bismillah.sh?data=queues_redis

File check-rabbitmq accept method GET from monit

If queue greater than 5 then waning 

Alert will be inform
