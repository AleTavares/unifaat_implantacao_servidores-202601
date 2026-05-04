Questão 1: A diferença fundamental entre Docker Compose e Docker Swarm está no escopo e na forma de gerenciamento dos containers.
O Docker Compose é uma ferramenta utilizada para definir e executar múltiplos containers em um único host, por meio de um arquivo de configuração (docker-compose.yml). Seu foco está na facilidade de uso e no ambiente local, sendo amplamente empregado em desenvolvimento e testes. Nesse modelo, todos os containers são executados na mesma máquina, o que limita a escalabilidade e não oferece mecanismos nativos de alta disponibilidade.
Por outro lado, o Docker Swarm é um orquestrador de containers que permite gerenciar aplicações distribuídas em um cluster de máquinas (múltiplos nós). Ele introduz conceitos como nós gerenciadores (managers) e trabalhadores (workers), possibilitando escalabilidade horizontal, balanceamento de carga automático e tolerância a falhas. Assim, caso um nó falhe, os serviços podem ser redistribuídos automaticamente para outros nós disponíveis.
Portanto, enquanto o Docker Compose é indicado para ambientes simples e centralizados, o Docker Swarm é voltado para ambientes distribuídos e de produção, onde há necessidade de maior disponibilidade, escalabilidade e resiliência.

Questão 2: Dentro de um cluster do Docker Swarm, os nós assumem dois papéis principais com responsabilidades distintas:
O Manager é responsável pelo controle e gerenciamento do cluster. Ele toma decisões sobre o estado desejado do sistema, como onde os containers (serviços) devem ser executados, realiza o agendamento das tarefas (scheduling), mantém o estado do cluster e garante a consistência entre os nós. Além disso, é o único que aceita comandos administrativos, como criação de serviços e escalabilidade.
Já o Worker é responsável pela execução das tarefas atribuídas pelo Manager. Ele recebe as instruções e executa os containers conforme definido, sem participar das decisões de gerenciamento do cluster. Sua função é operacional, focada em rodar as aplicações.
Em resumo, o Manager coordena e decide, enquanto o Worker executa as tarefas dentro do cluster.

3b: O driver de rede utilizado por padrão para comunicação entre serviços em diferentes nós é o: Overlay Network
Esse driver permite a comunicação entre containers distribuídos em múltiplos hosts dentro do cluster, criando uma rede virtual compartilhada entre os nós.

5b: A capacidade do Swarm de redistribuir automaticamente as instâncias em caso de falha de um nó é chamada de:
Alta Disponibilidade (High Availability)
(associada ao conceito de auto-healing)