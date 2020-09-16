---
layout: post
title: Install Consul Agent
author: Galuh D Wijatmiko
categories: [ServiceDiscovery]
tags: [Consul]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---

## Prepartion
> vm1 192.168.33.13 vm1.roomit.tech as consul server

> vm2 192.168.33.14 vm2.roomit.tech as consul client

You have already install Consul Server in vm1.
this is link : [How To Install Consul Server]({{ site.url }}/notes/2020/03/15/install-consule-service-discovery/)

Runnig up both VM
```bash
vagrant up vm1 vm2
```

running consul server in vm1
```bash
vagrant ssh vm1
systemctl start consul
```

Login vm2 and add user consul
```bash
vagrant ssh vm2
useradd consul
passwd consul
```

## Installation
Install Tools
```bash
apt install unzip -y wget
```

Download Package
```bash
wget -c  https://releases.hashicorp.com/consul/1.7.1/consul_1.7.1_linux_amd64.zip
```

Hiearachy
```bash
/opt/consule-client/
├── bin
├── cfg
└── data
```

```bash
mkdir -p /opt/consule-client/{bin,cfg,data}
chown consul:consul -R /opt/consule-client
```

Install and Save Path Environment
```bash
unzip consul_1.7.1_linux_amd64.zip -d /opt/consule-client/bin/
chmod +x /opt/consule-client/bin/consul
echo "export PATH=$PATH:/opt/consule-client/bin" >> ~/.bashrc 
source ~/.bashrc
```

Generate Keys
```bash
consul keygen
j4j7yRLgC0JfKu0tT05xlINH56k3R6c0S1L2K1cCuYw=
```

Configure Consul Client in /opt/consule-client/cfg/config.json
```bash
{
    "server": false,
    "datacenter": "Tendean",
    "data_dir": "/opt/consule-client/data/",
    "encrypt": "InWruaxMIrBj64pd4d+FmhH57A3jw3RzCaIdLVxt+vA=",
    "log_level": "INFO",
    "enable_syslog": true,
    "leave_on_terminate": true,
    "addresses" : {
         "http": "127.0.0.1"
    },
    "bind_addr": "192.168.33.11",
    "start_join": [
        "192.168.33.10"
    ]
}

```

Create Systemd init in /etc/systemd/system/consul-client.service
```bash
[Unit]
Description=Consul Startup process
After=network.target
 
[Service]
Type=simple
Type=simple
User=consul
Group=consul
ExecStart=/bin/bash -c '/opt/consule-client/bin/consul agent -config-dir /opt/consule-client/cfg/'
TimeoutStartSec=0
 
[Install]
WantedBy=default.target
```

Reload Daemon
```bash
systemctl daemon-reload
```

Start Service 
```bash
systemctl start consul-client
```

Check Service
```bash
systemctl start consul-client
```

If Success Go to vm1 and check members
```bash
root@vm1:/opt/consule-server/data/serf# consul members
Node  Address             Status  Type    Build  Protocol  DC       Segment
vm1   192.168.33.10:8301  alive   server  1.7.1  2         tendean  <all>
vm2   192.168.33.11:8301  alive   client  1.7.1  2         tendean  <default>

```

