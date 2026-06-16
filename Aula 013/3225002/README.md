# TF Aula 013 — Deploy de Containers na AWS com EKS

**RA:** 3225002
**Aluno:** José Henrique Teixeira Luiz
**Disciplina:** Implementação de servidor e nuvem (cloud)
**Aula:** 13 — Deploy de Containers na AWS com EKS

---

## Questão 1: Conceitos de Kubernetes e EKS

### a) Diferença entre Control Plane e Worker Nodes em um cluster EKS

O **Control Plane** é o "cérebro" do cluster Kubernetes — formado por componentes como API Server (recebe comandos do `kubectl`), etcd (banco de dados de estado), Scheduler (decide em qual node cada pod vai rodar) e Controller Manager (reconcilia estado desejado vs estado real). No EKS, **quem gerencia o Control Plane é a AWS**: ela cuida de patches, alta disponibilidade, backup e escalabilidade dele — o aluno não tem acesso direto às máquinas do Control Plane.

Os **Worker Nodes** são as máquinas EC2 (no nosso lab, instâncias `t3.medium`) que executam de fato os pods (containers). Cada node roda o `kubelet` (agente que se comunica com o Control Plane) e o `kube-proxy` (responsável pela rede). **Quem gerencia os Worker Nodes é o aluno/cliente** — através do Node Group, definindo tipo da instância, quantidade mínima/máxima, atualizações, etc.

### b) Self-healing no Kubernetes

**Self-healing** é a capacidade do Kubernetes de **se recuperar automaticamente de falhas**, mantendo o cluster sempre no estado desejado declarado nos manifestos YAML. O K8s compara continuamente o **estado atual** com o **estado desejado** e, se houver divergência, age pra reconciliar.

**O que acontece quando um pod falha:**
1. O **kubelet** detecta que o container parou (via probes ou erro de processo)
2. O **Deployment Controller** percebe que o número de réplicas atuais é menor que o desejado (ex: tinha 2, agora tem 1)
3. O **Scheduler** agenda um novo pod num node disponível
4. Um novo container é iniciado, restaurando o número de réplicas

Isso vale também pra falha de node inteiro: o K8s reagenda os pods que estavam nele em outros nodes saudáveis.

---

## Questão 2: Objetos Kubernetes

### a) Diferença entre Deployment e Service

| | **Deployment** | **Service** |
|--|--|--|
| **O que é** | Controlador que gerencia o ciclo de vida dos pods | Abstração de rede que expõe pods |
| **Responsabilidade** | Garantir que N réplicas estejam sempre rodando | Dar um endpoint estável (IP/DNS) pros pods |
| **Escala** | Define quantos pods existem (`replicas: 3`) | Distribui tráfego entre os pods existentes |
| **Identidade** | Pods têm IPs efêmeros (mudam a cada recriação) | Service tem IP fixo, independente dos pods |
| **Atualizações** | Faz rolling updates e rollbacks | Não atualiza pods, só roteia |

**Resumo:** Deployment cuida de **quem está rodando**; Service cuida de **como acessar quem está rodando**.

### b) Labels e Selectors

**Labels** são pares chave/valor que você "cola" em qualquer objeto Kubernetes (pod, service, deployment) pra identificá-los. Exemplo: `app: ads-site`, `tier: frontend`, `env: prod`.

**Selectors** são filtros que selecionam objetos com base nessas labels. Quando o Service tem o selector `app: ads-site`, ele encontra automaticamente **todos os pods** que têm a label `app: ads-site` e roteia tráfego pra eles.

**Como conectam Service aos Pods corretos:**

```yaml
# Pod (criado pelo Deployment)
metadata:
  labels:
    app: ads-site    # ← label do pod

# Service
spec:
  selector:
    app: ads-site    # ← selector procura por essa label
```

O Service não tem ligação "dura" com os pods — só procura quem tem o label. Por isso, quando o Deployment cria/deleta pods, o Service automaticamente reflete a mudança.

### c) Probes — livenessProbe e readinessProbe

**`livenessProbe`** — verifica se o pod **está vivo**. Se falhar (várias vezes seguidas), o Kubernetes **mata e recria** o container.

**`readinessProbe`** — verifica se o pod **está pronto pra receber tráfego**. Se falhar, o pod é **removido do Service** (não recebe requisições), mas **não é morto**. Quando voltar a passar, é re-adicionado ao Service.

