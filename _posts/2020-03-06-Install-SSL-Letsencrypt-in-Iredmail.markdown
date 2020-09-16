---
layout: post
title: Install SSL Letsencrypt in Iredmail
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [SSL,Iredmail]
draft: false
published: true
---


To install an SSL certificate for iRedMail, you need to specify it in the Dovecot, Postfix and Apache2 configuration.
Specify the certificate in Dovecot, to do this, open the configuration file in a text editor  **/etc/dovecot/dovecot.conf**

Find the lines:
```bash
ssl_cert = </etc/ssl/certs/iRedMail.crt
ssl_key = </etc/ssl/private/iRedMail.key
```

And change them to your certificate (say, from Let’s Encrypt):
```bash
ssl_cert = </etc/letsencrypt/live/ixnfo.com/cert.pem
ssl_key = </etc/letsencrypt/live/ixnfo.com/privkey.pem
```

Now open the Postfix configuration:
```bash
sudo vim /etc/postfix/main.cf

smtpd_tls_key_file = /etc/ssl/private/iRedMail.key
smtpd_tls_cert_file = /etc/ssl/certs/iRedMail.crt
smtpd_tls_CAfile = /etc/ssl/certs/iRedMail.crt
smtpd_tls_CApath = /etc/ssl/certs
```

And change them to your certificate (say, from Let’s Encrypt):
	
```bash
smtpd_tls_key_file = /etc/letsencrypt/live/ixnfo.com/privkey.pem
smtpd_tls_cert_file = /etc/letsencrypt/live/ixnfo.com/cert.pem
smtpd_tls_CAfile = /etc/letsencrypt/live/ixnfo.com/chain.pem
smtpd_tls_CApath = /etc/letsencrypt/live/ixnfo.com
```

Well, it remains to open the configuration of Apache2:
```bash
sudo vim /etc/apache2/sites-enabled/default-ssl.conf

SSLCertificateFile /etc/ssl/certs/iRedMail.crt
SSLCertificateKeyFile /etc/ssl/private/iRedMail.key
```
And change them:
```bash
SSLCertificateFile /etc/letsencrypt/live/ixnfo.com/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/ixnfo.com/privkey.pem
```
To apply the changes, restart Dovecot, Postfix, Apache2 and make sure that they are successfully launched:
```bash	
sudo systemctl restart dovecot postfix apache2
```

Look status :
```bash
sudo systemctl status dovecot postfix apache2
```
