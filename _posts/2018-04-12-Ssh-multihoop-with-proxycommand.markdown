---
layout: post
title: SSH Multihop
author: Galuh D Wijatmiko
categories: [Server]
tags: [ssh]
---


#### ProxyCommand ####

Flow

###### Workstation -> server1 -> server2 ######

access from workstation to server2 via server1


If DNS not avaiable please create DNS Locally in Workstation, Server1 and Server2

```bash

echo "10.32.56.1 Server1" >> /etc/hosts
echo "10.10.100.2 Server2" >> /etc/hosts

```


modify file config ssh :


```bash


Host server1
       IdentityFile ~/.ssh/id_rsa
       user senops
Host server2
       ProxyCommand ssh -q server1 nc server2 22
       user userserver2


```

How Play?

```bash

ssh server2

```
