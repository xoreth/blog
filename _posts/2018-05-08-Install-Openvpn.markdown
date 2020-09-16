---
layout: post
title: Install OPENVPN Centos7
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening,Networks]
tags: [VPN,SSL]
---

## Install Openvpn Centos 7##

Before that, Set secure SSH https://blog.wajatmaka.com/2018/05/Secure-SSH-Config.html

IP Public : 159.89.98.161
IP Private : 10.8.0.1
Port Income : TCP/13579
DNS Cloudflare : 1.0.0.1/1.1.1.1
Chiper : AES-256-CBC
Diffie-Hellman key : 3072 bits
RSA : 3072 bits



```bash
yum install epel-release -y
yum install openvpn iptables iptables-service openssl wget ca-certificates curl -y
yum install policycoreutils-python -y
```

For temporary disable firewall

```bash
systemctl stop iptables
systemctl enable iptables
```

Install easyRSA

```bash
wget -O ~/EasyRSA-3.0.4.tgz https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
tar xzf ~/EasyRSA-3.0.4.tgz -C ~/
mv ~/EasyRSA-3.0.4/ /etc/openvpn/
mv /etc/openvpn/EasyRSA-3.0.4/ /etc/openvpn/easy-rsa/
chown -R root:root /etc/openvpn/easy-rsa/
rm -rf ~/EasyRSA-3.0.4.tgz
cd /etc/openvpn/easy-rsa/
export SERVER_NAME="server_wajatmaka"
echo "set_var EASYRSA_KEY_SIZE 3072" > vars
echo "set_var EASYRSA_REQ_CN cn_5ff1DGObWJIdSES7" >> vars
./easyrsa init-pki
./easyrsa --batch build-ca nopass
openssl dhparam -out dh.pem 3072 
./easyrsa build-server-full $SERVER_NAME nopass
./easyrsa build-client-full $CLIENT nopass
export EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
openvpn --genkey --secret /etc/openvpn/tls-auth.key
cp pki/ca.crt pki/private/ca.key dh.pem pki/issued/$SERVER_NAME.crt pki/private/$SERVER_NAME.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
chmod 644 /etc/openvpn/crl.pem

```

Configure server.conf in /etc/openvpn

```bash
port 13579
proto tcp
dev tun
user nobody
group nobody
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "redirect-gateway def1 bypass-dhcp" 
crl-verify crl.pem
ca ca.crt
cert server_wajatmaka.crt
key server_wajatmaka.key
client-config-dir config
tls-auth tls-auth.key 0
dh dh.pem
auth SHA256
cipher AES-128-CBC
tls-server
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
status /var/log/openvpn-status.log
writepid /var/run/openvpn.pid
verb 4 
```


configure sysctl.conf for hardening and direct traffic 

```
net.ipv4.ip_forward=1
kernel.dmesg_restrict=1
kernel.kptr_restrict=2
kernel.sysrq=0
kernel.yama.ptrace_scope=3
net.ipv4.conf.all.log_martians=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.log_martians=1
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
# Avoid a smurf attack
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Turn on protection for bad icmp error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1
# Turn on syncookies for SYN flood attack protection
net.ipv4.tcp_syncookies = 1
# Turn on and log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
# No source routed packets here
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
# Turn on reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
# Make sure no one can alter the routing tables
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
# Turn on execshild
kernel.exec-shield = 1
kernel.randomize_va_space = 1
# Tuen IPv6
net.ipv6.conf.default.router_solicitations = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_defrtr = 0
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.default.dad_transmits = 0
net.ipv6.conf.default.max_addresses = 1
# Optimization for port usefor LBs
# Increase system file descriptor limit
fs.file-max = 65535
# Allow for more PIDs (to reduce rollover problems); may break some programs 32768
kernel.pid_max = 65536
# Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000
# Increase TCP max buffer size setable using setsockopt()
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
# Increase Linux auto tuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
# Tcp Windows etc
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_window_scaling = 1
```



