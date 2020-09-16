---
layout: post
title: "Install Consul Server"
author: Galuh D Wijatmiko
categories: [ServiceDiscovery]
tags: [consul]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


## Preparation
> vm1 192.168.33.13 vm1.roomit.tech

> vm2 192.168.33.14 vm2.roomit.tech

Download Package:
```bash
# wget https://releases.hashicorp.com/consul/1.7.1/consul_1.7.1_linux_amd64.zip
```

Install Tools Support:
```bash
# apt install unzip nginx 
```

Setting Host
set this alias dns on your host, vm1, vm2, and vm3
```bash
# echo -e "
192.168.33.10 vm1.roomit.tech vm1\n
192.168.33.11 vm2.roomit.tech vm2 \n
192.168.33.12 vm3.roomit.tech vm3" >> /etc/hosts
```
> notes: in this tutorial we only using one server vm1

Create user consul
```bash
# useradd consul
# passwd consul
```

Create Heirarchy:
```bash
/opt/consule-server/
├── bin
├── cfg
└── data
```

```bash
# mkdir -p /opt/consule-server/{bin,cfg,data}
# chown consul:consul -R /opt/consule-server
```



## Installation 
Extract and save path binary to environment
```bash 
# unzip consul_1.7.1_linux_amd64.zip -d /opt/consule-server/bin/
# chmod +x /opt/consule-server/bin/consul
# echo "export PATH=$PATH:/opt/consule-server/bin" >> ~/.bashrc 
# source ~/.bashrc
```

## Configuration
Generate Keygen
```bash
# consul keygen

myjwslBVOrz3amfAJuyLVxGSqcsvPGX+cmZIgZVRK7U=
```
Create file and config in /opt/consule-server/cfg/config.json
```bash
{
"bootstrap": true,
"server": true,
"log_level": "DEBUG",
"enable_syslog": true,
"datacenter": "Tendean",
"addresses" : {
"http": "127.0.0.1"
},
"bind_addr": "192.168.33.10",
"node_name": "vm1",
"data_dir": "/opt/consule-server/data/",
"primary_datacenter": "Tendean",
"acl_default_policy": "allow",
"encrypt": "myjwslBVOrz3amfAJuyLVxGSqcsvPGX+cmZIgZVRK7U="
}
```
Create virtualhost /etc/nginx/site-available/consule
```bash
server
{
  listen 80 ;
  server_name vm1.roomit.tech;
  root /opt/consule-server/cfg/ui;
      location / {
        proxy_pass http://127.0.0.1:8500;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
    }
}
```
Enable and Check Config
```bash
# ln -sf /etc/nginx/sites-available/consule  /etc/nginx/sites-enabled/
# nginx -t
```
Create Systemd Init /lib/systemd/system/consul.service
```bash
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=consul
Group=consul
LimitNOFILE=1024
PermissionsStartOnly=true
Environment="OPTIONS=-server -ui -client 192.168.33.10 -advertise 192.168.33.10"   
ExecStart=/opt/consule-server/bin/consul agent $OPTIONS  -config-dir /opt/consule-server/cfg/
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
```
Reload
```bash
# systemctl daemon-reload
```

Running Nginx
```bash
# systemctl start nginx
```

Access Web
> http://vm1.roomit.tech


![DashboarConsul](/assets/images/data_blog/dashboardConsul.png)