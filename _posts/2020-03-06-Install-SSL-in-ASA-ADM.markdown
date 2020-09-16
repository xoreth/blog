---
layout: post
title: Install SSL in ASA ADM
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [SSL]
draft: false
published: true
---


## Convert Certificate PEM to PKCS#12 ##
```bash
  openssl pkcs12 -export -out roomit.tech.pfx -inkey roomit.tech.key -in roomit.tech.crt -certfile roomit.tech-int.crt
```

Assign Password standard : **roomit**

## Install To ASA Firewall ##
1. Login ASDM

2. Click Configuration -> Device Management -> Certificate Management -> Identity Certificate

3. Add
```bash
    Trustpoint = ssl-new-2019-2020
    File to Import Form = roomit.tech.pfx
    Decryption Passpharse = roomit
```
4. Add Certificate     

5. Apply
