# Respostas - Kubernetes e Amazon EKS

## Questão 1: Conceitos de Kubernetes e EKS (Teórica)

### a) Diferença entre Control Plane e Worker Nodes

O **Control Plane** é a camada responsável pelo gerenciamento do cluster Kubernetes. Ele controla o estado desejado da aplicação, agenda pods, monitora recursos e coordena toda a operação do cluster.

Principais componentes:
- API Server
- Scheduler
- Controller Manager
- etcd (banco de dados do cluster)

No Amazon EKS, o **Control Plane é totalmente gerenciado pela AWS**.

Os **Worker Nodes** são as máquinas (EC2 ou Fargate) onde os contêineres realmente executam. Eles hospedam os Pods da aplicação e executam componentes como:
- kubelet
- kube-proxy
- runtime de contêineres (containerd)

Os **Worker Nodes são gerenciados pelo cliente**, mesmo quando utilizando Managed Node Groups.

### b) Conceito de Self-Healing

O **self-healing** (auto-recuperação) é a capacidade do Kubernetes de restaurar automaticamente o estado desejado da aplicação.

Quando um Pod falha:
1. O Kubernetes detecta a falha.
2. O Pod é marcado como indisponível.
3. O Deployment identifica que o número desejado de réplicas não está sendo atendido.
4. Um novo Pod é criado automaticamente para substituir o que falhou.

Isso garante alta disponibilidade e reduz a necessidade de intervenção manual.

---

## Questão 2: Objetos Kubernetes (Teórica)

### a) Diferença entre Deployment e Service

#### Deployment
É responsável por gerenciar os Pods da aplicação.

Funções:
- Criar Pods
- Manter quantidade desejada de réplicas
- Realizar atualizações (rolling updates)
- Recuperar Pods com falha

#### Service
É responsável por fornecer acesso estável aos Pods.

Funções:
- Expor a aplicação na rede
- Balancear tráfego entre Pods
- Fornecer um endereço IP estável

Em resumo:
- **Deployment cria e gerencia Pods**
- **Service fornece acesso aos Pods**

### b) Labels e Selectors

#### Labels
São pares chave-valor utilizados para identificar recursos.

Exemplo:

```yaml
labels:
  app: nginx
  ambiente: producao
```

#### Selectors

São filtros usados para localizar recursos com determinadas labels.

Exemplo:

```yaml
selector:
  app: nginx
```

#### Como conectam Services aos Pods

Um Service utiliza Selectors para encontrar os Pods corretos.

Exemplo:

Pod:

```yaml
metadata:
  labels:
    app: nginx
```

Service:

```yaml
spec:
  selector:
    app: nginx
```

Nesse caso, o Service enviará tráfego para todos os Pods que possuírem a label `app=nginx`.

### c) Função das Probes

As Probes monitoram a saúde e disponibilidade dos contêineres.

#### livenessProbe

Verifica se a aplicação ainda está funcionando corretamente.

Se a verificação falhar:
- O Kubernetes reinicia o contêiner.

Exemplo prático:
- Uma API entra em deadlock e para de responder.
- A livenessProbe detecta o problema e reinicia o contêiner.

#### readinessProbe

Verifica se a aplicação está pronta para receber tráfego.

Se a verificação falhar:
- O Pod permanece em execução.
- O Service para de encaminhar requisições para ele.

Exemplo prático:
- Uma aplicação está iniciando e ainda carregando dados do banco.
- A readinessProbe impede que receba requisições antes de estar pronta.

---

## Questão 3: IAM e Permissões (Teórica)

### a) Por que o cluster EKS precisa de uma IAM Role própria?

O Control Plane do EKS precisa interagir com diversos serviços AWS em nome do cluster.

A role `EKSClusterRole` concede permissões para:
- Gerenciar recursos de rede
- Registrar e monitorar nós
- Integrar-se com serviços AWS
- Criar e gerenciar componentes necessários ao funcionamento do cluster

Sem essa role, o EKS não conseguiria operar adequadamente.

### b) Por que os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly?

Os Worker Nodes precisam baixar imagens armazenadas no Amazon ECR (Elastic Container Registry).

A política `AmazonEC2ContainerRegistryReadOnly` permite:
- Autenticar no ECR
- Consultar imagens
- Fazer download das imagens necessárias

Sem essa política:
- Os nós não conseguem acessar o ECR.
- Os Pods falham ao iniciar.
- O Kubernetes apresenta erros como:

```text
ImagePullBackOff
ErrImagePull
```

