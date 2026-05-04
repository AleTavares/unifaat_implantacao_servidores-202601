# Respostas TF008 - Docker Swarm

## Questão 1: Conceito de Cluster (Teórica)
A diferença fundamental é que o Docker Compose gerencia um stack de containers em um único host, enquanto o Docker Swarm orquestra o stack em um cluster de múltiplos hosts, permitindo escalabilidade, alta disponibilidade e distribuição de carga.

## Questão 2: Funções dos Nós (Teórica)
- **Manager**: Responsável por gerenciar o estado do cluster, agendar tarefas, manter o consenso e expor a API do Swarm.
- **Worker**: Executa as tarefas (containers) atribuídas pelo manager, sem participar da gestão do cluster.

## Questão 3: Inicialização do Swarm (Prática)
a) Comando: `docker swarm init`
b) Driver de rede padrão: overlay

## Questão 4: Criação de Service (Prática)
a) Comando: `docker service create --name web-escalavel --replicas 3 nginx:alpine`
b) Comando: `docker service ps web-escalavel`

## Questão 5: Atualização e Escalabilidade (Prática)
a) Comando: `docker service scale web-escalavel=5`
b) Capacidade: Auto-healing (ou self-healing)

## Tarefa Prática Integrada

### Passo 1: Inicialização do Cluster
- Limpeza: `docker swarm leave --force` (se ativo)
- Inicialização: `docker swarm init`

Saída da inicialização:
```
Swarm initialized: current node (x29ldnmiqyzgzc5r7putqzgls) is now a manager.
```

### Passo 2: Deploy de um Serviço
Comando: `docker service create --name app-stack-tf9 --publish published=8001,target=80 --replicas 4 nginx:alpine`

Saída:
```
rjgf2lqg19c5m3w8lp9rv9k8h
overall progress: 4 out of 4 tasks 
1/4: running   
2/4: running   
3/4: running   
4/4: running   
verify: Service rjgf2lqg19c5m3w8lp9rv9k8h converged 
```

### Passo 3: Validação e Evidências
1. Verificação: `docker service ls`

Saída (Evidência 1):
```
ID             NAME            MODE         REPLICAS   IMAGE          PORTS
rjgf2lqg19c5   app-stack-tf9   replicated   4/4        nginx:alpine   *:8001->80/tcp
```

2. Acesso: `Invoke-WebRequest -Uri http://localhost:8001 -UseBasicParsing`

Saída (Evidência 2):
```
StatusCode: 200
Content: <!DOCTYPE html>...<title>Welcome to nginx!</title>...
```

### Passo 4: Escalabilidade
Comando: `docker service scale app-stack-tf9=1`

Saída:
```
app-stack-tf9 scaled to 1
overall progress: 1 out of 1 tasks 
1/1: running   
verify: Service app-stack-tf9 converged 
```

### Passo 5: Limpeza Final
- Remover service: `docker service rm app-stack-tf9`
- Sair do Swarm: `docker swarm leave --force`

Saída da remoção: `app-stack-tf9`
Saída da saída: `Node left the swarm.`