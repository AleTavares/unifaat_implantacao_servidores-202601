# TF013 - Deploy de Containers na AWS com EKS

RA: 6325149  
Aluno: Gabriel  
Disciplina: Implementacao de servidor e nuvem (cloud)  
Aula: 13 - Deploy de Containers na AWS com EKS  
Data: 15/06/2026

---

## Questao 1: Conceitos de Kubernetes e EKS (Teorica)

### a) Control Plane vs Worker Nodes - Diferenca e Gerenciamento

**Control Plane (Plano de Controle):**
- Componente central que gerencia todo o cluster Kubernetes
- Responsavel por decisoes de orquestracao, scheduling e estado do cluster
- Componentes: API Server, etcd (banco de dados), Scheduler, Controller Manager
- **Quem gerencia:** AWS EKS gerencia o Control Plane automaticamente (servico gerenciado)
- Developer nao tem acesso direto; AWS mantem alta disponibilidade, backups e atualizacoes

**Worker Nodes:**
- Sao instancias EC2 que executam os pods (containers)
- Recebem instrucoes do Control Plane e executam as aplicacoes
- Componentes: kubelet (agente), container runtime (Docker/containerd), kube-proxy
- **Quem gerencia:** Developer configura e gerencia os worker nodes via Node Groups
- AWS provisiona as instancias, mas o developer define quantidade, tipo e configuracoes

**Analogia:** Control Plane = maestro de orquestra (decide o que tocar e quando); Worker Nodes = musicos (executam a musica).

---

### b) Self-Healing no Kubernetes

**Conceito:** Capacidade do Kubernetes de detectar e recuperar automaticamente de falhas.

**O que acontece quando um pod falha:**

1. **Deteccao:** O kubelet (agente no node) detecta que o pod nao esta respondendo (health check falha)
2. **Notificacao:** Kubelet informa o Control Plane sobre a falha
3. **Decisao:** Controller Manager (ReplicaSet Controller) verifica se o numero de replicas desejadas esta sendo mantido
4. **Acao:** Se havia 3 replicas e 1 falhou, Kubernetes imediatamente cria um novo pod para substituir
5. **Resultado:** Aplicacao continua rodando com 3 replicas sem intervencao manual

**Exemplo pratico:**
```
Pod1 (Running) → Pod1 crashes → Pod1 (Failed)
  ↓                              ↓
Pod2 (Running)         Kubernetes detecta
  ↓                              ↓
Pod3 (Running)      Cria novo Pod4 (Running)
  ↓                              ↓
Resultado: 3 pods sempre rodando
```

---

## Questao 2: Objetos Kubernetes (Teorica)

### a) Diferenca entre Deployment e Service

| Aspecto | Deployment | Service |
|---------|-----------|---------|
| **Proposito** | Gerenciar replicas de pods | Expor pods para acesso externo/interno |
| **O que faz** | Garante numero correto de pods rodando | Fornece ponto de acesso estavel aos pods |
| **Scopo** | Aplicacao (qual imagem rodar, replicas) | Networking (como acessar a aplicacao) |
| **Exemplo YAML** | Deployment + Pods | Service + LoadBalancer/ClusterIP |
| **Ciclo de vida** | Cria/atualiza/deleta pods | Fornece DNS e roteamento stavel |

**Na pratica:**
- Deployment: "Quero 3 pods da imagem nginx:latest sempre rodando"
- Service: "Esses 3 pods devem ser acessiveis em http://minha-app.default.svc.cluster.local"

---

### b) Labels e Selectors - Conexao Service com Pods

**Labels:** Pares chave-valor anexados a objetos Kubernetes para identificacao e organizacao.

```yaml
# No Deployment/Pod
labels:
  app: web-app
  version: v1
```

**Selectors:** Mecanismo de query que usa labels para selecionar um conjunto de pods.

```yaml
# No Service
selector:
  app: web-app  # Seleciona todos os pods com label app=web-app
```

**Fluxo de Conexao:**
1. Deployment cria pods com labels `app: web-app`
2. Service define selector `app: web-app`
3. Service automaticamente descobre e roteia trafego para todos os pods com esse label
4. Se novo pod e criado com esse label, Service adiciona automaticamente

**Beneficio:** Desacoplamento — Service nao precisa saber de pods especificos, apenas do label padrao.

---

### c) Probes (livenessProbe e readinessProbe) - Funcao e Exemplos

**livenessProbe:**
- **Funcao:** Detecta se um pod "morreu" ou travou (mesmo que o container nao tenha crashed)
- **Acao:** Se falhar repetidamente, Kubernetes mata o pod e cria um novo (restart)
- **Quando usar:** Aplicacoes que podem travar ou entrar em deadlock

Exemplo pratico - Aplicacao Node.js que trava apos 5 minutos:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30    # Espera 30s antes de verificar
  periodSeconds: 10          # Verifica a cada 10s
  failureThreshold: 3        # Reinicia apos 3 falhas consecutivas
