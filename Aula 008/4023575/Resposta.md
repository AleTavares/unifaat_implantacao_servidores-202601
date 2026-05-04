# TF - Tarefa Final - Aula 8 (Docker Swarm)

## RA: 4023575

## Nome: Emilly Santos de Oliveira

---

# 🧠 Questões Teóricas

## Questão 1: Conceito de Cluster

A principal diferença entre Docker Compose e Docker Swarm está na forma como os containers são gerenciados.

O Docker Compose é utilizado para gerenciar aplicações em um único host, sendo mais simples e voltado para desenvolvimento local. Já o Docker Swarm trabalha com um cluster de múltiplos nós, permitindo distribuir containers entre diferentes máquinas, oferecendo escalabilidade, alta disponibilidade e tolerância a falhas.

---

## Questão 2: Funções dos Nós

No Docker Swarm existem dois tipos principais de nós:

* **Manager**: responsável por gerenciar o cluster, tomar decisões de orquestração, agendar serviços e manter o estado desejado da aplicação.
* **Worker**: responsável por executar os containers conforme as instruções recebidas do Manager.

---

## Questão 3: Inicialização do Swarm

### a) Comando para inicializar o cluster:

docker swarm init

### b) Driver de rede utilizado:

overlay

---

## Questão 4: Criação de Service

### a) Criar o service com 3 réplicas:

docker service create --name web-escalavel --replicas 3 nginx:alpine

### b) Verificar o status das réplicas:

docker service ps web-escalavel

---

## Questão 5: Atualização e Escalabilidade

### a) Aumentar o número de réplicas para 5:

docker service scale web-escalavel=5

### b) Termo que descreve essa capacidade:

Auto-healing (ou Self-healing)

---

# ⚙️ Tarefa Prática Integrada

## 🔹 Passo 1: Inicialização do Cluster

### Limpeza do ambiente:

docker swarm leave --force

### Inicialização do cluster:

docker swarm init

---

## 🔹 Passo 2: Deploy do Serviço

docker service create \
  --name app-stack-tf9 \
  --replicas 4 \
  -p 8001:80 \
  nginx:alpine

---

## 🔹 Passo 3: Validação e Evidências

### Verificação do status das réplicas:

docker service ps app-stack-tf9

### 📸 Evidência 1:

![alt text](image.png)

---

### Teste de acesso externo:

curl localhost:8001

### 📸 Evidência 2:

![alt text](image-1.png)

---

## 🔹 Passo 4: Escalabilidade

docker service scale app-stack-tf9=1

---

## 🔹 Passo 5: Limpeza Final

docker service rm app-stack-tf9
docker swarm leave --force
