---
layout: post
title: NTP Server Installation Centos 7
author: Galuh D Wijatmiko
categories: [Server]
tags: [ntp,centos7,installation]
---



##NTP Server Centos 7##

###INSIDE SERVER###

`Install All package ntp`

`yum install ntpdate ntp`

2. Create Configuration

>     cat > /etc/ntp.conf <<EOF
>     driftfile /var/lib/ntp/drift
>     restrict default kod nomodify notrap nopeer noquery
>     restrict -6 default kod nomodify notrap nopeer noquery
>     restrict 127.0.0.1 
>     restrict -6 ::1
>     restrict 10.0.1.0 mask 255.255.255.0 nomodify notrap
>     server 127.127.1.0
>     fudge 127.127.1.0 stratum 10
>     includefile /etc/ntp/crypto/pw
>     keys /etc/ntp/keys
>     logfile /var/log/ntp.log
>     disable monitor
>     EOF

3. Start and enable service

    `systemctl start ntpd`

   ` systemctl enable ntpd`

4. Check status ntp

    `ntpq -p`
    Output :
>      remote refid st t when poll reach delay offset jitter
>     ==============================================================================
>     *LOCAL(0) .LOCL. 10 l 6 64 1 0.000 0.000 0.000

###INSIDE ALL CLIENT###
1. Sync time to server

`ntpdate -q ipserver`

2. Install in crontab

    `crontab -e`
    */5 * * * * /sbin/ntpdate -q ipserver
