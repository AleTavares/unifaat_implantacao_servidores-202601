Questoes

1- a diferença é a que o swarm gerencia varios nós

2- Os Manegers é como se fosse o gerente de uma loja ele gerencia e da ordens ao works
aonde acontece as tarefas

3-a) docker swarm init
B) a rede Overlay

4-A)docker service create \
--name web-escalavel \
--replicas 3 \
nginx:alpine

B)docker service ps web-escalavel


5-A)docker service scale web-escalavel=5

B)O Termo é tolerancia a falhas


PARTE PRATICA

Passo 1 
 docker info | grep Swarm
 docker swarm init
 docker node ls

Passo 2
 docker service create \
--name app-stack-tf9 \
--replicas 4 \
-p 8001:80 \
nginx:alpine
```

Passo 3

Na pasta print

Passo 4

docker service scale app-stack-tf9=1

Passo 5

docker service rm app-stack-tf9
docker swarm leave --force
docker info | grep Swarm