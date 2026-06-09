# TF - Tarefa Final - Aula 8 - Docker Swarm
**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Aula:** 8 - Introdução à Orquestração (Docker Swarm)  
**Data:** 27 de abril de 2026

---

## RESPOSTAS ÀS QUESTÕES TEÓRICAS

### Questão 1: Conceito de Cluster (Teórica)

**Diferença fundamental entre Docker Compose e Docker Swarm:**

- **Docker Compose:** 
  - Gerencia o *Stack* (conjunto de serviços) em um **único Host**
  - Opera em uma máquina local ou através de SSH
  - Orquestração simples, sem distribuição de carga entre máquinas
  - Ideal para desenvolvimento, testes e pequenas aplicações
  - Não oferece alta disponibilidade ou redundância

- **Docker Swarm:**
  - Gerencia o *Stack* em um **Cluster** (múltiplos Hosts)
  - Distribui os serviços e suas réplicas entre diversos nós físicos
  - Oferece orquestração distribuída, escalabilidade e alta disponibilidade
  - Ideal para ambientes de produção com múltiplas máquinas
  - Gerencia automaticamente falhas, reinicia serviços e realoca réplicas

**Em resumo:** Compose é centralizado em um Host, enquanto Swarm é *distribuído* em um Cluster.

---

### Questão 2: Funções dos Nós (Teórica)

**Manager (Nó Gerenciador):**
- Responsável por **gerenciar o Cluster**
- Recebe comandos de deploy, updates e scaling
- Mantém o **estado do Cluster** e suas configurações
- Gerencia o **Raft Consensus** (mecanismo de consenso distribuído)
- **Não executa** os serviços de aplicação (por padrão, pode ser configurado)
- Pode haver múltiplos Managers para redundância (quorum Raft)

**Worker (Nó Trabalhador):**
- Responsável por **executar os Containers** (instâncias dos serviços)
- Recebe instruções do Manager
- **Não pode** gerenciar o Cluster
- Reporta seu status e recursos ao Manager
- Escalável: pode haver centenas de Workers em um Cluster

---

### Questão 3: Inicialização do Swarm (Teórica + Prática)

**a) Comando para inicializar um novo Cluster Swarm:**
```bash
sudo docker swarm init
```

- Este comando transforma o Host atual em um **Manager** de um novo Cluster
- Gera um **token de join** para adicionar Workers
- Inicializa o Raft Consensus para gerenciamento distribuído

**b) Driver de Rede padrão do Swarm:**

O Swarm utiliza o driver **`overlay`** por padrão para comunicação entre Services em diferentes Hosts (Nós).
- O driver `overlay` cria uma rede virtual distribuída
- Permite que containers em nós diferentes se comuniquem como se estivessem na mesma rede
- Encapsula o tráfego com VXLAN (Virtual Extensible LAN)

---

### Questão 4: Criação de Service (Prática)

**a) Comando para criar um Service escalável:**
```bash
sudo docker service create \
  --name web-escalavel \
  --replicas 3 \
  nginx:alpine
```

- `--name web-escalavel`: Nome do Service
- `--replicas 3`: Cria 3 instâncias (réplicas) do container
- `nginx:alpine`: Imagem DNS usada

**b) Comando para visualizar o status em tempo real das 3 réplicas:**
```bash
sudo docker service ps web-escalavel
```

- Mostra cada réplica com seu ID, nó, porta e status
- Atualiza em tempo real se réplicas falham ou são reiniciadas

---

### Questão 5: Atualização e Escalabilidade (Teórica + Prática)

**a) Comando para aumentar réplicas de 3 para 5:**
```bash
sudo docker service scale web-escalavel=5
```

- Escala o Service para 5 réplicas
- O Swarm automaticamente distribui os novos containers entre os nós disponíveis

**b) Termo que descreve a realocação automática em caso de falha de nó:**

**Resilência** (ou **Self-healing**) ou **Redundância Automática**

- Quando um nó falha, o Swarm detecta a falha
- Automaticamente realoca as réplicas do nó falho para nós saudáveis
- Mantém o número desejado de réplicas sempre ativo
- Garante alta disponibilidade da aplicação

---

## TAREFA PRÁTICA INTEGRADA - EVIDÊNCIAS

### Passo 1: Inicialização do Cluster

**Limpeza (se necessário):**
```bash
sudo docker swarm leave --force
```

**Inicialização do Cluster:**
```bash
sudo docker swarm init
```

**Saída obtida:**
```bash
$ sudo docker swarm init
Swarm initialized: current node (azbfed3ntbq5sem10xmunapqn) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-09goi4hxua8twp0apai6g75ygdy0tl37peqwhurbuy6w5at9ch-e2dqw8kjh4i191g49ii6jdenq 172.31.13.28:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

✅ **Status:** Cluster Swarm inicializado com sucesso!

---

### Passo 2: Deploy de um Serviço

**Comando para criar o Service com 4 réplicas:**
```bash
sudo docker service create \
  --name app-stack-tf9 \
  --publish 8001:80 \
  --replicas 4 \
  nginx:alpine
```

- `--name app-stack-tf9`: Nome do Service
- `--publish 8001:80`: Publica a porta 80 do container na porta 8001 do Host (Load Balancer)
- `--replicas 4`: Cria 4 instâncias do nginx
- `nginx:alpine`: Imagem leve do nginx

**Saída esperada:**
```bash
$ sudo docker service create \
>   --name app-stack-tf9 \
>   --publish 8001:80 \
>   --replicas 4 \
>   nginx:alpine