---

## Questão 4: Networking e Exposição (Teórica)

### a) Diferença entre ClusterIP, NodePort e LoadBalancer

#### ClusterIP

- Tipo padrão.
- Acesso apenas dentro do cluster.
- Não expõe a aplicação externamente.

#### NodePort

- Expõe a aplicação em uma porta fixa dos Worker Nodes.
- Permite acesso externo através do IP do nó.

Exemplo:

```text
http://IP_DO_NODE:30080
```

#### LoadBalancer

- Expõe a aplicação externamente através de um balanceador de carga.
- Distribui o tráfego entre os Pods automaticamente.
- É o método mais utilizado em ambientes de produção na AWS.

### b) O que acontece ao criar um Service do tipo LoadBalancer?

Quando um Service do tipo `LoadBalancer` é criado no Amazon EKS:

1. O Kubernetes envia uma solicitação para a AWS.
2. A AWS cria automaticamente um Elastic Load Balancer (ELB).
3. O Load Balancer recebe um endereço DNS público.
4. O tráfego recebido é encaminhado para os Worker Nodes e posteriormente para os Pods.

### c) Por que é importante deletar o Service LoadBalancer antes de deletar o cluster?

Ao criar um Service do tipo `LoadBalancer`, a AWS provisiona recursos externos que geram custos.

Se o cluster for deletado antes do Service:
- O Load Balancer pode permanecer ativo.
- Recursos associados podem ficar órfãos.
- Custos desnecessários podem continuar sendo cobrados.
- Pode ser necessário realizar a remoção manual dos recursos restantes.

Por isso, recomenda-se:
1. Deletar primeiro os Services do tipo `LoadBalancer`.
2. Confirmar que os Load Balancers foram removidos.
3. Somente então excluir o cluster EKS.

# Respostas - Questão 5: Tarefa Prática - Comandos EKS

## Dados Utilizados

- **Cluster:** `producao-cluster`
- **Namespace:** `minha-app`
- **Imagem ECR:** `111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0`
- **Réplicas iniciais:** `3`

---

## a) Criar o namespace no cluster

Primeiro, configure o kubectl para acessar o cluster EKS:

```bash
aws eks update-kubeconfig --region us-east-1 --name producao-cluster
```

Criar o namespace:

```bash
kubectl create namespace minha-app
```

Verificar:

```bash
kubectl get namespaces
```

---

## b) Criar um Deployment com 3 réplicas usando a imagem informada

### deployment.yaml

```yaml
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
        - containerPort: 80
```

Aplicar o Deployment:

```bash
kubectl apply -f deployment.yaml
```

Verificar:

```bash
kubectl get deployments -n minha-app
```

---

## c) Expor a aplicação ao mundo com um Service LoadBalancer na porta 80

### service.yaml

```yaml
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
    targetPort: 80
```

Aplicar o Service:

```bash
kubectl apply -f service.yaml
```

Verificar:

```bash
kubectl get svc -n minha-app
```

---

## d) Escalar o Deployment de 3 para 5 réplicas

```bash
kubectl scale deployment web-app \
  --replicas=5 \
  -n minha-app
```

Verificar:

```bash
kubectl get deployment web-app -n minha-app
```

Ou:

```bash
kubectl get pods -n minha-app
```

---

## e) Verificar se todos os Pods estão rodando e obter o endpoint do LoadBalancer

### Verificar Pods

```bash
kubectl get pods -n minha-app
```

Saída esperada:

```text
NAME                       READY   STATUS    RESTARTS   AGE
web-app-xxxxx              1/1     Running   0          2m
web-app-yyyyy              1/1     Running   0          2m
web-app-zzzzz              1/1     Running   0          2m
web-app-aaaaa              1/1     Running   0          1m
web-app-bbbbb              1/1     Running   0          1m
```

### Verificar o Deployment

```bash
kubectl get deployment web-app -n minha-app
```

Saída esperada:

```text
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
web-app   5/5     5            5           5m
```

### Obter o endpoint do LoadBalancer

```bash
kubectl get service web-app-service -n minha-app
```

Saída esperada:

```text
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP
web-app-service   LoadBalancer   10.100.10.20   a1b2c3d4.elb.amazonaws.com
```

Ou apenas o hostname:

```bash
kubectl get svc web-app-service \
  -n minha-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Exemplo de retorno:

```text
a1b2c3d4.elb.amazonaws.com
```

Esse endereço DNS público poderá ser acessado diretamente pelo navegador para consumir a aplicação.