---
layout: post
title: Renew SSL For Rhevm
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [SSL,RHEVM,Virtualization]
draft: false
published: true
---


##Check current certificate in RHEV Node##

For example, rhev-node IP is 10.32.5.67.

Login via ssh to 10.32.5.67, and type following command :
```bash
   openssl x509 -in /etc/pki/vdsm/certs/vdsmcert.pem -text -noout
```
Check expiration date.

##Create CSR in RHEV Node##

Login to RHEV Node., eg : rhev-c with IP 10.32.5.67

Create temporary directory for creating csr :
```bash
  mkdir gen-cert
  cd gen-cert/
```
Copy rhev node key to temporary directory.
```bash
  cp /etc/pki/vdsm/keys/vdsmkey.pem .
```
Create csr config file.
```bash
  vi 10.32.5.67.conf
```
Content of csr config file as following.
```bash
  RANDFILE = ~/.rnd
  [ req ]
  distinguished_name = req_distinguished_name
  prompt = no

  [ v3_ca ]
  subjectKeyIdentifier=hash
  authorityKeyIdentifier=keyid:always,issuer:always
  basicConstraints = CA:true

  [ req_distinguished_name ]
  O = roomit.tech
  CN = 10.32.5.67
```

Create csr certificate.
```bash
  openssl req -new -key vdsmkey.pem -out 10.32.5.67.req -config 10.32.5.67.conf
```
Check csr file.
```bash
  openssl req -text -noout -verify -in 10.32.5.67.req
```
Copy to csr to rhevm
```bash
  scp 10.32.5.67.req root@rhevm:/etc/pki/ovirt-engine/requests/
```

##Sign CSR in RHEV-M##

Login to RHEVM as room, and go to ovirt bin folder.
```bash
  cd /usr/share/ovirt-engine/bin
```
Create enroll request for rhev-c (IP : 10.32.5.67).
```bash
  ./pki-enroll-request.sh --name=10.32.5.67 --subject=/O=rhev-c.roomit.tech/CN=10.32.5.67 --days=180
```

**Output :**
```bash
  0
  Using configuration from openssl.conf
  Check that the request matches the signature
  Signature ok
  The Subject's Distinguished Name is as follows
  organizationName      :PRINTABLE:'rhev-c.roomit.tech'
  commonName            :PRINTABLE:'10.32.5.67'
  Certificate is to be certified until Jun  1 13:49:15 2024 GMT (1800 days)

  Write out database with 1 new entries
  Data Base Updated
```
Copy certificate to to RHEV node, rhev-c.
```bash
  scp /etc/pki/ovirt-engine/certs/10.32.5.67.cer root@10.32.5.67:/root/gen-cert/
```
##Install ssl certificate in RHEV node##

Login to RHEV node rhev-c.

Go to temporary folder that we created in previous step or folder where we copy certificate file from rhevm.
```bash
  cd gen-cert/
```
Copy and rename cer file to RHEV certificate folder.
```bash
  cp -avr 10.32.5.67.cer /etc/pki/vdsm/certs/vdsmcert.pem
```
Change permission.
```bash
  chmod 644 /etc/pki/vdsm/certs/vdsmcert.pem
```
Copy and rename cer file to libvirt certificate folder.
```bash
  cp -avr 10.32.5.67.cer /etc/pki/libvirt/clientcert.pem
```
Change permission.
 ```bash
  chmod 644 /etc/pki/libvirt/clientcert.pem
```
Copy and rename cer file toe SPICE certificate folder.
```bash
  cp -avr /etc/pki/vdsm/certs/vdsmcert.pem /etc/pki/vdsm/libvirt-spice/server-cert.pem
```
Change permission.
```bash
  chmod 644 /etc/pki/vdsm/libvirt-spice/server-cert.pem
```
Restart VSDM service. Restart will have no impact with running VM in existing RHEV node, but it is recommended to execute this command during non office hour to prevent any impact.
```bash
  service vdsmd restart
```
[[https://access.redhat.com/solutions/2152811 related vdsmd]]

##Reload RHEV node in RHEV-M##

Login to RHEVM, and reload ovirt-engine.
```bash
  service ovirt-engine restart
```
