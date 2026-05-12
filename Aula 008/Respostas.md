# Tarefa Final - Aula 8 - Docker Swarm

## Questão 1: Conceito de Cluster (Teórica)
**Resposta:** [Docker Compose = gerenciamento local e centralizado; Docker Swarm = orquestração distribuída em cluster.]

## Questão 2: Funções dos Nós (Teórica)
**Resposta:** [controle e inteligência do cluster; Worker = execução de tarefas]

## Questão 3: Inicialização do Swarm (Prática)
a) Comando: `![alt text](image.png)`
b) Driver de Rede: **o![alt text](image-1.png)**

## Questão 4: Criação de Service (Prática)
a) Comando:docker service ls
docker service ps app-stack-tf9
![alt text](image-2.png)
```bash
docker service create --name web-escalavel --replicas 3 nginx:alpine