```

**readinessProbe:**
- **Funcao:** Detecta se um pod esta pronto para receber trafego
- **Acao:** Se falhar, Service remove o pod do pool de balanceamento (mas nao o mata)
- **Quando usar:** Startup lento, dependencias externas (BD, cache) que precisam estar prontas

Exemplo pratico - API que aguarda conexao com PostgreSQL:
```yaml
readinessProbe:
  httpGet:
    path: /api/health/ready
    port: 8080
  initialDelaySeconds: 15    # Mais tempo para conectar BD
  periodSeconds: 5           # Verifica rapidamente
  failureThreshold: 2
```

**Diferenca resumida:**
- **liveness:** "Pod esta vivo?" → Se nao, restart
- **readiness:** "Pod esta pronto?" → Se nao, remove do trafego

---

## Questao 3: IAM e Permissoes (Teorica)

### a) Por que EKSClusterRole - Acoes Permitidas

**EKSClusterRole:** Role IAM que o Control Plane EKS assume para gerenciar recursos AWS em nome do usuario.

**Por que eh necessaria:**
- Control Plane precisa de permissoes para criar/atualizar recursos (ENIs, security groups, load balancers)
- Sem role, Control Plane nao consegue criar Service LoadBalancer, por exemplo
- Centraliza permissoes de forma auditavel

**Acoes tipicas permitidas:**
- Criar/gerenciar ENIs (Elastic Network Interfaces) para pods
- Criar/gerenciar security groups para comunicacao interna
- Provisionar load balancers quando Service LoadBalancer e criado
- Escrever logs em CloudWatch
- Gerenciar VPC e subnets para pods

**Politica recomendada (AWS):**
`AmazonEKSClusterPolicy` inclui permissoes minimas para:
- elasticloadbalancing:*
- ec2:DescribeSecurityGroups, ec2:DescribeNetworkInterfaces
- logs:CreateLogGroup, logs:CreateLogStream

---

### b) ECRReadOnly - Razao e Consequencias

**Por que Worker Nodes precisam de AmazonEC2ContainerRegistryReadOnly:**

Worker Nodes (EC2 instances) precisam fazer pull de imagens do ECR quando Kubernetes agenda novos pods.

**O que acontece SEM essa politica:**
1. Pod e criado em um worker node
2. Kubelet tenta fazer pull da imagem do ECR
3. Falha de autenticacao: "Unauthorized: authentication required"
4. Pod fica em estado `ImagePullBackOff` (erro critico)
5. Aplicacao nao inicia, Service nunca fica Ready

**Exemplo de erro:**
```
Failed to pull image "123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app:v1.0":
rpc error: code = Unknown desc = Error response from daemon:
unauthorized: authentication required
```

**Consequencias:**
- Deployments ficam com 0/N replicas rodando
- Pods nunca saem do estado Pending
- Servico fica indisponivel
- Nenhum healing automatico consegue resolver (problema de permissao)

---

## Questao 4: Networking e Exposicao (Teorica)

### a) Tipos de Service - ClusterIP vs NodePort vs LoadBalancer

| Tipo | Escopo | Acesso | Caso de Uso |
|------|--------|--------|-----------|
| **ClusterIP** | Interno apenas | DNS cluster (ex: web.default.svc) | Comunicacao interna entre pods/services |
| **NodePort** | Node + Externo | IP:PORT do node (ex: 10.0.1.100:30080) | Testes, acesso a partir de um ponto fixo |
| **LoadBalancer** | Externo gerenciado | URL DNS unica da AWS (ex: abc123.elb.amazonaws.com) | Producao, distribuir trafego, alta disponibilidade |

**Na pratica:**
- **ClusterIP:** Backend fala com BD interna via ClusterIP
- **NodePort:** Developer testa manualmente da sua maquina via IP:PORT do node
- **LoadBalancer:** Usuarios publicos acessam via DNS do Load Balancer (melhor pratica)

---

### b) O que AWS Provisiona com Service LoadBalancer

Quando voce cria um Service do tipo `LoadBalancer` em EKS:

1. **AWS ELB (Elastic Load Balancer) e criado automaticamente**
   - Tipo: Network Load Balancer (NLB) ou Classic Load Balancer (CLB), dependendo da versao
   - Ubicacao: Fora do cluster, na VPC
   - Provisioning: Leva 1-2 minutos

2. **DNS e atribuido ao Load Balancer**
   - Formato: `abc123-456789.us-east-1.elb.amazonaws.com`
   - Service atualiza automaticamente o field `status.loadBalancer.ingress[0].hostname`

3. **Security Groups sao configurados**
   - Ingress (entrada) do LB para o trafego (porta 80, 443, etc)
   - Egress (saida) do LB para os nodes

4. **Target Groups sao criados**
   - Pods sao registrados automaticamente como targets
   - Health checks validam se pods estao respondendo

**Custo:** Load Balancer incorre em cobrancos mensais enquanto existir (mesmo que sem trafego).

---

### c) Por que Deletar LoadBalancer ANTES do Cluster EKS

**Consequencias de nao deletar na ordem correta:**

1. **Se deletar cluster antes do Service LoadBalancer:**
   - Load Balancer fica orphaned (órfão) na AWS
   - Continua incorrendo em cobrangas mesmo sem cluster
   - Pode ser dificil encontrar/remover depois

2. **Ordem correta:**
   ```
   Delete Service LoadBalancer (libera ELB na AWS)
     ↓
   Aguardar ELB ser removido (~30s-2min)
     ↓
   Delete Cluster EKS (remocao limpa)
   ```

3. **Se deletar ao contrario:**
   - Service fica tentando atualizar Load Balancer inexistente
   - Recursos orphaned acumulam na conta
   - Cobrangas inesperadas

---

## Questao 5: Tarefa Pratica - Comandos EKS (Simulacao)

Valores exigidos:
- Cluster: `producao-cluster`
- Namespace: `minha-app`
- Imagem ECR: `111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0`
- Replicas: 3

### a) Criar o namespace

```bash
kubectl create namespace minha-app
```

Ou declarativo (YAML):
```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: minha-app
EOF
```

### b) Criar Deployment com 3 replicas

**Comando imperativo (rapido):**
```bash
kubectl create deployment web-app \
  --image=111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0 \
  --replicas=3 \
  -n minha-app
