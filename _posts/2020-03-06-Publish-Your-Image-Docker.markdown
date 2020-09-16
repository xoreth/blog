---
layout: post
title: "[Docker Administration] [Part III] Publish Your Image Docker"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker]
draft: false
published: true
---

The next Step continuous from [Docker Administration]({{ site.url }}/notes/2020/03/06/dockerizing-application-flask/)


If you have account in docker hub [docker.hub](https://hub.docker.com), just login using :
```bash
sudo docker login
```
Tag Your Images
```bash
sudo docker tag friendlyhello [USER]/RepositoryName:YourTags
```
ex:
```bash
sudo docker tag  d964aca327df wajatmaka/dockerizing:flask
```

Show Images 
```bash
sudo docker image ls
```
Output
```bash
....
wajatmaka/dockerizing   flask               d964aca327df        10 minutes ago      159MB
....
```

Push Image to Repo Hub
```bash
sudo docker push [USER]/RepositoryName:YourTags
```
ex:
```bash
sudo docker push wajatmaka/dockerizing:flask
```
Destroy all images
```bash
sudo docker image ls -a -q | xargs sudo docker rmi -f
```

Show Images 
```bash
sudo docker image ls -a
```

Got to web hub.docker.com, change mode private to public in settings after you login

Pull Images
```bash
sudo docker pull wajatmaka/dockerizing:flask
```

Show Images
```bash
sudo docker imag ls -a
```

Pull and Run Docker Images have uploadeded
```bash
sudo docker run -d -p 4000:80 wajatmaka/dockerizing:flask
```

Show Container
```bash
sudo docker container ls
```

Test Web
```bash
curl http://localhost:4000
```

Stop Container
```bash
sudo docker container stop [CONTAINER ID]
```

Show Container
```bash
sudo docker container ls -a
```