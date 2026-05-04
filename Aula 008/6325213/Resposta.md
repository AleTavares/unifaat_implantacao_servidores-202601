## RA 6325213 - Daniel Alves Pinheiro

## Questão 1: Conceito de Cluster
Docker Compose é utilizado para definir e gerenciar múltiplos containers em um único Host (máquina), sendo mais indicado para ambientes de desenvolvimento, testes e aplicações locais. Ele organiza serviços de forma simples, mas não oferece orquestração distribuída entre vários servidores.

Docker Swarm é uma ferramenta de orquestração que gerencia containers em um Cluster de múltiplos Hosts (nós), permitindo escalabilidade, balanceamento de carga, alta disponibilidade e tolerância a falhas. Com Swarm, os serviços podem ser distribuídos entre diferentes máquinas garantindo maior robustez para ambientes de produção

### Questão 2: Funções dos Nós
Manager: Responsável por gerenciar o cluster, manter o estado do Swarm, controlar serviços, tomar decisões e distribuir tarefas para os nós.

Worker: Responsável por executar os containers e tarefas atribuídas pelo Manager.

## Questão 3: Inicialização do Swarm
a) docker swarm init
b) overlay

## Questão 4: Criação de Service
a) docker service create --name web-escalavel --replicas 3 nginx:alpine
b) docker service ps web-escalavel

## Questão 5: Atualização e Escalabilidade
a) docker service scale web-escalavel=5
b) auto-healing

## Tarefa Prática Integrada

### Passo 1: Inicialização do Cluster
![alt text](<Captura de tela 2026-04-27 212945.png>)
1. Limpeza: docker swarm leave --force
2. Inicialização: docker swarm init

### Passo 2: Deploy de um Serviço
docker service create --name app-stack-tf9 --publish published=8001,target=80 --replicas 4 nginx:alpine

### Passo 3: Validação e Evidências
1. docker service ps app-stack-tf9
   (Evidência 1: saída do comando)

2. curl localhost:8001
   (Evidência 2: saída do curl)

### Passo 4: Escalabilidade
docker service scale app-stack-tf9=1

### Passo 5: Limpeza Final
1. docker service rm app-stack-tf9
2. docker swarm leave --force
