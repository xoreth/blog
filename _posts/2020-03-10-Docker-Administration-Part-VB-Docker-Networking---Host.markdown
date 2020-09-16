---
layout: post
title: "[Docker Administration] [Part V.B] Docker Networking - Host"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker,networking,container]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


# Host Network

Running nginx
```bash
sudo docker run --rm -itd --network host --name my_nginx nginx
```

Show Container Status
```bash
sudo docker container ls
```

we can not see port binding in level container, port will be attahed in *your host*.

verify with
```bash
ss -tulpn | grep 80
```
Output:
```bash
tcp     LISTEN   0        511              0.0.0.0:80            0.0.0.0:*       users:(("nginx",pid=19858,fd=6),("nginx",pid=19844,fd=6))     
```

Test with curl
```bash
curl http://localhost
```

Remove Container
```bash
sudo docker container rm my_nginx
```

