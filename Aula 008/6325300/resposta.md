Questão 1: Conceito de Cluster
O Docker Compose gerencia contêineres em um único host físico ou virtual. Já o Docker Swarm orquestra e distribui contêineres através de um cluster formado por múltiplos hosts, garantindo alta disponibilidade e balanceamento de carga.

Questão 2: Funções dos Nós

Manager: Gerencia o estado do cluster, distribui as tarefas, gerencia os serviços e mantém a orquestração funcionando.

Worker: Tem a função exclusiva de receber e executar as tarefas (contêineres) delegadas pelo nó Manager.

Questão 3: Inicialização do Swarm
a) docker swarm init
b) O driver de rede padrão é o overlay.

Questão 4: Criação de Service
a) docker service create --name web-escalavel --replicas 3 nginx:alpine
b) docker service ps web-escalavel

Questão 5: Atualização e Escalabilidade
a) docker service scale web-escalavel=5
b) Esse comportamento é chamado de Self-healing (ou Reconciliação de Estado).