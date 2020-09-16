---
layout: post
title: "[Docker Administration] [Part IV.A] Volume Local in Docker"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker,volume,Fileshare]
draft: false 
published: true
---

# Table Of Contents
- [VOLUME LOCAL DRIVER](#volume-local-driver)
  * [Share Host Part I](#share-host-part-i)
  * [Share Host to Container (Absolute Path) Part II](#share-host-to-container--absolute-path--part-ii)


The next Step continuous from [Docker Administration]({{ site.url }}/notes/2020/03/06/publish-your-image-docker/)

How Share File From Host To Container or biderectional:

# VOLUME LOCAL DRIVER
## Share Host Part I
Create Volume
```bash
sudo docker volume create first-volume
```

Show list Volume
```bash
sudo docker volume ls
```

Show detail volume
```bash
sudo docker volume inspect first-volume
```

Running Service Nginx With Container
```bash
sudo docker run -d --name=nginxtest -v first-volume:/usr/share/nginx/html nginx:latest
```

Show Ip Address Docker
```bash
sudo docker inspect nginxtest | grep -i ipaddress
```

Testing
```bash
curl http://172.17.XXX.XXX
```

Create file index.html and in Mount Point Volume Docker Data
```bash
su - root
echo "This is from first-volume source directory." > /var/lib/docker/volumes/first-volume/_data/index.html
```

Test Again
```bash
curl -sLi http://172.17.XXX.XXX
```

Output :
```bash
HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Sat, 07 Mar 2020 11:46:12 GMT
Content-Type: text/html
Content-Length: 44
Last-Modified: Sat, 07 Mar 2020 11:44:33 GMT
Connection: keep-alive
ETag: "5e638921-2c"
Accept-Ranges: bytes

This is from first-volume source directory.
```

Setup Volume Readonly, add _:ro_ 
```bash
sudo docker run -d --name=nginxtest-ro-vol -v first-volume:/usr/share/nginx/html:ro nginx:latest
```
## Share Host to Container (Absolute Path) Part II
Share folder /usr/share/nginx/html into Hosts

```bash
mkdir -p Project/LAMP/www
cd Project/LAMP
echo "test" > www/index.html
pwd
```
save result _pwd_, my result is /home/vagrant/Project/LAMP

Running Container
```bash

sudo docker run -d --name=nginxtest-mount-www -v /home/vagrant/Project/LAMP/www/:/usr/share/nginx/html nginx:latest
```

Find IP COntainer nginxtest-mount-www
```bash
sudo docker container inspect -f '\{\{\.NetworkSettings.Networks.bridge.IPAddress\}\}' nginxtest-mount-www
```
or simple way
```bash
sudo docker container inspect  nginxtest-mount-www | grep IPAddress
```
Testing
```bash
curl -sLi http://172.17.0.5
```

Output :

```bash
HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Sat, 07 Mar 2020 12:15:13 GMT
Content-Type: text/html
Content-Length: 5
Last-Modified: Sat, 07 Mar 2020 12:02:42 GMT
Connection: keep-alive
ETag: "5e638d62-5"
Accept-Ranges: bytes

test
```