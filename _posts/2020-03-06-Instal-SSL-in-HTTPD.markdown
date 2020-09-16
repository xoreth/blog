---
layout: post
title: Instal SSL in HTTPD
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [SSL]
draft: false
published: true
---


Open your vhost, and add line :

```bash
<VirtualHost *:443>
......
        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
        SSLCertificateFile /etc/httpd/cacerts/roomit.tech.crt
        SSLCertificateKeyFile /etc/httpd/cacerts/roomit.tech.key
        SSLCertificateChainFile /etc/httpd/cacerts/roomit.tech-int.crt
.......
</VirtualHost>
```
