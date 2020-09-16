---
layout: post
title: ELK Stack Installation
author: Galuh D Wijatmiko
categories: [LoggingAndMonitoring]
tags: [Loging,Logs,CentralizedLogging,Monitoring,ELK]
draft: false
published: true
---
# Architecture
![ELK Stack Architecture](/assets/images/data_blog/ELK.png)

Description 
<pre>
<table>
<tr>
    <th>No</th>
    <th>VM</th>
    <th>Hostname</th>
    <th>Status</th>
    <th>Service</th>
    <th>OS</th>
    <th>IP Address</th>
</tr>
<tr>
    <td>1</td>
    <td>vm1</td>
    <td>client.vm1.test</td>
    <td>Client</td>
    <td>Filebeat</td>
    <td>Ubuntu 19.10</td>
    <td>192.168.33.10</td>
</tr>
<tr>
    <td>2</td>
    <td>vm2</td>
    <td>logstash.vm2.test </td>
    <td>Server</td>
    <td>Logstash</td>
    <td>Ubuntu 19.10</td>
    <td>192.168.33.11</td>
</tr>
<tr>
    <td>3</td>
    <td>vm3</td>
    <td>dashboard.vm3.test</td>
    <td>Server</td>
    <td>Elasticsearch, Nginx and Kibana</td>
    <td>Ubuntu 19.10</td>
    <td>192.168.33.12</td>
</tr>
</table>
</pre>

# Preparation 
Create Vagrantfile
```bash
Vagrant.configure("2") do |config|

config.vm.box_check_update = false	
    
    config.vm.define "vm1" do |vm1|
    vm1.vm.box = "ubuntu/eoan64"
    vm1.vm.hostname = "client.vm1.test"
    vm1.vm.network "private_network", ip: "192.168.33.10"
        vm1.vm.provider "virtualbox" do |vb|
            vb.name = "vm1"
            vb.memory = "1024"
        end
    end

    config.vm.define "vm2" do |vm2|
    vm2.vm.box = "ubuntu/eoan64"
    vm2.vm.hostname = "logstash.vm2.test"
    vm2.vm.network "private_network", ip: "192.168.33.11"
        vm2.vm.provider "virtualbox" do |vb|
            vb.name = "vm2"
            vb.memory = "1024"
        end
    end

    config.vm.define "vm3" do |vm3|
    vm3.vm.box = "ubuntu/eoan64"
    vm3.vm.hostname = "dashboard.vm3.test"
    vm3.vm.network "private_network", ip: "192.168.33.13"
        vm3.vm.provider "virtualbox" do |vb|
            vb.name = "vm3"
            vb.memory = "2048"
        end
    end

end
```

Running Vagrant
```bash
vagrant up vm1 vm2 vm3
```

