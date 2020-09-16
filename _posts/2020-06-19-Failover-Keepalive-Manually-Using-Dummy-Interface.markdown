---
layout: post
title: Failover Keepalive Manually Using Dummy Interface
author: Galuh D Wijatmiko
categories: [Server]
tags: [keepalived,failover,HA]
draft: false
published: true
---


Create Dummy Interface

```bash
 echo "modprobe dummy" >/etc/sysconfig/modules/rcsysinit.modules
 chmod +x /etc/sysconfig/modules/rcsysinit.modules
 modprobe -a dummy
 ```

Create network file for dummy module in /etc/sysconfig/network-scripts/ifcfg-dummy0
```bash
 DEVICE=dummy0
 BOOTPROTO=none
 IPV6INIT=no
 NAME="dummy0"
 ONBOOT=yes
 TYPE=Ethernet
 USERCTL=no
 NM_CONTROLLED="no"

 ```

Start dummy0 interface
```bash
 ifup dummy0
```
Install Keepalived in Both Server Maaster and Slave Node

Add track for interface dummy0 in vrrpd.conf or in keepalived.
```bash
 track_interface {
   ens160
   dummy0
 }
```

or we can add in keepalived config in /etc/keepalived/keepalived.conf in master node
```bash
global_defs {
   notification_email {
     admin@roomit.tech
   }
   notification_email_from madangkara@roomit.tech
   smtp_server localhost
   smtp_connect_timeout 30
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1
    track_interface {
        eth0
        dummy0
    }
    virtual_ipaddress {
        10.32.16.73
    }
}
```

and then we add config in slave node /etc/keepalived/keepalived.conf 
```bash
! Configuration File for keepalived

global_defs {
   notification_email {
     admin@roomit.tech
   }
   notification_email_from singasari@roomit.tech
   smtp_server localhost
   smtp_connect_timeout 30
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    track_interface {
        eth0
        dummy0
    }

    virtual_ipaddress {
        10.32.16.73
    }
}
```

How to switch IP or move ip virtual to slave node?
just shutdown dummy0 in maste node
```bash
 ifdown dummy0
```

and switch on dummy0 in slave node
```bash
ifup dummy0
```