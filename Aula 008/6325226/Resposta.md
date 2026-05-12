# Respostas - Aula 008: Docker Swarm - Orquestração e Cluster

Aluno: Weslley Lucas Souza Alves
RA: 6325226
Disciplina: Implementação de Servidor e Nuvem
Data: Abril de 2026

---

## Questão 1: Conceito de Cluster

A principal diferença entre Docker Compose e Docker Swarm está no ambiente em que operam.

O Docker Compose gerencia containers em um único host.

O Docker Swarm permite orquestrar containers em múltiplos hosts (cluster), oferecendo escalabilidade, alta disponibilidade, balanceamento de carga e recuperação de falhas.

---

## Questão 2: Funções dos Nós

Manager: Gerencia o cluster e toma decisões.

Worker: Executa os containers.

---

## Questão 3: Inicialização do Swarm

a)
docker swarm init --advertise-addr 172.24.249.150

b)
overlay

---

## Questão 4: Criação de Service

a)
docker service create --name web-escalavel --replicas 3 nginx:alpine

b)
docker service ps web-escalavel

---

## Questão 5: Atualização e Escalabilidade

a)
docker service scale web-escalavel=5

b)
Auto-healing

---

# TAREFA PRÁTICA

## 🔹 Inicialização do Swarm

![Swarm inicializado](imagens/swarm.png)

---

## 🔹 Evidência 1 - 4 Réplicas

Comando:
docker service ps app-stack-tf9

![4 réplicas rodando](imagens/replicas4.png)

---

## 🔹 Evidência 2 - Acesso com curl

Comando:
curl 127.0.0.1:8001

![Resultado do curl](imagens/curl.png)

---

## 🔹 Escalabilidade - Redução para 1 réplica

Comando:
docker service scale app-stack-tf9=1

![1 réplica rodando](imagens/escala1.png)

---

## 🔹 Limpeza Final

docker service rm app-stack-tf9
docker swarm leave --force

---

## Conclusão

O Docker Swarm permite orquestração de containers com escalabilidade e alta disponibilidade. Foi possível criar, monitorar e escalar serviços com sucesso, mesmo em um cluster de um único nó.
