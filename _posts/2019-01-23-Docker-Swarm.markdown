---
layout: post
title: Learn Docker Swarm
author: Galuh D Wijatmiko
categories: [Provisioning]
tags: [Cluster,Docker,Container,Swarm,automation]
---
# Docker Swarm #

## VM1 ##
Iniziate docker manager

```bash
docker swarm init --advertise-addr $(hostname -i)
```
Output :
```bash
Swarm initialized: current node (qdrdp07xbugnshpy9k8ci4r8o) is now a manager.
To add a worker to this swarm, run the following command:
    docker swarm join --token SWMTKN-1-1x8za7xd18khl5d6ksq0x8coxf1ggl4t1nkipywtn6s1hjfici-635zjltegdf22beb93utab7zx 192.168.33.11:2377
To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instruction
```

How show token init as manager and worker

```bash
docker swarm join-token manager
docker swarm join-token worker
```

Show worker and manager running in node :

```bash
docker node ls
```


## VM2 and VM3 ##
join as worker 

```bash
docker swarm join --token SWMTKN-1-1x8za7xd18khl5d6ksq0x8coxf1ggl4t1nkipywtn6s1hjfici-635zjltegdf22beb93utab7zx 192.168.33.11:2377
```

Check node running :

```bash
docker node ls
```

## VM1 ##
Cloning application :

```bash
git clone https://github.com/docker/example-voting-app
cd example-voting-app
```

Deploy Stack 

```bash
docker stack deploy --compose-file=docker-stack.yml voting_stack
```
Output :
```bash
Creating network voting_stack_default
Creating network voting_stack_frontend
Creating network voting_stack_backend
Creating service voting_stack_worker
Creating service voting_stack_visualizer
Creating service voting_stack_redis
Creating service voting_stack_db
Creating service voting_stack_vote
Creating service voting_stack_result
```

Show the Stack 

```bash
docker stack ls
```
Output:
```bash
[senops@vm1 example-voting-app]$ docker stack ls
NAME                SERVICES            ORCHESTRATOR
voting_stack        6                   Swarm
```

List service on stack

```bash
docker stack services voting_stack
```
Output :
```bash
ID                  NAME                      MODE                REPLICAS            IMAGE                                          PORTS
04ya3j6mlzlu        voting_stack_visualizer   replicated          1/1                 dockersamples/visualizer:stable                *:8080->8080/tcp
dg8olqegoke5        voting_stack_vote         replicated          2/2                 dockersamples/examplevotingapp_vote:before     *:5000->80/tcp
dt8xk7alhgkr        voting_stack_redis        replicated          1/1                 redis:alpine                                   
jeftuc5zvx6q        voting_stack_worker       replicated          0/1                 dockersamples/examplevotingapp_worker:latest   
k0f2zu5lybi4        voting_stack_result       replicated          1/1                 dockersamples/examplevotingapp_result:before   *:5001->80/tcp
ry34ib8sfdxx        voting_stack_db           replicated          1/1                 postgres:9.4     
```

List every stack service in worker
```bash
docker service ps voting_stack_vote
```
Output:
```bash
ID                  NAME                      IMAGE                                        NODE                DESIRED STATE       CURRENT STATE             ERROR                              PORTS
oe8i96dufht4        voting_stack_vote.1       dockersamples/examplevotingapp_vote:before   vm2.wajatmaka.com   Running             Running 20 minutes ago                                       
npmcpvc3vpnc         \_ voting_stack_vote.1   dockersamples/examplevotingapp_vote:before   vm2.wajatmaka.com   Shutdown            Rejected 22 minutes ago   "No such image: dockersamples/…"   
y20jrj7gza2c        voting_stack_vote.2       dockersamples/examplevotingapp_vote:before   vm3.wajatmaka.com   Running             Running 21 minutes ago         
```
Check Service in stack

```bash
docker service ps voting_stack_redis
```
Output:
```bash
ID                  NAME                   IMAGE               NODE                DESIRED STATE       CURRENT STATE         ERROR               PORTS
0bhkel67jw5w        voting_stack_redis.1   redis:alpine        vm2.wajatmaka.com   Running             Running 2 hours ago     
```
```bash
docker service ps voting_stack_db
```
Output:
```bash
[senops@vm1 example-voting-app]$ docker service ps voting_stack_db
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE         ERROR               PORTS
rk13xw3mehzd        voting_stack_db.1   postgres:9.4        vm1.wajtamaka.com   Running             Running 2 hours ago 
```

## SCALING UP STACK SERVICE ##

```bash
docker service scale voting_stack_vote=5
```
Output :
```bash
voting_stack_vote scaled to 5
overall progress: 5 out of 5 tasks 
1/5: running   
2/5: running   
3/5: running   
4/5: running   
5/5: running   
verify: Service converged 
```
Check Service in Stack
```bash
docker service ps voting_stack_vote
```
Output:
```bash
[senops@vm1 example-voting-app]$ docker service ps voting_stack_vote
ID                  NAME                      IMAGE                                        NODE                DESIRED STATE       CURRENT STATE           ERROR                              PORTS
oe8i96dufht4        voting_stack_vote.1       dockersamples/examplevotingapp_vote:before   vm2.wajatmaka.com   Running             Running 2 hours ago                                        
npmcpvc3vpnc         \_ voting_stack_vote.1   dockersamples/examplevotingapp_vote:before   vm2.wajatmaka.com   Shutdown            Rejected 2 hours ago    "No such image: dockersamples/…"   
y20jrj7gza2c        voting_stack_vote.2       dockersamples/examplevotingapp_vote:before   vm3.wajatmaka.com   Running             Running 2 hours ago                                        
dzlna4scadxb        voting_stack_vote.3       dockersamples/examplevotingapp_vote:before   vm2.wajatmaka.com   Running             Running 3 minutes ago                                      
sbcosy4tb2gh        voting_stack_vote.4       dockersamples/examplevotingapp_vote:before   vm1.wajtamaka.com   Running             Running 2 minutes ago                                      
j2d8k18vkn7w        voting_stack_vote.5       dockersamples/examplevotingapp_vote:before   vm3.wajatmaka.com   Running             Running 3 minutes ago    
```

## SCALING DOWN STACK SERVICE ##
```bash
 docker service scale voting_stack_vote=2
```


## Flow ##
![Alt-Text](https://blog.roomit.tech/img/swarm-stack.jpg)
