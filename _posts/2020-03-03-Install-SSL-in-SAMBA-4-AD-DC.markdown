---
layout: post
title: Install SSL in SAMBA 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication,SecurityTunningAndHardening]
tags: [samba4,SSL,centos7,installation]
---

# General Information
To use TLS, Samba has to be compiled with --enable-gnutls. To verify, use the following command: 
```bash
  smbd -b | grep "ENABLE_GNUTLS"
  ENABLE_GNUTLS
```
1. The private key must be accessible without a passphrase, i.e. it must not be encrypted!
2. The files that samba uses have to be in PEM format (Base64-encoded DER). The content is enclosed between 
   e. g. 
   > \-\-\-\-\-BEGIN CERTIFICATE\-\-\-\-\- and \-\-\-\-\-END CERTIFICATE\-\-\-\-\-
3. When intermediate certificates are used they should be appended to the cert.pem file after the server certificate
   e. g.
   > roomit-int.tech.cert + roomit.tech.cert 

# Enable SSL SAMBA AD DC

in /etc/samba/smb.conf add under [global] option
```bash
        tls enabled  = yes
        tls keyfile  = /etc/samba/private/tls/roomitKey.pem
        tls certfile = /etc/samba/private/tls/roomitCert.pem
        tls cafile   = /etc/samba/private/tls/roomitIntermediate.pem
```
Change key certificate to 600 mode
```bash
  chmod 600 /etc/samba/private/tls/roomitKey.pem
```


# Enable port 389 Accessible

in /etc/samba/smb.conf add under [global] option
```bash
        client ldap sasl wrapping = sign
        ldap server require strong auth = no
```

# Restart SAMBA AD DC
```bash
 systemctl restart samba
```

# Check Certificate
```bash
 echo | openssl s_client -servername addc1.roomit.tech -connect addc1.roomit.tech:636 2>/dev/null
```
