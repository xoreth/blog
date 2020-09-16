---
layout: post
title: Install And Configure IPSEC VPN IKEV1 Using Openswan on Centos 7
author: Galuh D Wijatmiko
categories: [Networks]
tags: [VPN]
draft: false
published: true
---


# Install VPN Site to SIte IPSEC Ikev1 using Openswan
## SCHEMA

### VPN Config Inside PT. Daku


*Phase 1:*

> IP Private : 10.172.192.101  
> IP Peer : 103.10.128.2  
> Auth Method : Pre-Shared Key  
> Encryption : IKE  
> Diffie-Hellman Group : Group2  
> Encryption Algorithm : AES-256  
> Hash Algorithm : SHA-2    
> Main or Aggresive Mode : Main Mode  
> Lifetime : 86400 s  

*Phase 2 :*  

> Encapsulation (ESP) : ESP  
> Encryption Algorithm : AES-256  
> Authentication Algorithm : SHA-2
> PFS With Algorithm : No PFS  
> Lifetime : 3600 s  
> Port Open : 443 TCP, ICMP  


### VPN Config Inside PT. KotakSayurDulu

*Phase 1:*

> IP Private : 10.69.0.44,10.69.0.128/25  
>  IP Peer : 18.136.161.45  
> Auth Method : Pre-Shared Key  
> Encryption : IKE  
> Diffie-Hellman Group : Group2  
> Encryption Algorithm : AES-256  
> Hash Algorithm : SHA-2  
> Main or Aggresive Mode : Main Mode  
> Lifetime : 86400 s  

*Phase 2 :*

> Encapsulation (ESP) : ESP  
> Encryption Algorithm : AES-256  
> Authentication Algorithm : SHA-2  
> PFS With Algorithm : No PFS  
> Lifetime : 3600 s  


Install  Openswan
```
yum install openswan iptables-services
```

Change Parameter Kernel /etc/sysctl.conf
```
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0 
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0 
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.lo.accept_redirects = 0 
net.ipv4.conf.lo.send_redirects = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0 
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.ip_vti0.rp_filter = 0
```


Config Ipsec Global /etc/ipsec.conf
```
config setup
	logfile=/var/log/pluto.log
	plutodebug="all crypt"
	virtual_private=%v4:10.0.0.0/8,%v4:10.69.0.0/24  
        include /etc/ipsec.d/*.conf
```

Config VPN site2site detial /etc/ipsec.d/daku-vpn.conf
```
conn daku-vpn
  type=tunnel
  auto=start
  dpddelay=20
  dpdtimeout=40
  dpdaction=restart
  left=10.69.0.44 # private ip of openswan instance
  leftid= 18.136.161.45 #public ip of openswan instance
  leftsubnets={10.69.0.44/32,10.69.0.128/25} # private ip of #openswan/32 and private ip of java application instances/32
  #leftsourceip=10.69.0.44
  right=103.10.128.2 # public ip of the third party network
  rightsubnets=10.172.192.101/32 # private ip of the third party network
  #### phase 1 ####
  keyexchange=ike
  ike=aes256-sha2-modp1024
  ikelifetime=86400s
  authby=secret #use presharedkey
  rekey=yes  #should we rekey when key lifetime is about to expire
  #### phase 2 #####
  esp=aes256-sha2
  keylife=3600 
  pfs=no
```

Create  IP Peer and Secret /etc/ipsec.d/daku-vpn.secrets
```
18.136.161.45  103.10.128.2: PSK "jancukphasparse"
```

Loading and Unloading a Connection  
```
ipsec auto --add daku-vpn
ipsec auto --delete daku-vpn
```

Initiating, On-demand and Terminating a Connection  
```
ipsec auto --up daku-vpn
ipsec auto --route daku-vpn
ipsec auto --down daku-vpn
```
Checking the IPsec Kernel Subsystem  
```
ip xfrm policy
ip xfrm state
ip -s xfrm monitor
```

Start, Status and Verify Tunnel Service
```
sysctl start ipsec
ipsec status
ipsec verify
```

