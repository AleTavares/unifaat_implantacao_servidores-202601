Respostas

1 - A diferença fundamental está no escopo e na forma de orquestração dos containers:

O Docker Compose gerencia um stack em um único host. Ele é ideal para desenvolvimento e testes, permitindo subir vários containers que se comunicam entre si, mas todos rodam na mesma máquina, sem recursos nativos de distribuição, alta disponibilidade ou tolerância a falhas.

Já o Docker Swarm gerencia um stack em um cluster de múltiplos nós. Isso significa que os containers podem ser distribuídos entre várias máquinas.

2 - Manager decide e coordena, Worker executa e reporta

3 - B - Overlay
No Docker Swarm, o driver de rede overlay é utilizado por padrão para permitir a comunicação entre services que estão distribuídos em diferentes nós do cluster.
Esse tipo de rede cria uma rede virtual distribuída, conectando containers em hosts distintos como se estivessem na mesma rede local, o que é essencial para o funcionamento de aplicações em cluster.

5 - B - Auto-healing (ou self-healing)
No Docker Swarm, essa capacidade significa que o sistema monitora continuamente o estado dos serviços e, ao detectar falhas (como a queda de um nó ou de containers), ele automaticamente recria e redistribui as réplicas em nós saudáveis para manter o estado desejado do cluster.