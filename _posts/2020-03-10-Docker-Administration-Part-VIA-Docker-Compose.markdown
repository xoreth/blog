---
layout: post
title: "[Docker Administration] [Part VI.A] Docker Compose - Installation and Management"
author: Galuh D Wijatmiko
categories: [Container]
tags: [docker,container,orchestration]
draft: true
published: false
---

###################
##### Compose #####
###################


##### Instal Compose #####

#1. Unduh Compose
sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

#2. Set permisson executable
sudo chmod +x /usr/local/bin/docker-compose

#3. Uji instalasi
sudo docker-compose --version


##### Compose & Wordpress #####

#1. Buat direktori my_wordpress dan masuk ke direktori tersebut
mkdir /latihan/my_wordpress
cd /latihan/my_wordpress

#2. Buat file docker-compose.yml
vim docker-compose.yml

version: '3.2'

services:
   db:
     image: mysql:5.7
     volumes:
       - dbdata:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: [username]
       MYSQL_PASSWORD: [password]

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: [username]
       WORDPRESS_DB_PASSWORD: [password]
volumes:
    dbdata:


#3. Jalankan compose
sudo docker-compose up -d

#4. Tampilkan daftar container
sudo docker container ls

#5. Uji browsing ke ke halaman wordpress yang sudah dibuat

#K> Screenshot jika sukses menampilkan halaman wordpress. Beri nama X-do-adm-K.png

#6. Hapus container, default network dan database wordpress
sudo docker-compose down --volumes


##### Compose & app.py #####

#1. Buat direktori my_app dan masuk ke direktori tersebut
mkdir /latihan/my_app
cd /latihan/my_app

#2. Buat file app.py
vim app.py

import time

import redis
from flask import Flask


app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)


def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)


@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)


#3. Buat file requirements.txt
vim requirements.txt

flask
redis


#4. Buat file Dockerfile
vim Dockerfile

FROM python:3.4-alpine
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]


#5. Buat file docker-compose.yml
vim docker-compose.yml

version: '3.2'
services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
  redis:
    image: "redis:alpine"


#6. Jalankan compose
sudo docker-compose up -d

#7. Uji browsing ke http://10.X.X.11:5000
curl http://10.X.X.11:5000

#8. Menampilkan compose aktif
sudo docker-compose ps

#9. Menampilkan environment variable di service web
sudo docker-compose run web env

#10. Hapus container, default network dan database app.py
sudo docker-compose down --volumes



##################
##### Secret #####
##################


##### Get started with secrets #####

#1. Membuat secret
printf "This is a secret" | sudo docker secret create my_secret_data -

#2. Membuat service redis dan mengizinkan akses secret my_secret_data
sudo docker service  create --name redis --secret my_secret_data redis:alpine

#3. Verifikasi service redis
sudo docker service ps redis

#4. Baca content di dalam container
sudo docker ps --filter name=redis -q
sudo docker container exec $(docker ps --filter name=redis -q) ls -l /run/secrets
sudo docker container exec $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data

#5. Verifikasi secret tidak ada di image hasil commit container
sudo docker commit $(docker ps --filter name=redis -q) committed_redis
sudo docker run --rm -it committed_redis cat /run/secrets/my_secret_data

##### Quiz #####

1. Hapus Secret tanpa menghapus container service redis

#L> Verifikasi bahwa secret sudah berhasil dihapus. Beri nama X-do-adm-L.png

2. Buatlah 3 container, denngan ketentuan sebagai berikut :

*Container 1 :

Name : ct-one
Image : alpine
Hostname : kotak1


*Container 2 :

Name : ct-two
Image : alpine
Hostname : kotak2

*Container 3 :

Name : ct-three
Image : alpine
Hostname : kotak3

#M> Lakukan verifikasi hostname & IP pada masing masing container. Beri nama X-do-adm-M.png

#N> pastikan Container1 hanya bisa diakses dari Container3, lakukan verifikasi ping ke masing masing container. Beri nama X-do-adm-N.png


