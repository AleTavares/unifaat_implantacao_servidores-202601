### Questão 1: Conceito de Cluster:
A diferença fundamental está na escala e resiliência.Docker Compose gerencia o Stack em um único Host. Todos os containers rodam na mesma máquina. Se esse Host falhar, toda a aplicação cai. É usado para desenvolvimento e teste local. Não tem alta disponibilidade nativa nem balanceamento entre máquinas.Docker Swarm gerencia o Stack em um Cluster com múltiplos Hosts, chamados de nós. O Swarm distribui as réplicas dos serviços entre os nós. Se um nó falhar, o Swarm automaticamente recria os containers em outros nós saudáveis. Possui alta disponibilidade, auto-healing e load balancing nativo via routing mesh. É usado para produção.Resumindo: Compose é para uma máquina só. Swarm é para um cluster de máquinas com tolerância a falhas.

### Questão 2: Funções dos Nós:
-Manager Node: É o nó que gerencia o cluster. Suas responsabilidades são manter o estado do cluster, agendar tarefas, orquestrar serviços, gerenciar a comunicação entre nós e eleger um líder usando algoritmo Raft. Só Managers podem executar comandos como docker service e docker node. É recomendado ter um número ímpar de Managers para garantir quorum.
-Worker Node: É o nó que executa as tarefas. Sua única responsabilidade é rodar os containers conforme foi ordenado pelos Managers. Workers não tomam decisões sobre o cluster, apenas executam a carga de trabalho. Não possuem acesso ao estado do cluster.Resumindo: Manager decide e gerencia. Worker executa os containers.

### Questão 3: Inicialização do Swarm:
a)Comando para inicializar um novo Cluster Swarm:
docker swarm init
Se o Host tiver mais de uma interface de rede, use a flag --advertise-addr para especificar o IP:
docker swarm init --advertise-addr IP_DO_HOST
Após executar, o terminal retorna os comandos docker swarm join com tokens para adicionar Managers e Workers ao cluster.

b)Driver de Rede padrão do Swarm para comunicação entre Services em diferentes Hosts:O driver padrão é o overlay.A rede overlay cria uma rede virtual distribuída que permite que containers rodando em nós diferentes do cluster se comuniquem de forma segura, como se estivessem na mesma rede local. O Swarm usa VXLAN para encapsular o tráfego entre os Hosts.
# Para criar manualmente uma rede overlay:
docker network create --driver overlay nome-da-rede

Quando você faz deploy de um Stack no Swarm sem especificar a rede, ele cria automaticamente uma rede overlay para os serviços.

### Questão 4: Criação de Service (Prática)
a) Comando para criar o Service web-escalavel com 3 réplicas:
docker service create --name web-escalavel --replicas 3 nginx:alpine

b) Comando para visualizar o status em tempo real das 3 réplicas:
docker service ps web-escalavel

Esse comando mostra em qual nó cada réplica está rodando, o status atual e o histórico.
### Para acompanhar em tempo real, use:
watch docker service ps web-escalavel
### Ou para ver detalhes gerais do Service:
docker service ls

### Questão 5: Atualização e Escalabilidade (Prática)
a) Comando para aumentar as réplicas de 3 para 5:
docker service scale web-escalavel=5
### Ou usando update:
docker service update --replicas 5 web-escalavel
Os dois fazem a mesma coisa. O Swarm vai criar 2 réplicas novas e distribuir pelos nós disponíveis.

b) Termo que descreve essa capacidade:Self-healing ou Auto-healing.
______________________________________________________________
### Tarefa Prática Integrada (Obrigatória)

# Passo 1: Limpeza e Inicialização
docker swarm leave --force
docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

# Passo 2: Deploy
docker service create --name app-stack-tf9 --replicas 4 --publish 8001:80 nginx:alpine

# Passo 3: Validação
EVIDÊNCIA 01: docker service ps app-stack-tf9
![Print da evidencia 1](/img/saidaDockerServicePs.png)


EVIDÊNCIA 02: curl localhost:8001
![Print da evidencia 2](/img/saidaCurl.png)

# Passo 4: Escalabilidade
docker service scale app-stack-tf9=1

# Passo 5: Limpeza
docker service rm app-stack-tf9
docker swarm leave --force

