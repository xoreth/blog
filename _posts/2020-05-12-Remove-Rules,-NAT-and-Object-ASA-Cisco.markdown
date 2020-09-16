---
layout: post
title: Remove Rules, NAT and Object ASA Cisco
author: Galuh D Wijatmiko
categories: [Networks]
tags: [Firewall,ASA,Cisco]
draft: false
published: true
---

```bash
no access-list nex_dmz_access_in line 16 extended permit object-group DM_INLINE_PROTOCOL_1 object dmz.aqmsdki any 
no access-list nex_dmz_access_in line 15 remark ACL Defaults - Outgoing gre tunnel
no access-list nex_outside_access_in line 36 extended permit tcp any object dmz.mbng2 object-group DM_INLINE_TCP_2 
no access-list nex_outside_access_in line 35 remark ACLdefaults Application EMAIL Iredmail
no access-list nex_outside_access_in line 34 remark ACLdefaults Application FTP to SMS
no access-list nex_outside_access_in line 33 remark ACLdefaults Application Altamides Mobile
no access-list nex_outside_access_in line 32 remark ACLdefaults Application Altamides Web
no access-list nex_outside_access_in line 31 remark ACLdefaults Application Web with standar port
no access-list nex_outside_access_in line 30 remark ACLdefaults Application SMS API BRIDGE
no access-list nex_outside_access_in line 29 remark ACLdefaults Application SMSAPIV2-2
no access-list nex_outside_access_in line 28 remark ACLdefaults Application SMSAPIV2
no access-list nex_outside_access_in line 27 remark ACLdefaults Server Reporting and Gateway SMS
no access-list nex_outside_access_in line 26 remark ACLdefaults DNS Access
no access-list nex_outside_access_in line 25 remark ACL Testing - Soni Load balancing
no access-list nex_outside_access_in line 10 extended permit object-group DM_INLINE_SERVICE_13 any object dmz.aqmsdki 
no access-list nex_outside_access_in line 9 remark ACL Defaults - Incoming Application FTP to SMS
no object-group service DM_INLINE_TCP_2 tcp
no object-group service DM_INLINE_SERVICE_13
no object-group protocol DM_INLINE_PROTOCOL_1
object network dmz.aqmsdki
   no nat (nex_dmz,nex_outside) static out.nat-vpn-aqms-dki
   clear xlate interface nex_dmz local 10.32.27.23
no object network dmz.aqmsdki

```