Setting Iptables

```bash
### NAT FOR GET INTERNET ACCESS ##

*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j SNAT --to-source 159.89.98.163
COMMIT

### FILTERING ###

*filter
:INPUT DROP [27:1560]
:FORWARD DROP [15:801]
:OUTPUT DROP [0:0]
:LOGGING - [0:0]



## Allow Income Loopback ##
-A INPUT -i lo -j ACCEPT

## Allow Income State Established ##
-A INPUT -m state --state ESTABLISHED -j ACCEPT

## Allow Income ICMP type 11 ##
-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT


## Allow Income SSH From Local Tun0 openvpn ##
-A INPUT -s 10.8.0.2/32 -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

## Allow Income SSH From All Outside ##
-A INPUT -p tcp -m tcp --dport 57913 -m state --state NEW,ESTABLISHED -j ACCEPT

## Allow Income Openvpn Connection ##
-A INPUT -p tcp -m tcp --dport 13579 -m state --state NEW,ESTABLISHED -j ACCEPT

## Allow Income For All tun0 ##
-A INPUT -i tun0 -j ACCEPT

## Allow Forward For All tun0 ##
-A FORWARD -i tun0 -j ACCEPT

## Allow Forward from tun0 to eth0 ##
-A FORWARD -i tun0 -o eth0 -s 10.8.0.0/24 -j ACCEPT

## Allow Forward State Established and Related ##
-A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

## Allow Outgoing All tun0 ##
-A OUTPUT -o tun0 -j ACCEPT

## Allow Outgoing Loopback ##
-A OUTPUT -o lo -j ACCEPT

## Allow Outgoing From Self  to eth0 Any UDP DNS and NTP ##
-A OUTPUT -s 159.89.98.163/32,10.8.0.0/24 -o eth0 -p udp -m multiport --dports 53,123 -j ACCEPT

## Allow Outgoing From Self to tun0 Any UDP DNS and NTP ##
-A OUTPUT -s 10.8.0.0/24 -o tun0 -p udp -m multiport --dports 53,123 -j ACCEPT

## Allow Outgoing From Self HTTP HTTPS and OPENVPN ##
-A OUTPUT -s 159.89.98.163/32,10.8.0.1/24 -o eth0 -p tcp -m multiport --dports 80,443,13579 -j ACCEPT


## Allow Outgoing Any TCP and UDP ##
-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED -j ACCEPT

## Allow Logging DROP OUTGOING ##
-A OUTPUT -j LOGGING
-A LOGGING -m limit --limit 5/min -j LOG --log-prefix "Outgoing Dropped: " --log-level 5
-A LOGGING -j DROP
COMMIT
```

Create Client Openvpn

create file in ~/client.ovpn and fill it

```bash
client
proto tcp-client
remote 159.89.98.16 13579
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verify-x509-name server_wajatmaka name
auth SHA256
auth-nocache
cipher AES-128-CBC
tls-client
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
setenv opt block-outside-dns
verb 3
<ca>
```

After that, sign all RSA/cert to client.ovpn

```bash
cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/client.ovpn
echo "</ca>" >> ~/client.ovpn
echo "<cert>" >> ~/client.ovpn
cat /etc/openvpn/easy-rsa/pki/issued/client.crt >> ~/client.ovpn
echo "</cert>" >> ~/client.ovpn
echo "<key>" >> ~/client.ovpn
cat /etc/openvpn/easy-rsa/pki/private/client.key >> ~/client.ovpn
echo "</key>" >> ~/client.ovpn
echo "key-direction 1" >> ~/client.ovpn
echo "<tls-auth>" >> ~/client.ovpn
cat /etc/openvpn/tls-auth.key >> ~/client.ovpn
echo "</tls-auth>" >> ~/client.ovpn
```

Running from client

```bash
openvpn --config client.ovpn

```