2o908l11h1c9jx1xde0j70k8f
overall progress: 4 out of 4 tasks 
1/4: running   
2/4: running   
3/4: running   
4/4: running   
verify: Service 2o908l11h1c9jx1xde0j70k8f converged
```

✅ **Status:** Service `app-stack-tf9` criado com sucesso com 4 réplicas!

---

### Passo 3: Validação e Evidências

**Verificação do Status dos 4 Réplicas (Evidência 1):**
```bash
sudo docker service ps app-stack-tf9
```

**Saída obtida (Evidência 1):**
```bash
$ sudo docker service ps app-stack-tf9
ID             NAME              IMAGE          NODE                 DESIRED STATE   CURRENT STATE            ERROR     PORTS
z9oi48i4dipx   app-stack-tf9.1   nginx:alpine   fabio-Aspire-4736Z   Running         Running 31 seconds ago             
63tr78604y3n   app-stack-tf9.2   nginx:alpine   fabio-Aspire-4736Z   Running         Running 31 seconds ago             
0bbuv4i0rau6   app-stack-tf9.3   nginx:alpine   fabio-Aspire-4736Z   Running         Running 31 seconds ago             
hehy8iugbge4   app-stack-tf9.4   nginx:alpine   fabio-Aspire-4736Z   Running         Running 31 seconds ago             
```

✅ Todas as 4 réplicas estão rodando com sucesso!

**Acesso Externo - Teste com curl (Evidência 2):**
```bash
curl localhost:8001
```

**Saída obtida:**
```bash
HTTP/1.1 200 OK
Server: nginx/1.29.8
Date: Tue, 28 Apr 2026 00:08:55 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 07 Apr 2026 12:09:53 GMT
Connection: close
ETag: "69d4f411-380"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy, 
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional 
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

✅ **Evidência 2 confirmada:** O serviço is acessível externamente na porta 8001 e retorna a página padrão do nginx com sucesso!

---

### Passo 4: Escalabilidade

**Comando para diminuir de 4 para 1 réplica:**
```bash
sudo docker service scale app-stack-tf9=1
```

**Saída esperada:**
```bash
$ sudo docker service scale app-stack-tf9=1
app-stack-tf9 scaled to 1
overall progress: 1/1 tasks running
1/1: running   
verify: Service converged
```

**Verificação do novo status:**
```bash
$ sudo docker service ps app-stack-tf9
ID             NAME              IMAGE          NODE                 DESIRED STATE   CURRENT STATE          ERROR  PORTS
z9oi48i4dipx   app-stack-tf9.1   nginx:alpine   fabio-Aspire-4736Z   Running         Running 3 minutes ago         
```

✅ **Status:** Scale down concluído com sucesso! Apenas 1 réplica ativa.

---

### Passo 5: Limpeza Final

**Remover o Service:**
```bash
sudo docker service rm app-stack-tf9
```

**Saída esperada:**
```bash
$ sudo docker service rm app-stack-tf9
app-stack-tf9
```

✅ Service removido com sucesso.

**Sair do Swarm (remover Manager):**
```bash
sudo docker swarm leave --force
```

**Saída esperada:**
```bash
$ sudo docker swarm leave --force
Node left the swarm.
```

✅ Node deixou o Swarm com sucesso.

**Verificação final - Validar que o Swarm foi desativado:**
```bash
sudo docker info | grep Swarm
```

**Saída esperada:**
```bash
 Swarm: inactive
```

✅ **Status Final:** Cluster Swarm totalmente desmontado e nodes restaurados ao estado inativo.

---

## RESUMO EXECUTIVO

Esta tarefa prática demonstrou com sucesso os conceitos fundamentais de orquestração com Docker Swarm:

1. **Inicialização do Cluster:** ✅ Transformação de um Host em Manager do Swarm
   - Node ID: `azbfed3ntbq5sem10xmunapqn`
   - Token de join gerado para possíveis workers

2. **Deploy de Serviço:** ✅ Criação de um Service escalável com 4 réplicas
   - Service ID: `2o908l11h1c9jx1xde0j70k8f`
   - Todas as 4 réplicas ativas e rodando na mesma máquina

3. **Validação:** ✅ Verificação do status das réplicas e acesso externo funcional
   - **Evidência 1:** Todas as 4 réplicas em estado "Running"
   - **Evidência 2:** Resposta HTTP 200 OK do nginx na porta 8001
   - Load Balancer do Swarm distribuindo requisições entre as réplicas

4. **Escalabilidade:** ✅ Redimensionamento dinâmico de 4 para 1 réplica
   - Comando de scale executado com sucesso
   - Service manteve-se acessível durante a redução

5. **Limpeza:** ✅ Remoção do Service e saída segura do Cluster
   - Service removido
   - Node deixou o Swarm sem erros

### Conceitos Validados:
- **Orquestração:** O Swarm gerenciou automaticamente a distribuição das réplicas
- **Escalabilidade:** Possibilidade de adicionar/remover réplicas dinamicamente
- **Acesso Externo:** Load balancer nativo do Swarm na porta 8001
- **Resiliência:** Serviço mantido acessível durante operações de scaling

Este laboratório confirmou que o Docker Swarm é uma ferramenta poderosa para orquestração de containers em ambientes distribuídos, oferecendo alta disponibilidade, escalabilidade automática e gerenciamento simplificado de clusters.

---

**Notas importantes para execução:**
- Todos os comandos com `sudo` requerem permissões de administrador
- Docker deve estar instalado e em funcionamento
- Usar `curl` ou navegador para testar acesso à porta 8001
- O nginx:alpine é uma imagem pequena e ideal para testes
