Questão 1: Conceito de Cluster

A diferença fundamental é que o Docker Compose gerencia containers em um único host, enquanto o Docker Swarm gerencia serviços em um cluster de múltiplos nós.

No Docker Compose, todos os containers são executados localmente em uma única máquina, sem distribuição ou tolerância a falhas. Já no Docker Swarm, os serviços podem ser distribuídos entre vários nós, permitindo escalabilidade, balanceamento de carga e alta disponibilidade.

Questão 2: Funções dos Nós

O nó Manager é responsável por gerenciar o cluster, tomar decisões de orquestração, controlar os serviços e manter o estado desejado do sistema.

O nó Worker é responsável por executar as tarefas atribuídas pelo Manager, ou seja, ele roda os containers dos serviços.

Questão 3: Inicialização do Swarm

a) Comando:

docker swarm init

b) O driver de rede padrão utilizado é o overlay.

Questão 4: Criação de Service

a) Comando:

docker service create --name web-escalavel --replicas 3 nginx:alpine

b) Comando para visualizar o status das réplicas:

docker service ps web-escalavel

Questão 5: Atualização e Escalabilidade

a) Comando:

docker service scale web-escalavel=5

b) Essa capacidade é chamada de auto-healing.


Tarefa Prática

Passo 1: Inicialização do Cluster

docker swarm leave --force
docker swarm init

Passo 2: Deploy de um Serviço

docker service create --name app-stack-tf9 --replicas 4 -p 8001:80 nginx:alpine

Passo 3: Evidência 1

docker service ps app-stack-tf9

Passo 3: Evidência 2

curl 127.0.0.1:8001

Passo 4: Escalabilidade

docker service scale app-stack-tf9=1

Passo 5: Limpeza Final

docker service rm app-stack-tf9
docker swarm leave --force