**Quando cada uma é útil:**

- **liveness:** aplicação travou (deadlock, memória estourada, loop infinito) — `livenessProbe` detecta e força reinício. Exemplo: app Node.js que travou processando uma requisição.

- **readiness:** aplicação ainda está inicializando (carregando cache, conectando no banco, baixando arquivos) — `readinessProbe` espera ela ficar pronta antes de mandar usuário pra ela. Exemplo: Spring Boot que demora 30s pra subir totalmente — sem readiness, o usuário receberia erro 502 nos primeiros segundos.

---

## Questão 3: IAM e Permissões

### a) Por que o cluster EKS precisa de IAM Role própria (EKSClusterRole)?

Porque o **serviço EKS** (Control Plane) precisa **agir em nome do usuário** dentro da conta AWS pra criar e gerenciar recursos que o cluster precisa: ENIs (Elastic Network Interfaces) pra rede dos pods, Load Balancers quando você cria um Service do tipo LoadBalancer, integração com CloudWatch pra logs, etc.

Sem essa role, o EKS não conseguiria provisionar nada e o cluster sequer iniciaria.

**Tipos de ações que a `EKSClusterRole` permite** (via `AmazonEKSClusterPolicy`):
- Criar/deletar/descrever **Load Balancers (ELB)** quando um Service tipo LoadBalancer é criado
- Gerenciar **Network Interfaces (ENIs)** pra comunicação entre pods
- Anexar/desanexar **Security Groups**
- Descrever **VPCs, Subnets, Route Tables** pra entender a topologia de rede
- Criar/deletar **Tags** em recursos pra rastreamento

### b) Por que os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly?

Porque os nodes (EC2) precisam **baixar imagens Docker** do ECR pra rodar os containers. A política `AmazonEC2ContainerRegistryReadOnly` dá permissão de leitura nos repositórios ECR da conta — especificamente:
- `ecr:GetAuthorizationToken` (autenticar no ECR)
- `ecr:BatchCheckLayerAvailability`, `ecr:GetDownloadUrlForLayer`, `ecr:BatchGetImage` (baixar as camadas da imagem)

**O que acontece se essa política NÃO estiver anexada:**

Os pods entram em status **`ImagePullBackOff`** — não conseguem nem iniciar. O `kubectl describe pod` mostra erro do tipo:
```
Failed to pull image "123.dkr.ecr.us-east-2.amazonaws.com/ads-unifaat-site:v1.0":
unauthorized: authentication required
```
A aplicação inteira fica indisponível porque nenhum pod consegue subir.

---

## Questão 4: Networking e Exposição

### a) Diferença entre ClusterIP, NodePort e LoadBalancer

| Tipo | Acesso | Quando usar |
|--|--|--|
| **ClusterIP** (padrão) | Só **dentro do cluster** — IP privado, acessível apenas por outros pods | Comunicação interna entre microsserviços (ex: API ↔ banco de dados) |
| **NodePort** | Expõe a aplicação em uma porta (30000-32767) **em cada node** do cluster — acessível via `<IP-do-node>:<porta>` | Acesso externo simples em ambientes on-premise ou dev/teste |
| **LoadBalancer** | Cria automaticamente um **balanceador de carga gerenciado** (ex: ELB na AWS) com DNS público — acessível por qualquer um na internet | Aplicações de produção expostas ao mundo |

### b) O que acontece na AWS quando você cria um Service tipo LoadBalancer

A AWS provisiona automaticamente um **Elastic Load Balancer (ELB)** — por padrão, do tipo **Classic Load Balancer** (CLB), mas pode ser configurado pra **NLB** (Network) ou **ALB** (Application) com anotações específicas.

O processo é:
1. O `kubectl apply -f service.yaml` (com `type: LoadBalancer`) é enviado ao Control Plane
2. O Control Plane usa a `EKSClusterRole` pra chamar a API da AWS e **criar o ELB**
3. O ELB recebe um **DNS público** (ex: `a1b2c3.us-east-2.elb.amazonaws.com`) e Security Groups
4. O ELB é configurado pra rotear o tráfego pra **portas dos Worker Nodes** onde os pods estão rodando (via NodePort interno)
5. O DNS é exposto no campo `EXTERNAL-IP` quando você executa `kubectl get svc`

