---
layout: post
title: Error Consul No installed keys could decrypt the message
author: Galuh D Wijatmiko
categories: [Troubleshot]
tags: [consul]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


We got error in consul log like
```bash
Mar 17 06:21:23 vm2 consul[13954]:  agent: Started HTTP server: address=127.0.0.1:8500 network=tcp
Mar 17 06:21:23 vm2 consul[13954]:  agent: (LAN) joining: lan_addresses=[192.168.33.10]
Mar 17 06:21:23 vm2 bash[13954]:     2020-03-17T06:21:23.947Z [WARN]  agent: (LAN) couldnt join: number_of_nodes=0 error=1 error occurred:
Mar 17 06:21:23 vm2 bash[13954]: #011* Failed to join 192.168.33.10: No installed keys could decrypt the message
Mar 17 06:21:23 vm2 bash[13954]: 
```

How to Fix:
1. Go to data consul, in our tutorial we stored in 

    * /opt/consule-server/data. References : [How To Install Consul Server]({{ site.url }}/notes/2020/03/15/install-consule-service-discovery/)
    * /opt/consule-client/data. References : [How To Install Consul Agent]({{ site.url }}/notes/2020/03/17/install-consul-agent/)

1. You can delete all in ./data/*
```bash
rm -rf ./data/*
```

> This is data service will be remove also.

The Best Solution is :

1.  Added the current encryption key in "local.keyring"

And Restart consul agent or server what you got error
```bash
systemctl restart consul
```