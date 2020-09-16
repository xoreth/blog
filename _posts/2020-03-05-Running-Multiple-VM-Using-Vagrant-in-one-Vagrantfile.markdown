---
layout: post
title: "[Vagrant] Running Multiple VM Using Vagrant in one Vagrantfile"
author: Galuh D Wijatmiko
categories: [Provisioning]
tags: [vagrant,automatic]
---


The first, make sure we was intall vagrant.
[Install Vagrant]({{site.url}}/notes/2017/02/23/install-and-run-vagrant/)

> We are using ubuntu bionic 64

Create Folder and Code your VM using ruby
```bash
mkdir -p myVM
cd myVM
vim Vagrantfile
```

```bash
Vagrant.configure("2") do |config|

config.vm.box_check_update = false	
config.vbguest.auto_update = false

config.vm.define "vm1" do |vm1|
  vm1.vm.box = "ubuntu/bionic64"
  vm1.vm.hostname = "vm1.roomit.tech"
  vm1.vm.network "private_network", ip: "192.168.33.10"
  vm1.vm.provider "virtualbox" do |vb|
     vb.name = "vm1"
     vb.memory = "1024"
  end
end

config.vm.define "vm2" do |vm2|
  vm2.vm.box = "ubuntu/bionic64"
  vm2.vm.hostname = "vm2.roomit.tech"
  vm2.vm.network "private_network", ip: "192.168.33.11"
  vm2.vm.provider "virtualbox" do |vb|
     vb.name = "vm2"
     vb.memory = "1024"
  end
end

config.vm.define "vm3" do |vm3|
  vm3.vm.box = "ubuntu/bionic64"
  vm3.vm.hostname = "vm3.roomit.tech"
  vm3.vm.network "private_network", ip: "192.168.33.13"
  vm3.vm.provider "virtualbox" do |vb|
     vb.name = "vm3"
     vb.memory = "1024"
  end
end

end
```

Running Your 3 VM
```bash
vagrant up vm1 vm2 vm3 --provider=virtualbox
```
 I am using virtualbox for virtualzation


> note

*If you need  only one VM, please only doit*
```bash
vagrant init ubuntu/bionic64
```


