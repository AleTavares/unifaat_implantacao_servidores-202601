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

## Evidência 1

ID NAME IMAGE NODE DESIRED STATE CURRENT STATE ERROR PORTS
vb9nmac2a4bs app-stack-tf9.1 nginx:alpine andreyhv15 Running Running 4 minutes ago
y5vblzgrz80n app-stack-tf9.2 nginx:alpine andreyhv15 Running Running 4 minutes ago
nimwz05n9v5t app-stack-tf9.3 nginx:alpine andreyhv15 Running Running 4 minutes ago
abigr618mrwk app-stack-tf9.4 nginx:alpine andreyhv15 Running Running 4 minutes ago

## Evidência 2


