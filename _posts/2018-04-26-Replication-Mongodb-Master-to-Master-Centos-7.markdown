---
layout: post
title: Replication MongoDB Master to Master Centos 7
author: Galuh D Wijatmiko
categories: [Databases]
tags: [mongodb,replication,database,centos7]
---

#### Replication Master-Master Mongodb Centos 7 ####

Create Vagrant VM and Running VM

```bash
git clone https://gist.github.com/7b43350b3a7a467cc0dd2408c0de9ff5.git VMmongo
cd VMmongo
vagrant up node1
vagrant up node2
```

Turn Off Service mongodb in all nodes and create DB directory

```bash
systemctl stop mongod
mkdir -p /data/db
chown mongod:mongod -R /data/db/
```

Edit /etc/mongod.conf in all nodes

```bash
#   http://docs.mongodb.org/manual/reference/configuration-options/

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

storage:
  dbPath: /data/db
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/db/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0  # Listen to local interface only, comment to listen on all interfaces.


#security:

#operationProfiling:

replication:
  replSetName: repWJT

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
```


Change systemd init file in /usr/lib/systemd/system/mongod.service in all nodes

```bash
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target
Documentation=https://docs.mongodb.org/manual

[Service]
User=mongod
Group=mongod
Environment="OPTIONS=-f /etc/mongod.conf"
ExecStart=/usr/bin/mongod $OPTIONS
ExecStartPre=/usr/bin/mkdir -p /var/run/mongodb
ExecStartPre=/usr/bin/chown mongod:mongod /var/run/mongodb
ExecStartPre=/usr/bin/chmod 0755 /var/run/mongodb
PermissionsStartOnly=true
PIDFile=/data/db/mongod.pid
Type=forking
# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false
# Recommended limits for for mongod as specified in
# http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings

[Install]
WantedBy=multi-user.target
```

Start and Check Listen Port in all nodes

```bash
# systemctl start mongod
# ss -tulpn | grep 27017
tcp    LISTEN     0      128       *:27017                 *:*                   users:(("mongod",pid=6663,fd=11))
```