## ORACLE JDK Installation
Install Oracle JDK in all Hosts (vm1,vm2,vm3)
Download in page [OracleJDK8](https://www.oracle.com/java/technologies/javase-jdk8-downloads.html). 
> jdk-8u251-linux-x64.tar.gz

If you downloaded in your host not in your VM, you can upload file jdk deb using upload by vagrant feature like :
```bash
vagrant upload ~/Downloads/jdk-8u251-linux-x64.tar.gz vm1
vagrant upload ~/Downloads/jdk-8u251-linux-x64.tar.gz vm2
vagrant upload ~/Downloads/jdk-8u251-linux-x64.tar.gz vm3
```

Install :
```bash
# tar xvf jdk-8u251-linux-x64.tar.gz -C /opt
# ln -s /opt/jdk1.8.0_251/ /opt/jdk
```
Create Vaiable Environment JDK
```bash
# cat > /etc/profile.d/jvm.sh <<EOF
JAVA_HOME="/opt/jdk"
export PATH=$PATH:/opt/jdk/bin:/usr/local/bin
EOF
```
Reload Variable Environment
```bash
source /etc/profile.d/jvm.sh
```

Testing work or not, if work output will be show:
```bash
# java -version
java version "8.0.251" 2020-04-14 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.7+8-LTS)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.7+8-LTS, mixed mode)
```
## Put DNS
Put DNS hosts in every VM (vm1,vm2,vm3)
```bash
echo "192.168.33.10 client.vm1.test" >> /etc/hosts
echo "192.168.33.11 logstash.vm2.test" >> /etc/hosts
echo "192.168.33.12 dashboard.vm3.test" >> /etc/hosts
```
## Disable IPV6
Disbale all ipv6 in all host (vm1,vm2, vm3). then, edit  in /etc/sysctl.conf
```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
Reload kernel config
```bash
sysctl -p
```

## Filebeat Installation
Login ssh to client.vm1.test (192.168.33.10)
```bash
vagrant ssh vm1
```

download filebeat:
```bash
# apt install wget
# wget -c https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.2-amd64.deb 
```
Install Filebeat:
```bash
dpkg -i filebeat-7.6.2-amd64.deb
```
edit file configuration in  /etc/filebeat/filebeat.yml

Disable send to elasticsearch
```bash
....
#output.elasticsearch:
  # Array of hosts to connect to.
  #hosts: ["localhost:9200"]
....
```

Enable send to logstash
```bash
....
output.logstash:
  # The Logstash hosts
  hosts: ["logstash.vm2.test:5044"]
....
```

Enable Modules Template what you need, In my case I enabled system and auditd. before enable, I have install auditd first.
```bash
# apt install auditd
# systemctl start auditd
# systemctl enable auditd
```

Lets enable modules :
```bash
# filebeat modules enable system auditd
```

To look modules already enabled
```bash
# filebeat modules list
Enabled:
auditd
system

Disabled:
activemq
apache
aws
azure
cef
cisco
coredns
elasticsearch
envoyproxy
googlecloud
haproxy
ibmmq
icinga
iis
iptables
kafka
kibana
logstash
misp
mongodb
mssql
mysql
nats
netflow
nginx
osquery
panw
postgresql
rabbitmq
redis
santa
suricata
traefik
zeek
```

Lets verify config and connection
Config Check
```bash
# filebeat test config
Config OK
```

Connection Check
```bash
# filebeat test output
logstash: logstash.vm2.test:5044...
  connection...
    parse host... OK
    dns lookup... OK
    addresses: 192.168.33.11
    dial up... ERROR dial tcp 192.168.33.11:5044: connect: connection refused
```

Connection check will be *ERROR* because we have not installed logstash.

## Elasticsearch Installation
Login ssh to dashboard.vm3.test (192.168.33.12)
```bash
vagrant ssh vm3
```

Download Elasticsearch 
```bash
wget -c https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-amd64.deb
```
Install Elasticsearch :
```bash
# dpkg -i elasticsearch-7.6.2-amd64.deb
```

Binding Service to IP 192.168.33.12, edit in /etc/elasticsearch/elasticsearch.yml
```bash
....
discovery.type: single-node
network.host: 192.168.33.12
#
# Set a custom port for HTTP:
#
http.port: 9200
....
```

Start Elasticsearch
```bash
# systemctl start elasticsearch
```

Check Service if already up
```bash
# systemctl status elasticsearch
# ss -tulpn | grep -E "9200|9300"
```

To make sure we can login to logstash.vm2.test and test connection
```bash
telnet dashboard.vm3.test 9200
```
if connection fine, output:
```
Trying 192.168.33.12...
Connected to dashboard.vm3.test.
Escape character is '^]'.
```
And test curling in logstash.vm2.test:
```bash
$ curl -X GET "dashboard.vm3.test:9200"
{
  "name" : "dashboard",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "nKL1X59MRz-RfF3-ElD0Jw",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

```
Enable Booting Startup Service
```bash
# systemctl enable elasticsearch
```

## Logstash Installation
Login ssh to logstash.vm2.test (192.168.33.11)
```bash
vagrant ssh vm2
```

Download Logstash 
```bash
wget -c https://artifacts.elastic.co/downloads/logstash/logstash-7.6.2.deb
```

Install Logstash
```bash
dpkg -i logstash-7.6.2.deb
```

Edit file /etc/default/logstash, and add in last file:
```bash
....
JAVA_HOME="/opt/jdk"
....
```

Create Configuration in /etc/logstash/conf.d/02-beats-input.conf
```bash
input {
  beats {
    port => 5044
  }
}
```

Create Configuration in /etc/logstash/conf.d/10-syslog-filter.conf
```bash
filter {
  if [fileset][module] == "system" {
    if [fileset][name] == "auth" {
      grok {
        match => { "message" => ["%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} %{DATA:[system][auth][ssh][method]} for (invalid user )?%{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]} port %{NUMBER:[system][auth][ssh][port]} ssh2(: %{GREEDYDATA:[system][auth][ssh][signature]})?",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} user %{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: Did not receive identification string from %{IPORHOST:[system][auth][ssh][dropped_ip]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sudo(?:\[%{POSINT:[system][auth][pid]}\])?: \s*%{DATA:[system][auth][user]} :( %{DATA:[system][auth][sudo][error]} ;)? TTY=%{DATA:[system][auth][sudo][tty]} ; PWD=%{DATA:[system][auth][sudo][pwd]} ; USER=%{DATA:[system][auth][sudo][user]} ; COMMAND=%{GREEDYDATA:[system][auth][sudo][command]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} groupadd(?:\[%{POSINT:[system][auth][pid]}\])?: new group: name=%{DATA:system.auth.groupadd.name}, GID=%{NUMBER:system.auth.groupadd.gid}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} useradd(?:\[%{POSINT:[system][auth][pid]}\])?: new user: name=%{DATA:[system][auth][user][add][name]}, UID=%{NUMBER:[system][auth][user][add][uid]}, GID=%{NUMBER:[system][auth][user][add][gid]}, home=%{DATA:[system][auth][user][add][home]}, shell=%{DATA:[system][auth][user][add][shell]}$",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} %{DATA:[system][auth][program]}(?:\[%{POSINT:[system][auth][pid]}\])?: %{GREEDYMULTILINE:[system][auth][message]}"] }
        pattern_definitions => {
          "GREEDYMULTILINE"=> "(.|\n)*"
        }
        remove_field => "message"
      }
      date {
        match => [ "[system][auth][timestamp]", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
      }
      geoip {
        source => "[system][auth][ssh][ip]"
        target => "[system][auth][ssh][geoip]"
      }
    }
    else if [fileset][name] == "syslog" {
      grok {
        match => { "message" => ["%{SYSLOGTIMESTAMP:[system][syslog][timestamp]} %{SYSLOGHOST:[system][syslog][hostname]} %{DATA:[system][syslog][program]}(?:\[%{POSINT:[system][syslog][pid]}\])?: %{GREEDYMULTILINE:[system][syslog][message]}"] }
        pattern_definitions => { "GREEDYMULTILINE" => "(.|\n)*" }
        remove_field => "message"
      }
      date {
        match => [ "[system][syslog][timestamp]", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
      }
    }
  }
}
```

Create Configuration in /etc/logstash/conf.d/30-elasticsearch-output.conf
```bash
output {
  elasticsearch {
    hosts => ["dashboard.vm3.test:9200"]
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
  file {
    path => "/var/log/data.%{+yyyy.MM.dd.HH}"
  }
}
```

Enable Booting :
```bash
# systemctl enable  logstash
```

Start Service :
```bash
# systemctl start logstash
```

Check Service :
```bash
# systemctl status logstash

```

If Service difficult for running, you can reboot first
```bash
# reboot
```

## View Logs From Filebeat, Logstash and Elasticsearch (Flow Logs ELK)

First Start your all service, if not running
VM1
```bash
# systemctl status filebeat
# systemctl start filebeat
```

VM2
```bash
# systemctl status logstash
# systemctl start logstash
```

VM3
```bash
# systemctl status elasticsearch
# systemctl start elasticsearch
```



On filebeat we can check log already  sending or not with
```bash
# journalctl -f -u filebeat
....
May 11 08:23:41 client filebeat[5514]: 2020-05-11T08:23:41.651Z        INFO        [monitoring]        log/log.go:145        Non-zero metrics in the last 30s        {"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":400,"time":{"ms":7}},"total":{"ticks":880,"time":{"ms":20},"value":880},"user":{"ticks":480,"time":{"ms":13}}},"handles":{"limit":{"hard":524288,"soft":1024},"open":11},"info":{"ephemeral_id":"9d2917d6-7e25-4729-8a26-0896d4857f1c","uptime":{"ms":750064}},"memstats":{"gc_next":10661600,"memory_alloc":9687408,"memory_total":80227472},"runtime":{"goroutines":57}},"filebeat":{"events":{"added":1,"done":1},"harvester":{"files":{"c46bae67-38e7-403e-befb-5927bb73de39":{"last_event_published_time":"2020-05-11T08:23:20.769Z","last_event_timestamp":"2020-05-11T08:23:15.768Z","read_offset":1212,"size":2438}},"open_files":1,"running":1}},"libbeat":{"config":{"module":{"running":0}},"output":{"events":{"acked":1,"batches":1,"total":1},"read":{"bytes":6},"write":{"bytes":1169}},"pipeline":{"clients":6,"events":{"active":0,"published":1,"total":1},"queue":{"acked":1}}},"registrar":{"states":{"current":4,"update":1},"writes":{"success":1,"total":1}},"system":{"load":{"1":0,"15":0,"5":0,"norm":{"1":0,"15":0,"5":0}}}}}}
....
```

On logstash we can check log already  recieved or not with
```bash
# tail -f data.2020.05.11.08
```
or we can look traffic with tcpdump
```bash
# tcpdump -nn -i any host 192.168.33.10 and not port 22
...
08:48:43.806249 IP 192.168.33.10.46618 > 192.168.33.11.5044: Flags [S], seq 2057297696, win 64240, options [mss 1460,sackOK,TS val 2851851605 ecr 0,nop,wscale 7], length 0
08:48:43.806294 IP 192.168.33.11.5044 > 192.168.33.10.46618: Flags [R.], seq 0, ack 2057297697, win 0, length 0
08:48:48.964271 ARP, Request who-has 192.168.33.10 tell 192.168.33.11, length 28
08:48:48.964616 ARP, Reply 192.168.33.10 is-at 08:00:27:7e:1b:28, length 46
...
```

On Elasticsearch we can look data using curl
```bash
# curl -XGET 'http://192.168.33.12:9200/filebeat-*/_search?pretty'
....
{
        "_index" : "filebeat-7.6.2-2020.05.11",
        "_type" : "_doc",
        "_id" : "NeDGAnIBe1bGH8HxZj0L",
        "_score" : 1.0,
        "_source" : {
          "message" : "type=CRED_DISP msg=audit(1589113021.987:168): pid=3972 uid=0 auid=0 ses=25 msg='op=PAM:setcred grantors=pam_permit acct=\"root\" exe=\"/usr/sbin/cron\" hostname=? addr=? terminal=cron res=success'",
          "input" : {
            "type" : "log"
          },
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "fileset" : {
            "name" : "log"
          },
          "agent" : {
            "hostname" : "client",
            "ephemeral_id" : "3c2d7a67-e0a6-453d-a9d2-a7ee7fa7c946",
            "version" : "7.6.2",
            "id" : "05162b46-7489-4258-a919-e831ad2e7908",
            "type" : "filebeat"
          },
          "@timestamp" : "2020-05-11T08:07:09.774Z",
          "host" : {
            "hostname" : "client",
            "id" : "002ec2f2a0b54ced91df112c17524746",
            "name" : "client",
            "architecture" : "x86_64",
            "containerized" : false,
            "os" : {
              "family" : "debian",
              "version" : "19.10 (Eoan Ermine)",
              "name" : "Ubuntu",
              "platform" : "ubuntu",
              "codename" : "eoan",
              "kernel" : "5.3.0-51-generic"
            }
          },
          "ecs" : {
            "version" : "1.4.0"
          },
          "@version" : "1",
          "service" : {
            "type" : "auditd"
          },
          "event" : {
            "dataset" : "auditd.log",
            "module" : "auditd"
          },
          "log" : {
            "file" : {
              "path" : "/var/log/audit/audit.log"
            },
            "offset" : 24970
          }
        }
      }
