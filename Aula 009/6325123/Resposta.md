# Aula 009 - Kubernetes

RA: 6325123

## Respostas do Lab 009

1. Se um Pod morrer, o objeto acionado para manter a quantidade desejada de replicas e o Deployment, que gerencia o ReplicaSet e recria os Pods quando necessario.

2. Para comunicacao interna com a aplicacao, outro Pod deve usar o Service, pois ele fornece um endereco estavel e faz o balanceamento para os Pods corretos.

3. Quando o trafego externo chega na porta `30080` de um Node, ele entra pelo Service do tipo NodePort e depois e roteado para a porta `80` do container Nginx, definida em `targetPort: 80`.

4. A label que conecta o Deployment ao Service e:

```yaml
app: web-app
```

No manifesto da tarefa final, a label equivalente usada foi:

```yaml
app: web-tf09
```

## Questao 1: Arquitetura e Componentes

a) O Control Plane e a parte responsavel por controlar o cluster Kubernetes. Ele recebe comandos pela API, armazena o estado do cluster, agenda Pods nos Nodes e garante que o estado real fique igual ao estado desejado. Um componente chave do Control Plane e o `etcd`, que armazena os dados e o estado do cluster.

b) Nos Worker Nodes, o principal software responsavel por garantir que os Pods estejam rodando e saudaveis e o `kubelet`. Ele conversa com o Control Plane e gerencia a execucao dos Pods no Node.

## Questao 2: Pod

a) Um Pod pode conter multiplos conteineres quando eles precisam trabalhar juntos de forma muito proxima, por exemplo um conteiner principal e um sidecar. Os conteineres dentro do mesmo Pod compartilham a mesma rede, o mesmo IP e podem compartilhar volumes.

b) Criar Pods diretamente em producao nao e uma boa pratica porque Pods sao efemeros. Se um Pod falhar, ele nao possui sozinho uma estrategia completa de recriacao, escalabilidade ou atualizacao. O recomendado e usar Deployment, que gerencia os Pods e mantem o estado desejado.

## Questao 3: Campos obrigatorios de um manifesto YAML

Os quatro campos principais na raiz de um manifesto Kubernetes sao:

```yaml
apiVersion:
kind:
metadata:
spec:
```

## Questao 4: Manifesto Deployment

Arquivo criado: `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-tf09
  labels:
    app: web-tf09
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-tf09
  template:
    metadata:
      labels:
        app: web-tf09
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
```

## Questao 5: Manifesto Service

Arquivo criado: `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-tf09
spec:
  type: NodePort
  selector:
    app: web-tf09
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

## Tarefa Pratica Integrada

Fluxo de comunicacao e gerenciamento:

1. O usuario acessa a aplicacao usando o IP de um Node e a porta exposta pelo NodePort, por exemplo `NodeIP:30080`.

2. A requisicao chega ao Service `web-service-tf09`. O Service usa o campo `selector` para encontrar quais Pods podem receber o trafego:

```yaml
selector:
  app: web-tf09
```

3. O componente `kube-proxy`, presente nos Worker Nodes, aplica as regras de rede e faz o roteamento do trafego do Service para um dos Pods ativos.

4. A requisicao chega a um Pod criado e mantido pelo Deployment `nginx-deploy-tf09`, acessando o container Nginx na porta `80`.

O Deployment garante que existam 3 replicas do Pod. Se algum Pod parar ou for removido, o Deployment cria outro para manter o estado desejado.

## Passo a passo para subir o ambiente

```bash
cd "Aula 009/6325123"
minikube start
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployments
kubectl get pods
kubectl get services
minikube service web-service-tf09 --url
kubectl scale deployment nginx-deploy-tf09 --replicas=5
kubectl get pods
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
minikube stop
```
