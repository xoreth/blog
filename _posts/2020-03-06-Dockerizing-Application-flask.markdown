---
layout: post
title: "[Docker Administration] [Part II] Dockerizing Application Flask "
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker]
draft: false
published: true
---

The next Step continuous from [Docker Administration]({{ site.url }}/notes/2020/03/05/docker-administration-install-docker)

Create Folder Project

```bash
mkdir -p Project/Flask
cd Project/Flask
```

Create requirements.txt file
```bash
echo -e "Flask\nRedis" > requirements.txt
```

Create app.py
```bash
vim app.py
```

```bash
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```

Create Dockerfile
```bash
vim Dockerfile
```
Fill with this Instruction:
```bash
FROM python:2.7-slim
RUN mkdir -p /app
WORKDIR /app 
ADD . /app
RUN cd /app && pip install  -r /app/requirements.txt 
EXPOSE 80 
ENV NAME World 
CMD ["python", "app.py"] 
```

Build Docker File Using Image friendlyhello
```bash
sudo docker build -t friendlyhello .
```

Show Images
```bash
sudo docker image ls
```

Running Image As Container
```bash
sudo docker run -d -p 4000:80 friendlyhello
```

Show Container UP
```bash
sudo docker container ls
```

Validation or test applicaiton
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