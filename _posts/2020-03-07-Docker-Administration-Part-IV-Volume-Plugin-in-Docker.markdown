---
layout: post
title: "[Docker Administration] [Part IV.B] Volume Plugin in Docker"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker,automation]
draft: false
published: true
---

- [GOAL](#goal)
    + [Volume Driver](#volume-driver)


### GOAL ###
> How implement Volume Sharing Between 2 Instance Using SSHFS.
>> VM2 nginx service will be read data in VM1 using SSHFS


The next Step continuous from [Docker Administration]({{ site.url }}/notes/2020/03/07/volume-in-docker/)

and we was create 2 instance in article [Docker Administration]({{ site.url }}/notes/2020/03/05/docker-administration-install-docker/), running again both instance :

```bash
vagrant up vm1 vm2
```

Generate SSH Keygen in both server
```bash
ssh-keygen -t rsa
```

Copy Public Key ssh vm2 to vm1
```bash
ssh-copy-id root@vm1
```

or you can add manually, in vm2
```bash
cat /root/.ssh/id_rsa.pub
```
put the output to vm1 in */root/.ssh/authorized_keys*

Modify /etc/hosts
```bash
echo -e "192.168.33.10 vm1.roomit.tech vm1 \n 192.168.33.11 vm2.roomit.tech vm2" >> /etc/hosts
```

##### Volume Driver #####

Remote Via SSH to vm1 and cretae directory
```bash
vagrant ssh vm1
sudo mkdir /data
sudo chmod 777 /data
exit
```

Install Plugin SSHFS in vm2
```bash
sudo docker plugin install --grant-all-permissions vieux/sshfs #install plugin
sudo docker plugin ls #list plugin
sudo docker plugin disable [PLUGIN ID] #disable plugin
sudo docker plugin set vieux/sshfs sshkey.source=/root/.ssh/ #set path authentication using ssh
sudo docker plugin enable [PLUGIN ID] #enable plugin
sudo docker plugin ls  #list plugin
```

Create Volume With SSHFS in vm2
```bash
sudo docker volume create --driver vieux/sshfs -o sshcmd=root@vm1:/data  -o allow_other sshvolume
```

Running Container with ssvolume in vm2
```bash
sudo docker run -d --name=nginxtest-ssh -p 8090:80 -v sshvolume:/usr/share/nginx/html nginx:latest
```

Login to vm1 and create index.html
```bash
vagrant ssh vm1
sudo sh -c "echo 'Hello, I am roomit' > /data/index.html"
sudo cat /data/index.html
exit
```

Execution in vm2
```bash
sudo docker ps
curl http://localhost:8090
```

Output:
```
Hello, I am roomit
```