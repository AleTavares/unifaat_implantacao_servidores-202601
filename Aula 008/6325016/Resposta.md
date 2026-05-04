# TF - Tarefa Final - Aula 8

**Disciplina:** Implementação de servidor e nuvem (cloud)

---

## **Questão 1: Conceito de Cluster**

A principal diferença entre Docker Compose e Docker Swarm está na forma como os containers são gerenciados:

* **Docker Compose**: gerencia containers em um único host (máquina), sendo mais utilizado para desenvolvimento local e sem recursos avançados de tolerância a falhas.
* **Docker Swarm**: gerencia containers em um cluster (conjunto de máquinas), permitindo alta disponibilidade, balanceamento de carga e escalabilidade.

---

## **Questão 2: Funções dos Nós**

* **Manager**:

  * Responsável por gerenciar o cluster
  * Controla o estado desejado dos serviços
  * Distribui tarefas para os nós Workers

* **Worker**:

  * Executa os containers (tasks)
  * Recebe instruções do Manager

---

## **Questão 3: Inicialização do Swarm**

### a) Comando para inicializar o Swarm:

```bash
sudo docker swarm init --advertise-addr 172.18.86.37
```

---

### b) Driver de rede padrão:

O driver de rede utilizado pelo Docker Swarm por padrão é o **overlay**.

---

## **Questão 4: Criação de Service**

### a) Criar o service com 3 réplicas:

```bash
sudo docker service create --name web-escalavel --replicas 3 nginx:alpine
```

---

### b) Ver status das réplicas:

```bash
sudo docker service ps web-escalavel
```

---

## **Questão 5: Atualização e Escalabilidade**

### a) Aumentar de 3 para 5 réplicas:

```bash
sudo docker service scale web-escalavel=5
```

---

### b) Nome da capacidade:

Essa capacidade é chamada de **auto-healing (auto-recuperação)**.

---

# 🚀 **Tarefa Prática Integrada**

## **Passo 1: Inicialização do Cluster**

### Limpeza:

```bash
sudo docker swarm leave --force
```

---

### Inicialização:

```bash
sudo docker swarm init --advertise-addr 172.18.86.37
```


---

## **Passo 2: Deploy de um Serviço**

```bash
sudo docker service create \
  --name app-stack-tf9 \
  --publish 8001:80 \
  --replicas 4 \
  nginx:alpine
```

---

## **Passo 3: Validação e Evidências**

### Verificação das réplicas:

```bash
sudo docker service ps app-stack-tf9
```

**Evidência 1:**
![Evidência 1:](/Aula%20008/6325016/img/eviden1.png)

---

### Teste de acesso:

```bash
curl 127.0.0.1:8001
```

**Evidência 2:**

Resultado do comando:

![Evidência 2:](/Aula%20008/6325016/img/image.png)

---

## **Passo 4: Escalabilidade**

Reduzindo de 4 para 1 réplica:

```bash
sudo docker service scale app-stack-tf9=1
```

Verificação:

```bash
sudo docker service ps app-stack-tf9
```

---

## **Passo 5: Limpeza Final**

Remoção do Service:

```bash
sudo docker service rm app-stack-tf9
```

Saída do Swarm:

```bash
sudo docker swarm leave --force
```

---

# 📌 **Observações Finais**

A atividade demonstrou na prática o funcionamento de um cluster Docker Swarm em nó único, incluindo criação, escalabilidade e gerenciamento de serviços.
