## Questão 1: Diferença Docker Compose vs Docker Swarm
A diferença fundamental é escopo e capacidade de gerenciamento:

Docker Compose
-Funciona em um único host (máquina)
-Gerencia múltiplos containers, mas localmente
-Não tem alta disponibilidade nativa nem distribuição de carga entre máquinas
## --------------
Docker Swarm
-Funciona em um cluster (várias máquinas/hosts)
-Orquestra containers distribuídos entre vários nós
-Possui:
-Alta disponibilidade
-Balanceamento de carga
-Escalabilidade horizontal
## -----------------
## Questão 2: Funções dos Nós no Swarm
No Docker Swarm existem dois tipos de nós:

Manager (Gerente)
Responsável pelo controle do cluster:
-Gerencia o estado do cluster
-Agenda onde os containers serão executados
-Monitora os nós
-Mantém a consistência (orquestração)
-É o “cérebro” do cluster
------------
Worker (Trabalhador)
Responsável pela execução:
-Executa os containers (tasks)
-Recebe instruções dos Managers
-Não toma decisões, apenas executa
-É a “mão de obra” do cluster
-------------
## Questão 3: Inicialização do Swarm (Prática)
   a)  O comando para iniciar um novo cluster no host é: docker swarm init
   b)  O driver utilizado por padrão é: overlay

## Questão 4: Criação de Serviço (Prática)
   a)  docker service create --name web-escalavel --replicas 3 nginx:alpine
   b)  docker service ps web-escalavel

## Questão 5: Atualização e Escalabilidade (Prática)
   a)docker service scale web-escalavel=5
   b)Auto-healing (ou Self-healing)

## Tarefa Prática

(![Evidencia 1](<Captura de tela 2026-04-27 212330.png>))

(![Evidenci 2 ](<Captura de tela 2026-04-27 212605.png>))