### c) Por que é importante deletar o Service LoadBalancer antes de deletar o cluster EKS

Porque o **ELB é um recurso AWS independente** do cluster — ele foi provisionado pela API da AWS, não está "dentro" do cluster. Se você deletar o cluster sem deletar o Service:

- O cluster some, mas o **ELB continua existindo** na conta AWS
- Você continua sendo **cobrado por ele** (~$0,025/hora = ~$18/mês por LoadBalancer ocioso)
- Vira um **recurso órfão** — sem rotear tráfego pra lugar nenhum, mas gerando custo
- Pra deletar manualmente depois, você precisa achar na console AWS, conferir que não tem dependências, etc.

**Ordem correta de limpeza:** Service → Deployment → Namespace → Node Group → Cluster → VPC → IAM Roles → ECR.

---

## Questão 5: Tarefa Prática — Comandos EKS

**Cenário:** Cluster `producao-cluster`, Namespace `minha-app`, Imagem `111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0`, Réplicas: 3.

### a) Criar o namespace

```bash
kubectl create namespace minha-app
```

### b) Criar Deployment com 3 réplicas

**Via YAML (manifesto):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: minha-app
  labels:
    app: web-app
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
        - containerPort: 80
```

Aplicar:
```bash
kubectl apply -f deployment.yaml
```

**Ou via imperativo (atalho):**
```bash
kubectl create deployment web-app \
  --image=111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0 \
  --replicas=3 -n minha-app
```

### c) Expor a aplicação com Service LoadBalancer na porta 80

```bash
kubectl expose deployment web-app \
  --type=LoadBalancer \
  --port=80 \
  --target-port=80 \
  -n minha-app
```

### d) Escalar de 3 para 5 réplicas

```bash
kubectl scale deployment web-app --replicas=5 -n minha-app
```

### e) Verificar pods rodando e endpoint do LoadBalancer

```bash
# Status dos pods
kubectl get pods -n minha-app

# Endpoint do LoadBalancer
kubectl get svc web-app -n minha-app

# Comando direto pra extrair só o DNS
kubectl get svc web-app -n minha-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

## Questão 6: Evidências Práticas da Execução do Lab013

As evidências estão na pasta `prints/` deste diretório, organizadas por parte:

### Parte 1: Construção e Teste Local
- `01_docker_build.png` — `docker build --no-cache -t ads-unifaat-site:v1.0 .` finalizado com sucesso
- `02_curl_local.png` — `curl -s http://localhost:3000 | head -5` retornando o HTML da página
- `03_docker_images.png` — `docker images | grep ads-unifaat` listando a imagem v1.0

### Parte 2: Publicação no ECR
- `04_ecr_login.png` — `Login Succeeded` após autenticar no ECR
- `05_docker_push.png` — `docker push` enviando as layers da imagem
- `06_ecr_describe.png` — `aws ecr describe-images` confirmando tag `v1.0` no repositório

### Parte 3: Cluster EKS e Deploy
- `07_cluster_active.png` — `aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'` retornando `"ACTIVE"`
- `08_kubectl_get_nodes.png` — 2 nodes com status `Ready`
- `09_kubectl_get_deployments.png` — Deployment `ads-site` com `2/2` replicas disponíveis
- `10_kubectl_get_pods.png` — 2 pods `Running` no namespace `ads-unifaat`
- `11_kubectl_get_svc.png` — Service `ads-site-service` com `EXTERNAL-IP` (DNS do LoadBalancer)

### Parte 4: Acesso e Testes
- `12_curl_endpoint.png` — `curl -s http://$ENDPOINT | head -10` retornando HTML da aplicação
- `13_navegador.png` — Página do curso de ADS carregada no browser com a URL do LoadBalancer visível na barra
- `14_resiliencia.png` — `kubectl delete pod <nome>` + `kubectl get pods -w` mostrando o Kubernetes recriando o pod automaticamente (self-healing)

### Parte 5: Limpeza
- `15_cleanup_final.png` — Saída do bloco de verificação final mostrando clusters EKS vazios, repositórios ECR removidos e stacks CloudFormation deletados

---

## Lista de Comandos Executados no Lab013

