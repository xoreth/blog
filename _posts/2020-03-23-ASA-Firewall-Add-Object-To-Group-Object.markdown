---
layout: post
title: "[ASA Firewall] Add Object To Group Object"
author: Galuh D Wijatmiko
categories: [Networks]
tags: [ASA,Cisco,Firewall]
draft: false
published: true
---



Create Object
```bash
conf t
object network dmz.webserver-01
host 182.253.30.82
```


Assign Object to Group
```bash
object-group network out.grp-webserver
network-object object dmz.webserver
```