Setting Iptables
```
##### IPTABLES OPENSWAN KotakSayurDulu
#
# Profiling by Dwiyan Galuh
#
#
#
*nat
:PREROUTING ACCEPT [120:16660]
:POSTROUTING ACCEPT [109:12489]
-A PREROUTING -j LOG
-A PREROUTING -p tcp -s 10.69.0.128/25 -d 10.69.0.44 --dport 6969 -j DNAT --to-destination 10.172.192.101:443 
-A POSTROUTING -j LOG
-A POSTROUTING -p tcp -s 10.69.0.128/25 -d 10.172.192.101 --dport 443 -j MASQUERADE
COMMIT
### FILTERING ###
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:65535]
:LOGGING - [0:65535]
## Drop flags Handshake TCP ##
-A INPUT -p tcp --tcp-flags ALL NONE -j DROP
-A INPUT -m state --state INVALID -j DROP
-A INPUT   -p tcp --tcp-flags ACK,FIN FIN -j LOG --log-prefix "FIN:" 
-A INPUT   -p tcp --tcp-flags ACK,FIN FIN -j DROP
-A INPUT   -p tcp --tcp-flags ACK,PSH PSH -j LOG --log-prefix "PSH:"
-A INPUT   -p tcp --tcp-flags ACK,PSH PSH -j DROP
-A INPUT   -p tcp --tcp-flags ACK,URG URG -j LOG --log-prefix "URG:"
-A INPUT   -p tcp --tcp-flags ACK,URG URG -j DROP
-A INPUT   -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "XMAS scan: "
-A INPUT   -p tcp --tcp-flags ALL ALL -j DROP
-A INPUT   -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "NULL scan: "
-A INPUT   -p tcp --tcp-flags ALL NONE -j DROP
-A INPUT   -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG --log-prefix "pscan: "
-A INPUT   -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
-A INPUT   -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j LOG --log-prefix "NMAP-ID: "
-A INPUT   -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP
-A INPUT   -p tcp --tcp-flags ALL FIN -j LOG --log-prefix "FIN-SCAN: "
-A INPUT   -p tcp --tcp-flags ALL FIN -j DROP
-A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
-A INPUT -f -j DROP
## Allow Income Loopback ##
-A INPUT -i lo -j ACCEPT -m comment --comment "Allow Income Loopback"
## Allow Income State Established ##
-A INPUT -m state --state ESTABLISHED -j ACCEPT -m comment --comment "Allow Income State Established"
## Drop Income ICMP##
-A INPUT -p icmp -s 10.69.0.0/24 -j ACCEPT
## Allow Income HTTP and HTTPS
-A INPUT -p tcp -s 10.69.0.128/25 -m tcp -m multiport --dports 6969 -j ACCEPT -m comment --comment "Allow Income HTTP and HTTPS"
## Allow Income Monit
-A INPUT -p tcp  -s 127.0.0.1 -m tcp -m multiport --dports 2812 -j ACCEPT -m comment --comment "Allow Income HTTP and HTTPS"
## Allow Income SSH  openvpn ##
-A INPUT  -p tcp -m tcp --dport 20491 -m state --state NEW,ESTABLISHED -j ACCEPT -m comment --comment "Allow Income SSH From Local Tun0 openvpn"
## Allow ikev ##
-A INPUT  -p udp -s 10.172.192.101,18.136.161.45,10.69.0.0/24,103.10.128.2 -m udp --dport 500 -j ACCEPT -m comment --comment "Allow Income ikev"
## Allow ipsec ##
-A INPUT  -p udp -s 10.172.192.101,18.136.161.45,10.69.0.0/24,103.10.128.2 -m udp --dport 4500 -j ACCEPT -m comment --comment "Allow Income ikev"
## Allow Forward State Established and Related ##
-A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Allow Forward Established State" 
-A FORWARD -i eth0 -j ACCEPT
-A FORWARD -o eth0 -j ACCEPT
## Allow Outgoing From Self  to eth0 Any UDP DNS and NTP ##
-A OUTPUT  -o eth0 -p udp -m multiport --dports 53,123 -j ACCEPT -m comment --comment " Allow Outgoing From Self to Any UDP dns and utp"
## Allow Outgoing From Self HTTP HTTPS and OPENVPN ##
-A OUTPUT -o eth0 -p tcp -m comment --comment " Allow Outgoing http, https and openvpn from self" -m multiport --dports 443,6969 -j ACCEPT
### Allow Outgoing ESP
-A OUTPUT -o eth0 -p 50 -j ACCEPT
### Allow Outgoing ICMP
-A OUTPUT -o eth0 -p icmp -j ACCEPT
### Allow Outgoing UDP DHCP Request
-A OUTPUT -o eth0 -p udp -d 10.69.0.0/24 -m multiport --dports 67 -j ACCEPT
#Allow Outgoing LO
-A OUTPUT -o lo -p tcp -s 127.0.0.1 -d 127.0.0.1  -m multiport --dports 2812 -j ACCEPT
-A OUTPUT -o lo -p tcp -s 127.0.0.1 -d 127.0.0.1  -m multiport --sports 2812 -j ACCEPT
### Allow UDP/TCP IkEv and esp dhcp
-A OUTPUT -o eth0 -p udp -m multiport --dports 500,4500 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m multiport --dports 500,4500 -j ACCEPT
## Allow SSH ##
-A OUTPUT -o eth0  -p tcp -m tcp --dport 20491 -j ACCEPT
## Allow Outgoing Any TCP and UDP ##
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT -m comment --comment " Allow Outgoing TCP"
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED -j ACCEPT -m comment --comment " Allow Outgoing UDP"
-A OUTPUT -o eth0 -p udp  --dport 53 -m state --state ESTABLISHED -j ACCEPT -m comment --comment " Allow Outgoing UDP" 
-A OUTPUT -o eth0 -p udp  --dport 123 -m state --state ESTABLISHED -j ACCEPT -m comment --comment " Allow Outgoing UDP" 
## Allow Logging DROP OUTGOING ##
-A INPUT -j LOGGING
-A OUTPUT -j LOGGING
-A LOGGING -m limit --limit 5/min -j LOG --log-prefix "Outgoing Dropped: " --log-level 5
-A LOGGING -j DROP
COMMIT
```
