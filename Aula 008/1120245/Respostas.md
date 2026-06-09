1. Conceito de Cluster (Teórica)

A diferença fundamental entre Docker Compose e Docker Swarm está no escopo e capacidade de orquestração:

Docker Compose:
Gerencia containers em um único Host
Voltado para desenvolvimento/local
Não possui escalabilidade automática
Não possui tolerância a falhas

Docker Swarm:
Gerencia containers em um cluster de múltiplos nós
Voltado para produção
Possui escalabilidade automática (replicas)
Possui load balancing nativo
Possui autorrecuperação (self-healing)


2. Funções dos Nós (Teórica)

Manager:
Responsável por gerenciar o cluster
Controla o estado desejado (desired state)
Agenda serviços e distribui tarefas
Mantém o consenso do cluster

Worker:
Executa os containers (tasks)
Recebe instruções do Manager
Não toma decisões sobre o cluster

3. Questão 3: Inicialização do Swarm
a) Comando para inicializar o cluster:
# docker swarm init
b) Driver de rede padrão:

O Docker Swarm utiliza o driver:

overlay

Ele permite comunicação entre containers em diferentes nós do cluster.

4. Criação de Service
a) Comando para criar o Service:
docker service create \
--name web-escalavel \
--replicas 3 \
nginx:alpine
b) Comando para visualizar status das réplicas:
docker service ps web-escalavel

5. Atualização e Escalabilidade
a) Comando para escalar de 3 para 5 réplicas:
docker service scale web-escalavel=5
b) Termo que descreve essa capacidade:

Autorrecuperação (Self-healing)

O Swarm garante que o estado desejado seja mantido automaticamente.




# Passo 1: Inicialização do Cluster
Limpeza (caso já exista Swarm):
docker swarm leave --force
Inicialização:
docker swarm init

# Passo 2: Deploy de um Serviço
docker service create \
--name app-stack-tf9 \
--replicas 4 \
-p 8001:80 \
nginx:alpine

# Passo 3: Validação e Evidências
Evidência 1: Status das réplicas
docker service ps app-stack-tf9

# Passo 4: Escalabilidade (redução)
docker service scale app-stack-tf9=1


# Passo 5: Limpeza Final
Remover o Service:
docker service rm app-stack-tf9