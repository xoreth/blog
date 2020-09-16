---
layout: post
title: Netplan Config
author: Galuh D Wijatmiko
categories: [Networks]
tags: [UbuntuNetwork,Networks,SetIPAddress]
draft: false
published: true
---

## Static IP
create file in /etc/netplan/myNetworks.yaml
```bash
network:
  version: 2
  renderer: NetworkManager
  ethernets: 
    enp0s25:
        dhcp4 : no 
        addresses : [10.32.5.9/24]
        gateway4 : 10.32.5.254
        nameservers: 
            addresses : [10.32.16.237,8.8.8.8]
```

or for setting dynamic IP

## Dynamic IP
```bash
network:
  version: 2
  renderer: NetworkManager
  ethernets: 
    enp0s25:
        dhcp4 : true 
        addresses : []
        optional : true
```


Try Config :
```bash
$ sudo netplan try
```

For Apply Config:
```bash
$ sudo netplan apply
``

