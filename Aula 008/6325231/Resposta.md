# TF - Aula 8 (Docker Swarm)

## Questão 1: Conceito de Cluster

A diferença fundamental é que o Docker Compose gerencia containers em um único host (máquina), enquanto o Docker Swarm gerencia containers em um cluster de múltiplos nós. O Swarm permite distribuição de serviços, escalabilidade e alta disponibilidade entre várias máquinas.

## Questão 2: Funções dos Nós

O nó Manager é responsável por gerenciar o cluster, tomar decisões, distribuir tarefas e manter o estado do sistema.  
O nó Worker executa as tarefas atribuídas pelo Manager, ou seja, roda os containers.

## Questão 3: Inicialização do Swarm

a) O comando para inicializar um novo cluster Swarm é:
docker swarm init

b) O driver de rede padrão utilizado pelo Swarm é o overlay.

## Questão 4: Criação de Service

a) Comando:
docker service create --name web-escalavel --replicas 3 nginx:alpine

b) Comando para verificar:
docker service ps web-escalavel

## Questão 5: Atualização e Escalabilidade

a) Comando:
docker service scale web-escalavel=5

b) Essa capacidade é chamada de alta disponibilidade (High Availability).