.....
.....
{
        "_index" : "filebeat-7.6.2-2020.05.11",
        "_type" : "_doc",
        "_id" : "MODGAnIBe1bGH8HxZj0L",
        "_score" : 1.0,
        "_source" : {
          "message" : "May 11 05:00:59 client systemd[1]: motd-news.service: Succeeded.",
          "input" : {
            "type" : "log"
          },
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "agent" : {
            "hostname" : "client",
            "ephemeral_id" : "3c2d7a67-e0a6-453d-a9d2-a7ee7fa7c946",
            "version" : "7.6.2",
            "id" : "05162b46-7489-4258-a919-e831ad2e7908",
            "type" : "filebeat"
          },
          "fileset" : {
            "name" : "syslog"
          },
          "@timestamp" : "2020-05-11T08:07:09.774Z",
          "host" : {
            "hostname" : "client",
            "id" : "002ec2f2a0b54ced91df112c17524746",
            "name" : "client",
            "architecture" : "x86_64",
            "containerized" : false,
            "os" : {
              "family" : "debian",
              "version" : "19.10 (Eoan Ermine)",
              "name" : "Ubuntu",
              "platform" : "ubuntu",
              "codename" : "eoan",
              "kernel" : "5.3.0-51-generic"
            }
          },
          "ecs" : {
            "version" : "1.4.0"
          },
          "@version" : "1",
          "service" : {
            "type" : "system"
          },
          "event" : {
            "dataset" : "system.syslog",
            "module" : "system",
            "timezone" : "+00:00"
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog"
            },
            "offset" : 1845
          }
        }
      }