```

**Declarativo YAML (recomendado para producao):**
```bash
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: minha-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: 111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0
        ports:
        - containerPort: 8080
EOF
```

### c) Expor com Service LoadBalancer

```bash
kubectl expose deployment web-app \
  --type=LoadBalancer \
  --port=80 \
  --target-port=8080 \
  -n minha-app
```

Ou YAML:
```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: minha-app
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
EOF
```

### d) Escalar de 3 para 5 replicas

```bash
kubectl scale deployment web-app --replicas=5 -n minha-app
```

Ou editar deployment:
```bash
kubectl edit deployment web-app -n minha-app
# Alterar replicas: 3 para replicas: 5
# Salvar (vi: :wq)
```

### e) Verificar pods e obter endpoint

```bash
# Verificar pods rodando
kubectl get pods -n minha-app

# Obter status do deployment
kubectl get deployments -n minha-app

# Obter Service e EXTERNAL-IP (LoadBalancer)
kubectl get svc -n minha-app

# Aguardar EXTERNAL-IP estar pronto (pode levar 1-2 min)
kubectl get svc web-app-service -n minha-app -w

# Testar acesso
ENDPOINT=$(kubectl get svc web-app-service -n minha-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ENDPOINT
```

---

## Questao 6: Evidencias Praticas da Execucao do Lab013

Diretorio das evidencias:

`Aula 013/6325149/evidencias`

Evidencias exigidas pelo TF013:

Parte 1 - Construcao e Teste Local

1. Build da imagem Docker
- Arquivo: `print01-docker-build.txt`

2. Teste local
- Arquivo: `print02-curl-localhost.txt`

3. Listagem da imagem
- Arquivo: `print03-docker-images.txt`

Parte 2 - Publicacao no ECR

1. Login no ECR
- Arquivo: `print04-ecr-login.txt`

2. Push da imagem
- Arquivo: `print05-docker-push.txt`

3. Verificacao remota
- Arquivo: `print06-ecr-verify.txt`

Parte 3 - Cluster EKS e Deploy

1. Cluster ativo
- Arquivo: `print07-cluster-active.txt`

2. Nodes prontos
- Arquivo: `print08-kubectl-nodes.txt`

3. Deploy aplicado
- Arquivo: `print09-kubectl-deployment.txt`

4. Pods rodando
- Arquivo: `print10-kubectl-pods.txt`

5. Service com endpoint
- Arquivo: `print11-kubectl-svc.txt`

Parte 4 - Acesso e Testes

1. Acesso via curl
- Arquivo: `print12-curl-endpoint.txt`

2. Teste de resiliencia
- Arquivo: `print14-resilience-test.txt`

Parte 5 - Limpeza

1. Verificacao final
- Arquivo: `print15-cleanup-verify.txt`

Observacao:
- Todas as evidencias obrigatorias descritas no TF013 foram coletadas
- Recursos AWS foram completamente removidos apos conclusao dos testes
- Repositorio ECR mantido (reutilizavel para futuros deploys)

---

## Resumo de Aprendizados

✅ **Kubernetes Control Plane** = orquestrador gerenciado pela AWS  
✅ **Worker Nodes** = instancias EC2 que executam pods  
✅ **Deployment** = garantir N replicas rodando  
✅ **Service** = expor pods para acesso externo  
✅ **Labels/Selectors** = conectar Service aos pods corretos  
✅ **Probes** = health checks para detectar e recuperar de falhas  
✅ **IAM Roles** = permissoes para cluster e nodes acessarem recursos AWS  
✅ **LoadBalancer** = distribuir trafego entre pods  
✅ **Self-Healing** = Kubernetes recria pods que falham automaticamente  

---

**Data de Conclusao:** 15/06/2026  
**Status:** ✅ Questoes Teoricas (Q1-Q5) Completas | ✅ Evidencias (Q6) Coletadas e Armazenadas
