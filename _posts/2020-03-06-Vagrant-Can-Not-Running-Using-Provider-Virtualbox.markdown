---
layout: post
title: Vagrant Can Not Running Using Provider Virtualbox
author: Galuh D Wijatmiko
categories: [Troubleshot]
tags: [vagrant]
draft: false
published: true
---

# Issue

> vagrant up failed, /dev/vboxnetctl: no such file or directory


# Fixing

1. sudo modprobe vboxdrv
2. sudo modprobe vboxnetadp - (host only interface)
3. sudo modprobe vboxnetflt - (make vboxnet0 accecible) 

References : [Stackoverflow](https://stackoverflow.com/questions/18149546/vagrant-up-failed-dev-vboxnetctl-no-such-file-or-directory)