.....
.....{
        "_index" : "filebeat-7.6.2-2020.05.11",
        "_type" : "_doc",
        "_id" : "0uDGAnIBe1bGH8Hxaj1R",
        "_score" : 1.0,
        "_source" : {
          "message" : "May  9 22:10:43 ubuntu-eoan systemd-logind[692]: New session 3 of user vagrant.",
          "input" : {
            "type" : "log"
          },
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "fileset" : {
            "name" : "auth"
          },
          "agent" : {
            "ephemeral_id" : "3c2d7a67-e0a6-453d-a9d2-a7ee7fa7c946",
            "hostname" : "client",
            "version" : "7.6.2",
            "id" : "05162b46-7489-4258-a919-e831ad2e7908",
            "type" : "filebeat"
          },
          "@timestamp" : "2020-05-11T08:07:09.775Z",
          "host" : {
            "hostname" : "client",
            "id" : "002ec2f2a0b54ced91df112c17524746",
            "name" : "client",
            "architecture" : "x86_64",
            "containerized" : false,
            "os" : {
              "family" : "debian",
              "version" : "19.10 (Eoan Ermine)",
              "platform" : "ubuntu",
              "name" : "Ubuntu",
              "codename" : "eoan",
              "kernel" : "5.3.0-51-generic"
            }
          },
.....
```
3 data above are respentation sample from syslog, auth and audit.

## Kibana Installation
Login ssh to VM3
```bash
vagrant ssh vm3
```
Download kibana first [Kibana Download](https://artifacts.elastic.co/downloads/kibana/kibana-7.6.2-amd64.deb)

Install Kibana
```bash
dpkg -i kibana-7.6.2-amd64.deb
```