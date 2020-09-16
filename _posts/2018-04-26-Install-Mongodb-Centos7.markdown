---
layout: post
title: Install MongoDB Centos 7
author: Galuh D Wijatmiko
categories: [Databases]
tags: [mongodb,replication,database,centos7,installation]
---


#### Install MongoDB Centos 7###

Disable selinux

```bash
# setenforce 0
# sed -i 's/SELINUX\=permissive/SELINUX=disabled/' /etc/selinux/config
# reboot
# sestatus
SELinux status:                 disabled
```


Configure Repo

```bash
cat > /etc/yum.repos.d/mongodb-org-3.6.repo << EOF
[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
EOF
```


Install MONGODB

```bash
yum install -y mongodb-org
```


Enable At Start up and Start Service

```bash
systemctl enable mongod && systemctl start mongod
```
