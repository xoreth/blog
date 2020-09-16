---
layout: post
title: "[Docker Administration] [Part I] Install Docker and Command Managment"
author: Galuh D Wijatmiko
categories: [Container]
tags: [Docker,Container,Automation]
draft: false
published: true
---

# Introduce Docker
For Overview Docker, please klik [Link](https://docs.docker.com/engine/docker-overview/)


Create 2 Instance with hostname using vagrant [link]({{ site.url }}/notes/2020/03/05/vagrant-running-multiple-vm-using-vagrant-in-one-vagrantfile/) :
1. vm1.roomit.tech 192.168.33.11
2. vm2.roomit.tech 192.168.33.12

Change Hostname in vm1 
```bash
hostnamectl set-hostname vm1.roomit.tech
```
Change Hostname in vm2
```bash
hostnamectl set-hostname vm2.roomit.tech
```

or visit [Link]({{ site.url}}/notes/2016/02/20/set-hostname-in-systemd/)


> Using Ubuntu Bionic

Login to VM Via ssh, open 2 terminal
```bash
vagrant ssh vm1
```

```bash
vagrant ssh vm2
```

in Both Server and please do it :

*Install Docker*

```bash
sudo apt update
sudo apt -y install docker.io
sudo systemctl status docker
```
if not running start service with
```bash
systemctl start docker
```
## Management Images
1. View Docker Version
```bash
sudo docker version
```

2. Check Docker info
```bash
sudo docker info
```

3. Testing Hello World On Docker
```bash
sudo docker run hello-world
```
4. Pull Image
```bash
sudo docker pull wajatmaka/dockerizing:flask
```

5. Lisitng Images
```bash
sudo docker image ls
```

6. Tags Image For Pushing
```bash
sudo docker image push wajatmaka/dockerizing:flask
```

7. Push Image
```bash
sudo docker image push wajatmaka/dockerizing:flask
```

8. Inspect Image
```bash
sudo docker image inspect  [ID IMAGE]
```

8. Build Image
```bash
sudo docker image build .  
```
9. Remove Image
```bash
sudo docker image rm  [ID IMAGE]
```


## Management Container
1. Lisiting Container
```bash
sudo docker container ls -a
```

2. Stop Container
```bash
sudo docker container stop [ID CONTAINER]
```

3. Start Container 
```bash
sudo docker container start [ID CONTAINER]
```

4. Restart Container 
```bash
sudo docker container restart [ID CONTAINER]
```

5. Monitoring Container Realtime
```bash
sudo docker container stats [ID CONTAINER]
```

6. Copy File To Container
```bash
sudo docker container cp [NameOfFile] [ID CONTAINER]:/
```

7. Commit if changes in container, this is will create new image
```bash
sudo docker container commit [[ID CONTAINER] wajatmaka/dockerizing:flask2
```

8. Login To Container
```bash
sudo docker container exec -it [ID CONTAINER] bash
```

9. Show Container Logs
```bash
sudo docker container logs [ID CONTAINER]
```

10. Pause Process Container
```bash
sudo docker container pause  [ID CONTAINER]
```
testing access with curl:
```bash
curl localhost:4000
```
output will be timeout.

11. Unpause Process Container
```bash 
sudo docker container unpause [ID CONTAINER]
```
testing access with curl:
```bash
curl http://localhost:4000
```
output will be get code 200 success.

12. Kill Process Container
```bash
sudo docker container kill [ID CONTAINER]
```

13. Cleaning All Container when Container Stopped
```bash
sudo docker container prune
```

14. Inspect Information Container
```bash
sudo docker container inspect [ID CONTAINER]
```
Inspect Spesific, example how to get IP container:
```bash
 sudo docker container inspect -f "\{\{ \.NetworkSettings.IPAddress \}\}"  [ID CONTAINER]
```

15. Destroy Container
```bash
sudo docker container rm [ID CNTAINER]
```
