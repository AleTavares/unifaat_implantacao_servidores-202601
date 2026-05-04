Questão 1: Conceito de Cluster (Teórica)

A diferença fundamental está na escala e arquitetura:

Docker Compose:
Gerencia containers em um único host.
Não possui suporte nativo a alta disponibilidade.
Indicado para desenvolvimento e ambientes simples.
Docker Swarm:
Gerencia serviços em um cluster de múltiplos nós.
Possui orquestração, balanceamento de carga e tolerância a falhas.
Permite escalabilidade horizontal.

Questão 2: Funções dos Nós (Teórica)
Manager:
Responsável por orquestrar o cluster.
Gerencia estado desejado, serviços e tarefas.
Decide onde os containers serão executados.
Worker:
Executa as tarefas atribuídas pelo Manager.
Não toma decisões, apenas executa containers.


Questão 3: Inicialização do Swarm (Prática)

a) Comando para inicializar o cluster:

docker swarm init

b) Driver de rede padrão:

overlay
Questão 4: Criação de Service (Prática)

a) Criar o service com 3 réplicas:

docker service create --name web-escalavel --replicas 3 nginx:alpine

b) Ver status das réplicas:

docker service ps web-escalavel
Questão 5: Atualização e Escalabilidade (Prática)

a) Aumentar réplicas de 3 para 5:

docker service scale web-escalavel=5

b) Termo teórico:

Auto-healing (autocura) ou self-healing