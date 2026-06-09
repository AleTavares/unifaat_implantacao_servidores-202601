Questão 1-) Docker Compose: roda containers em um único host (local), sem cluster nem alta disponibilidade.
Docker Swarm: gerencia containers em vários hosts (cluster), com distribuição, escala e tolerância a falhas.

Questão 2-) * **Manager:** gerencia o cluster — decide onde os containers vão rodar, mantém o estado do sistema e controla os nós.
* **Worker:** executa as tarefas — roda os containers conforme as instruções do Manager.

Questão 3-) a) Para inicializar um novo cluster Swarm:
docker swarm init
b) O driver de rede padrão para comunicação entre serviços em diferentes nós é o:
overlay

Questão 4 -)  b) Ver o status das réplicas:
docker service ps web-escalavel

Questão 5 -) b) Termo:
Auto-healing (ou Self-healing)

