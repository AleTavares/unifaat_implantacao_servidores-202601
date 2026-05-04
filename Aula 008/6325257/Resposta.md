## Questão 1: Conceito de Cluster (Teórica)
**Resposta: O Docker Compose orquestra apenas uma máquina localmente, enquanto o Docker Swarm  funciona em cluster, orquestra várias máquinas que podem ser virtuais.**

## Questão 2: Funções dos Nós (Teórica)
**Resposta: O manager orquestra os workers e gerencia o estado do cluster, enquanto o worker executa os conteineres enviados pelo manager.**

## Questão 3: Inicialização do Swarm (Prática)

a) **Prática: docker swarm init**
![alt text](<docker swarm init.png>)

b)**Overlay**

## Questão 4: Criação de Service (Prática)
O **Service** é o objeto central do Swarm, substituindo o conceito de `docker run` no mundo Compose.

a) **Prática:  docker service create** \
**--name web-app**\
**--replicas 3**\
**--publish 80:80**\
**nginx:latest**
![alt text](<docker service create.png>)

b)**Docker service logs web-app**
![alt text](<Docker service logs web-app.png>)

## Questão 5: Atualização e Escalabilidade (Prática)
Você percebe que a aplicação precisa de mais poder de processamento para lidar com picos de tráfego.

a) **Prática: docker service scale web-app=5**
![alt text](<docker service scale web-app=5.png>)

b) **Teórica: Alta disponibilidade.**

## Tarefa Prática Integrada (Obrigatória)
Simule um *Cluster* de nó único, lance um *Service* e prove sua escalabilidade.


### Passo 1: Inicialização do Cluster
1.  **Limpeza:** Certifique-se de que não há nenhum *Cluster* Swarm ativo no seu Host. Se houver, use o comando de limpeza.

**docker service rm web-app.png**


2.  **Inicialização:** Inicialize um novo *Cluster* Swarm, tornando seu Host o nó **Manager**.

**docker swarm init**


### Passo 2: Deploy de um Serviço
1.  Crie um *Service* chamado **`app-stack-tf9`**, usando a imagem `nginx:alpine`.
2.  Publique a porta **8001** do *Cluster* (Target Port) para a porta 80 do contêiner.
3.  **Escalone** o *Service* para ter 4 réplicas (`--replicas 4`).
    *(Liste o comando `docker service create` completo).*

**docker service create** \
**--name app-stack-tf9** \
**--replicas 4** \
**--publish 8001:80** \
**nginx:alpine**

### Passo 3: Validação e Evidências
1.  **Verificação do Status:** Use o comando para visualizar as 4 réplicas do *Service* rodando.
    *(Anexe a saída ou um screenshot desta lista como **Evidência 1**).*

**docker service ps app-stack-tf9**
![alt text](<Evidencia 1.png>)

2.  **Acesso Externo:** Use o `curl` (ou o navegador) para acessar a aplicação pela porta mapeada do Host.
    ```bash
    curl localhost:8001
    ```
    *(Anexe a saída do `curl` como **Evidência 2**).*
    ![alt text](<Evidencia 2.png>)

### Passo 4: Escalabilidade
1.  Execute o comando para **diminuir** o número de réplicas do `app-stack-tf9` de 4 para **1**.
    *(Liste o comando de escalabilidade).*

**docker service scale app-stack-tf9=1**


### Passo 5: Limpeza Final
1.  Remova o *Service* `app-stack-tf9`.

**docker service rm app-stack-tf9**


2.  Desfaça a inicialização do Swarm (saia do *Cluster*).

**docker swarm leave --force**

    *(Liste os comandos de remoção do Service e o comando de saída do Swarm).*

---
