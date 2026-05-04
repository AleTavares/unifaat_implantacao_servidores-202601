Questão 1: Conceito de Cluster
Qual é a diferença fundamental entre um ambiente Docker rodando com **Docker Compose** (que gerencia o *Stack* em um único Host) e um ambiente orquestrado com **Docker Swarm** (que gerencia o *Stack* em um *Cluster*)?

R:
O Docker Compose organiza containers em um único host, enquanto o Docker Swarm orquestra e distribui serviços em um cluster de múltiplas máquinas, garantindo escalabilidade, balanceamento de carga e alta disponibilidade.

Questão 2: Funções dos Nós
Dentro de um *Cluster* Swarm, existem dois papéis principais: **Manager** e **Worker**. Explique brevemente as responsabilidades de cada um desses papéis.

R:
Os nós Manager controlam e orquestram o cluster, tomando decisões e distribuindo tarefas, enquanto os nós Worker apenas executam os containers conforme as instruções recebidas.


Questão 3: Inicialização um novo Cluster  Swarm

a)
docker swarm init

![alt text](<Comando inicializar Sawrm .png>)

b)
utiliza a rede Overlay para roteamento garantindo distribuiçao equilibrada de todos os conteiner disponiveis

 Questão 4: Criação de Service 


 a) **Prática:** Qual comando você deve usar para criar um novo *Service* chamado **`web-escalavel`**, utilizando a imagem `nginx:alpine`, e **escalando**-o para ter 3 réplicas (instâncias) no *Cluster*?

 ![alt text](<Comando Serviço .png>)


b) Qual comando você deve usar imediatamente após o lançamento para **visualizar o *status* em tempo real** das 3 réplicas do *Service*?

 docker service ps web-scaling-9
 
 ![alt text](<docker servisse.png>)


 Questão 5: Atualização e Escalabilidade


a) **Prática:** Qual comando você deve usar para **aumentar** a contagem de réplicas do *Service* `web-escalavel` de 3 para **5**?

 docker service scale web-scaling-3=5

![alt text](<aumentar replicas.png>)


b) **Teórica:** Se um dos nós do *Cluster* falhar, o Swarm tentará realocar automaticamente as instâncias perdidas para outros nós saudáveis. Qual termo descreve essa capacidade do Swarm?

R:Auto-healing (Self-healing)

É a capacidade do Docker Swarm de recriar automaticamente containers em outros nós quando algum falha.


c:\users\denis\Pictures\Screenshots\local.png

c:\users\denis\Pictures\Screenshots\apagar tudo.png