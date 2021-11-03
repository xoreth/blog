---
layout: post
title: Configure Stunnel Forwarding SSL Traffic
author: Galuh D Wijatmiko
categories: [Networks]
tags: [Stunnel,Network,SSL,PortForwarding]
draft: false
published: true
---

## FLOW


Client Hit to 2 Server

1. Client 10.100.100.1
   hit localhost 8081/tcp -> throw to Server A (Stunnel Server) Port 8087/tcp
   hit localhost 8082/tcp -> throw to Server B (Stunnel Server) Port 8088/tcp
2. Server A 10.100.100.2
   Listen 8087/tcp forward to 80/tcp
3. Server B 10.100.100.3
   Listen 8088/tcp forward to 80/tcp


## CONFIGURATION

>> Configure in All Server and Client
Install stunnel
```
yum install stunnel
```

Configure Certificate
```
cd /etc/pki/tls/certs/
make stunnel.pem
```

Chek Certificate
```
openssl x509 -noout -text  -in stunnel.pem
```
>> Configure in All Server and Client

Configure stunnel

in Mechine Client 

vi /etc/stunnel/stunnel.conf
```
cert = /etc/pki/tls/certs/stunnel.pem
pid = /var/run/stunnel/stunnel.pid
fips=no
debug = debug
output = /var/log/stunnel.log
client = yes

[serverA]
SSLversion=TLSv1.2
accept = localhost:8081
connect = 10.100.100.2:8087

[serverB]
SSLversion=TLSv1.2
accept = localhost:8082
connect = 10.100.100.3:8088

```

in Mechine Server A

vi /etc/stunnel/stunnel.conf
```
cert = /etc/pki/tls/certs/stunnel.pem
pid = /var/run/stunnel/stunnel.pid
fips=no
debug = debug
output = /var/log/stunnel.log
client = no

[serverA]
SSLversion=TLSv1.2
accept = 10.100.100.2:8087
connect = 10.100.100.2:80
```


in Mechine Server B

vi /etc/stunnel/stunnel.conf
```
cert = /etc/pki/tls/certs/stunnel.pem
pid = /var/run/stunnel/stunnel.pid
fips=no
debug = debug
output = /var/log/stunnel.log
client = no

[serverB]
SSLversion=TLSv1.2
accept = 10.100.100.3:8088
connect = 10.100.100.3:80

```

>> Configure in All Server and Client

Create Directory pid
```
mkdir /var/run/stunnel
chown nobody:nobody /var/run/stunnel
```

Running stunnel
```
stunnel /etc/stunnel/stunnel.conf
```

Check Service
```
ps -ef |grep stunnel
ss -tulpn | grep 8081
```

For change port change in apram accept in /etc/stunnel/stunnel.conf
kill service and restart

>> Configure in All Server and Client