### Preparação
```bash
mkdir -p ~/aulas_lab/aula013/app && cd ~/aulas_lab/aula013
AWS_ACCOUNT_ID="<seu-account-id>"
AWS_REGION="us-east-2"
REPO_NAME="ads-unifaat-site"
IMAGE_TAG="v1.0"
CLUSTER_NAME="cluster-eks-ads"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
aws sts get-caller-identity
```

### Build local e teste
```bash
cd ~/aulas_lab/aula013/app
docker build --no-cache -t ads-unifaat-site:$IMAGE_TAG .
docker run -d -p 3000:80 --name teste-ads ads-unifaat-site:$IMAGE_TAG
curl -s http://localhost:3000 | head -5
docker stop teste-ads && docker rm teste-ads
```

### ECR
```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag ads-unifaat-site:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker push $REPO_URI:$IMAGE_TAG
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION
```

### IAM Roles
```bash
# Cluster Role
aws iam create-role --role-name EKSClusterRole-ADS --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy --role-name EKSClusterRole-ADS

# Node Role
aws iam create-role --role-name EKSNodeRole-ADS --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### VPC + Cluster + Nodes
```bash
aws cloudformation create-stack --stack-name eks-vpc-ads --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
aws cloudformation wait stack-create-complete --stack-name eks-vpc-ads

SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name eks-vpc-ads --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' --output text)

aws eks create-cluster --name $CLUSTER_NAME --role-arn $(aws iam get-role --role-name EKSClusterRole-ADS --query 'Role.Arn' --output text) --resources-vpc-config subnetIds=$SUBNET_IDS --kubernetes-version 1.32
aws eks wait cluster-active --name $CLUSTER_NAME

aws eks create-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes --node-role $(aws iam get-role --role-name EKSNodeRole-ADS --query 'Role.Arn' --output text) --subnets $(echo $SUBNET_IDS | tr ',' ' ') --instance-types t3.medium --scaling-config minSize=2,maxSize=3,desiredSize=2
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
kubectl get nodes
```

### Deploy
```bash
kubectl create namespace ads-unifaat
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployments -n ads-unifaat
kubectl get pods -n ads-unifaat
kubectl get svc -n ads-unifaat
```

### Acesso e testes
```bash
ENDPOINT=$(kubectl get svc ads-site-service -n ads-unifaat -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s http://$ENDPOINT | head -20

# Resiliência
POD_NAME=$(kubectl get pods -n ads-unifaat -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD_NAME -n ads-unifaat
kubectl get pods -n ads-unifaat -w
```

### Limpeza
```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete namespace ads-unifaat

aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes
aws eks wait nodegroup-deleted --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes

aws eks delete-cluster --name $CLUSTER_NAME
aws eks wait cluster-deleted --name $CLUSTER_NAME

aws cloudformation delete-stack --stack-name eks-vpc-ads
aws cloudformation wait stack-delete-complete --stack-name eks-vpc-ads

aws iam detach-role-policy --role-name EKSClusterRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name EKSClusterRole-ADS
aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam delete-role --role-name EKSNodeRole-ADS

aws ecr delete-repository --repository-name $REPO_NAME --region $AWS_REGION --force
```

---

## Observações da Execução

- O cluster EKS levou cerca de **12 minutos** pra ficar com status `ACTIVE` após o `create-cluster` — não houve erro, apenas o tempo padrão de provisionamento da AWS.
- O Node Group levou mais **~5 minutos** depois do cluster.
- O `EXTERNAL-IP` do Service LoadBalancer apareceu como `<pending>` por cerca de 2 minutos até a AWS provisionar o ELB. O DNS no formato `*.us-east-2.elb.amazonaws.com` só ficou acessível após mais ~1 minuto de propagação DNS.
- Ao executar `kubectl delete pod` num dos pods, o Deployment recriou outro pod em **~3 segundos**, comprovando o self-healing.
- A limpeza foi executada na ordem correta (Service → Deployment → Namespace → NodeGroup → Cluster → VPC → IAM → ECR) e não restou nenhum recurso órfão na conta AWS.

---

## Estrutura desta entrega

```
3225002/
├── README.md                  # este arquivo
├── app/
│   ├── Dockerfile             # imagem Nginx + index.html
│   ├── index.html             # página do curso ADS
│   └── styles.css             # estilos
└── prints/
    ├── 01_docker_build.png
    ├── 02_curl_local.png
    ├── ... (15 evidências no total)
    └── 15_cleanup_final.png
```
