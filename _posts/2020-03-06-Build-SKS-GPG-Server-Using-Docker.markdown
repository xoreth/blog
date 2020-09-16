---
layout: post
title: Build SKS GPG Server Using Docker
author: Galuh D Wijatmiko
categories: [Container]
tags: [Docker,Container,Security]
draft: false
published: true
---


## Installation ##
The SKS-Keyserver will be installed and running on Docker containers. There will be two docker images used:
* sks-keyserver : contains the main program and DB for the SKS keyserver.
* sks-nginx : will act as the front-end web for GUI access.


## Building SKS-Keyserver Image ##
### Files and configurations ###
Directory structure for SKS-Keyserver image.
```bash
sks-keyserver
 ├──bin
 │   ├──sks-init
 │   └──sks-start
 ├──conf
 │   └──sksconf
 ├──Dockerfile
 └──s6
     └──services.d
         ├──sks-db
         │   ├──finish
         │   └──run
         └──sks-recon
             └──run 
```
Following are details for each file used for image.<br/>
sks-keyserver/bin/sks-init:
```bash
  #!/bin/bash
  service sks stop
  su debian-sks -c '/usr/sbin/sks build'
```
sks-keyserver/bin/sks-start:
```bash
  #!/bin/bash
  service sks start
```

sks-keyserver/conf/sksconf:
```bash
debuglevel: 7
hostname: sks.roomit.tech
recon_address: 0.0.0.0
recon_port: 11370
hkp_address: 0.0.0.0
hkp_port: 11371
initial_stat:
disable_mailsync:
pagesize: 16
ptree_pagesize: 16
```

sks-keyserver/Dockerfile
```bash
FROM ubuntu:bionic

USER root

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /
RUN apt-get update && apt-get install -y sks && \
    service sks stop && \
    #su debian-sks -c '/usr/sbin/sks build' && \
    echo '# Empty - Do not communicate with other keyservers.' >/etc/sks/mailsync && \
    echo '# Empty - Do not communicate with other keyservers.' >/etc/sks/membership && \
    rm /etc/sks/sksconf && \
    apt-get install -y net-tools iproute2 && \
    apt-get purge

COPY conf/sksconf /etc/sks/
COPY s6 /etc/
COPY bin /usr/bin/

RUN chown debian-sks:debian-sks /var/lib/sks
RUN mkdir /var/run/sks

EXPOSE 11371 11370

VOLUME /var/lib/sks

CMD ["/init"]
```
sks-keyserver/s6/services.d/sks-db/finish:
```bash
  #!/bin/execlineb -S1

  if { s6-test ${1} -ne 0 }
  if { s6-test ${1} -ne 256 }
```

sks-keyserver/s6/services.d/sks-db/run:
```bash
  #!/bin/execlineb -P
  sks -stdoutlog db
```
sks-keyserver/s6/services.d/sks-recon/run:
```bash
  #!/bin/execlineb -P
  foreground
  {
    s6-svwait /var/run/s6/services/sks-db
  }
  sks -stdoutlog recon
```
### Build image ###
Build from Dockerfile.
```bash
  $ docker build -t roomit/sks-keyserver:latest sks-keyserver/.
```

