Questão 1: A diferença principal é que o Docker Compose é usado para rodar e organizar vários containers em um único host (uma máquina só), enquanto o Docker Swarm é usado para gerenciar containers em várias máquinas (um cluster).

No Docker Compose, tudo roda localmente e é mais simples, sendo ideal para desenvolvimento e testes. Já no Docker Swarm, ele distribui os containers entre vários nós, trazendo recursos como escalabilidade, alta disponibilidade e balanceamento de carga.

Questão 2: No Docker Swarm existem dois papéis principais:
Manager: é o nó responsável por controlar o cluster. Ele gerencia o estado dos serviços, toma decisões (como onde os containers vão rodar) e mantém tudo organizado.
Worker: é o nó que executa as tarefas. Ele recebe as instruções do Manager e roda os containers na prática.

Manager = gerencia e decide
Worker = executa

Questão 3:
a):docker swarm init
b):O driver de rede padrão usado pelo Docker Swarm é o overlay.
Ele permite a comunicação entre containers que estão em diferentes hosts (nós) como se estivessem na mesma rede.

Questão 4: 
a):docker service create --name web-escalavel --replicas 3 nginx:alpine
b):docker service ps web-escalavel

Questão 5: 
a):docker service scale web-scaling-9=5
b):docker service ps web-scaling-9

Passo 1:
docker swarm leave --force
docker swarm init

Passo 2: 
docker service create --name app-stack-tf9 --replicas 4 -p 8001:80 nginx:alpine

Passo 4:
docker service scale app-stack-tf9=1

Passo 5:
docker service rm app-stack-tf9
docker swarm leave --force