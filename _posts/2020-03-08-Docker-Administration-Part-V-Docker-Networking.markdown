---
layout: post
title: "[Docker Administration] [Part V.A] Docker Networking - Bridge"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker,automation,container,networks]
draft: false
published: true
---

# Table Of Contents
- [BRIDGE NETWORK](#bridge-network)
  * [Default Bridge](#default-bridge)
  * [User-Defined Bridge Network](#user-defined-bridge-network)

## BRIDGE NETWORK

### Default Bridge
Show Network
```bash
sudo docker network ls
```

Running 2 Container Alpine run ASH
```bash
sudo docker run -dit --name con1 alpine ash
sudo docker run -dit --name con2 alpine ash
```

Show Container
```bash
sudo docker container ls
```

Show Network
```bash
sudo docker network ls
```

Inspect Bridge Network
```bash
sudo docker network inspect bridge
```

enter to con1
```bash
sudo docker attach con1
```

show ip in con1
```bash
ip add
```

Ping IP to Google DNS [Status must Success]
```bash
ping -c 3 8.8.8.8
```
Ping to Another Container, Before that search IP Address con2   [Status must Success]

```bash
docker container inspect con2 | grep -i IPAddress
ping 172.17.0.2
```
Ping Name Of Container
```bash
ping -c 3 con2
```

Dettach container
```bash
Ctrl+P, Ctrl+Q
```
Remove 2 container
```bash
sudo docker container rm -f con1 con2
```

### User-Defined Bridge Network 

create bridge network for login-service
```bash
sudo docker network create --driver bridge login-net
```

Show Networks
```bash
sudo docker network ls
```

Show Details login-net
```bash
sudo docker network inspect login-net
```
Scenario :
> 1. con1 connect to default bridge
> 2. con2 connect to network login-net
> 3. con3 connect to default bridge and login-net

The Result :
> 1. con1 can not connect to con2, but able ping to con3
> 2. con2 can not connect to con1, but able ping to con3
> 3. con3 can ping ip all container, but can not able ping name of container con1
> 4. All container able ping to internet


Running container con1
```bash
sudo docker run -dit --name con1 alpine ash
```

Running container con2 with login-net network
```bash
sudo docker run -dit --name con2 --network login-net alpine ash
```

Running container con3 with default network
```bash
sudo docker run -dit --name con3 alpine ash
````
Check Detail Network con3
```bash
sudo docker container inspect con3
```

How to connect container con3 with default network bridge to netowrk login-net
```bash
sudo docker network connect login-net con3
```
Check Detail Network con3
```bash
docker container inspect con3
```
Now con3 have 2 network interface, for make sure login to con3 
```bash
docker container exec -it con3 ash
ip add
```

List container
```bash
sudo docker container ls
```

Show Detail network bridge and login-net
```bash
sudo docker network inspect bridge
sudo docker network inspect login-net
```
Login to con3 and ping to all container
```bash
sudo docker attach con3
ping -c 3 172.17.0.2 #con1 [Success]
ping -c 3 con1 #[Failed]
ping -c 3 con2 #[Success]
```

Login to con2 and ping to all container
```bash
ping -c 3 172.17.0.2 #con1 [Failed]
ping -c 3 con1 #[Failed]
ping -c 3 con3 #[Success]
```

Ping Internet
Login to con1 and ping to 8.8.8.8
```bash
docker container exec -it con1 ash
ping 8.8.8.8 #[success]
```

Login to con2 and ping to 8.8.8.8
```bash
docker container exec -it con2 ash
ping 8.8.8.8 #[success]
```

Login to con3 and ping to 8.8.8.8
```bash
docker container exec -it con3 ash
ping 8.8.8.8 #[success]
```

If you can not ping to outside enable forward in your host
```bash
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
```

Remove All Container and Network
```bash
sudo docker container rm -f con1 con2 con3
sudo docker network rm login-net
```