## Building SKS-Nginx image ##
### Download and configure source code ###
The sks-nginx image can be found on Dockerhub [https://hub.docker.com/r/jtbouse/sks-nginx here]. But we will download the source since we need to modify some configuration inside to match our environment.
```bash
  $ git clone <nowiki>https://github.com/UGNS/sks-nginx.git</nowiki>
```

Configure file sks-nginx/nginx/conf.d/default.conf
```bash
  $ vi sks-nginx/nginx/conf.d/default.conf
```
Edit as following example.
```bash
  server {
      listen 80 default_server;
      listen 11371 default_server;
      '''access_log /var/log/nginx/access.log  main;'''               
      server_tokens off;
      root   /usr/share/nginx/html;
      index  index.html index.htm;
  
      location /pks {
          proxy_pass <nowiki>http://sks:11371;</nowiki>
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Port $server_port;
          proxy_pass_header Server;
          proxy_ignore_client_abort on;
          add_header Via "1.1 sks.roomit.tech:$server_port (nginx)";
          client_max_body_size 8m;
      }
  }
  
  server {
      listen 443 default_server ssl;
      '''access_log /var/log/nginx/access_ssl.log  main;'''
      server_tokens off;
      root   /usr/share/nginx/html;
      index  index.html index.htm;
      #auth_basic "Asking User and Passwd";
      #auth_basic_user_file /usr/share/nginx/html/htpasswd/.htpasswd;
  
      #ssl_certificate /etc/ssl/certs/sks.undergrid.net.crt;
      '''ssl_certificate /etc/ssl/certs/roomit.crt;'''
      #ssl_certificate_key /etc/ssl/private/sks.undergrid.net.key;
      '''ssl_certificate_key /etc/ssl/private/roomit.key;'''
      '''ssl_trusted_certificate /etc/ssl/certs/sks-keyservers.net.ca.crt;'''
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
      ssl_prefer_server_ciphers on;
      ssl_dhparam /etc/ssl/dhparams.pem;
      ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;
  
      location /pks {
          proxy_pass <nowiki>http://sks:11371;</nowiki>
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Port $server_port;
          proxy_pass_header Server;
          proxy_ignore_client_abort on;
          add_header Via "1.1 sks.roomit.tech:$server_port (nginx)";
          client_max_body_size 8m;
      }
  }
```

### Build image ###
Build from sks-nginx Dockerfile.
```bash
  $ docker build -t roomit/sks-nginx:latest sks-nginx/.
```

## Docker Compose ##
We will deploy sks-keyserver and sks-nginx docker with docker compose. First create the prerequisite directory and files for container volume. In this example, we will configure them under **sks** directory.
```bash
sks
 ├──docker-compose.yml
 ├──log
 ├──sks-data
 └──ssl
     ├──certs
     │   ├──roomit.crt
     │   └──sks-keyservers.net.ca.crt
     ├──dhparams.pem
     └──private
         └──roomit.key
```

Create docker-compose.yml file as follow.
```bash
version: '3'

services:
  sks:
    container_name: sks-keyserver
    image: roomit/sks-keyserver
    hostname: sks.roomit.tech
    networks:
      - sks-networks
    volumes:
      - "./sks-data:/var/lib/sks"
    ports:
      - "10.32.16.97:11370:11370"
    #entrypoint:
    # - sks-init
  sks-fe:
    container_name: sks-fe
    image: roomit/sks-nginx:2.0
    depends_on:
      - sks
    ports:
      - "10.32.16.97:11371:11371"
      - "10.32.16.97:443:443"
      - "10.32.16.97:80:80"
    networks:
      - sks-networks
    volumes:
      - "./ssl:/etc/ssl"
      - "./log:/var/log/nginx"

networks:
  sks-networks:
```

Create the directory.
```bash
  $ mkdir log sks-data ssl
```

'log' directory will be used to store access.log from nginx. 'sks-data' directory will be used to store DB for SKS keys.<br/>
On 'ssl' directory, put the certificate that you want to use. In this example we use 'roomit.crt', 'roomit.key' and 'sks-keyservers.net.ca.crt'. Finally don't forget to generate dhparam and put under ssl directory, in this example we create 'dhparams.pem'.<br/>



## Operations Guide ##
#### Initial run ###
For the first time when starting up SKS-Keyserver, we need to generate the DB. To do that, in the docker-compose.yml file uncomment **entrypoint** parameter (line 14,15).<br/>
From this:
```bash 
 ...
    #entrypoint:
    # - sks-init
  ...
```
to this:
```bash  
  ...
    entrypoint:
     - sks-init
  ...
```

Run docker compose.
```bash
  $ docker-compose up
```

After successfully run, the container will stop by itself (if not you can manually stop the compose with Ctrl-C). Then check inside directory **sks-data**. Make sure there're folder **PTree** and **DB**. If those two folder didn't generated, then check for error in docker-compose logs when running them.
```bash
  $ [app@cnthost-1 sks]$ ls -lrth sks-data/
  total 0
  drwx------ 2 root root  89 Okt  7 09:07 PTree
  drwx------ 2  101  101 166 Okt  7 09:07 DB
```

### Start/Stop the SKS keyserver ###
To start the SKS-Keyserver containers, run docker-compose from the 'sks' directory.
```bash
  $ docker-compose up -d
```

To stop the SKS-Keyserver containers:
```bash
  $ docker-compose down
```

To list status of running containers:
```bash
  $ docker container ls
```

### Remove certain keys from SKS keyserver ###
To remove specific keys from SKS-Keyserver, we need to access the container console.
 ```bash
  $ docker exec -it sks-keyserver /bin/bash
  root@sks:/# 
```

Delete key entry by using key 32-digit HASH. 
```bash
  root@sks:/# sks drop F91CFEB5FA138F159D8341C0E124B06A
  2019-11-14 09:25:41 Marshalling: DeleteKey F91CFEB5FA138F159D8341C0E124B06A
  2019-11-14 09:25:41 Unmarshalling: Ack: 0
```


Upload Your Key
```bash
gpg --keyserver sks.roomit.tech --send-key yourKeys
```