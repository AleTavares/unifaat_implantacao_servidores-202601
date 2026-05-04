## questão 1 
A diferença fundamental é que o Docker Compose gerencia contêineres em um único host, criando um "stack" local sem distribuição. Já o Docker Swarm orquestra contêineres em um cluster de múltiplos hosts, permitindo escalabilidade, alta disponibilidade e distribuição automática de workloads entre nós.

## questão 2
Manager: Responsável por gerenciar o estado do cluster, agendar tarefas, manter o consenso (usando Raft) e expor a API do Swarm. Pode executar workloads, mas seu foco é controle.
Worker: Executa apenas as tarefas (contêineres) atribuídas pelo manager. Não participa do gerenciamento do cluster.

## quetão 3 
a) Comando para inicializar: docker swarm init
b) Driver de rede padrão: overlay

## questão 4
a) Comando: docker service create --name web-escalavel --replicas 3 nginx:alpine
b) Comando para visualizar status: docker service ps web-escalavel

## questão 5
a) Comando: docker service scale web-escalavel=5
b) Termo: Resiliência ou Auto-healing (capacidade de recuperação automática).

## tarefa pratica 
 
### passo 1 
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2020-37-17.png)

docker swarm leave --force
docker swarm init

### passo 2 
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2020-44-51.png)

docker service create --name app-stack-tf9 --publish published=8001,target=80 --replicas 4 nginx:alpine


### passo 3

## eviência 1 
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2020-49-27.png)

docker service ps app-stack-tf9

## evidência 2
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2020-55-22.png)

curl localhost:8001

### passo 4
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2020-59-39.png)

docker service scale app-stack-tf9=1

### passo 5
![alt text](./imagens/Captura%20de%20tela%20de%202026-04-27%2021-04-38.png)

docker service rm app-stack-tf9
docker swarm leave

