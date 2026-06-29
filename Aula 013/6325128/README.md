# Entrega - RA000000000

## Questão 1: Conceitos de Kubernetes e EKS (Teórica)

### a) Diferença entre Control Plane e Worker Nodes
- Control Plane: componente gerenciado pela AWS EKS que controla o cluster. Inclui API server, scheduler, etcd e controllers.
- Worker Nodes: instâncias EC2 que executam os containers da aplicação.
- Quem gerencia: AWS gerencia o Control Plane; o aluno/usuário gerencia os Worker Nodes (via Node Group e EC2).

### b) Self-healing no Kubernetes
- Self-healing é a capacidade do Kubernetes de manter o estado desejado automaticamente.
- Quando um pod falha, o controlador (por exemplo, o Deployment) detecta a diferença entre o estado atual e o desejado e cria um novo pod para substituir o que caiu.

## Questão 2: Objetos Kubernetes (Teórica)

### a) Diferença entre Deployment e Service
- Deployment: define o estado desejado de um conjunto de pods, incluindo réplicas, atualização de imagem e políticas de rollout.
- Service: expõe os pods na rede e fornece acesso estável através de IP/DNS, além de balancear tráfego entre os pods.

### b) Labels e Selectors
- Labels: pares `key=value` anexados a objetos Kubernetes, usados para identificar e agrupar recursos.
- Selectors: critérios que um Service ou outro controlador usa para encontrar os Pods corretos.
- Conexão: um Service usa selectors para escolher os pods com labels correspondentes, direcionando tráfego apenas para esses pods.

### c) Função das Probes
- livenessProbe: verifica se o container ainda está vivo. Se falhar, o pod é reiniciado. Exemplo: útil quando a aplicação trava ou entra em deadlock.
- readinessProbe: verifica se o container está pronto para receber tráfego. Se falhar, o pod é removido do serviço. Exemplo: útil quando a aplicação ainda está carregando dados no startup.

## Questão 3: IAM e Permissões (Teórica)

### a) Por que o EKS precisa de IAM Role própria
- O cluster EKS precisa de uma role para assumir permissões AWS necessárias à criação e gerenciamento de recursos, como ENIs, Load Balancers e CloudWatch.
- Essa role permite ações de gerenciamento do cluster em nome do serviço EKS.

### b) Por que os Worker Nodes precisam de AmazonEC2ContainerRegistryReadOnly
- Essa política permite que os nodes puxem imagens do Amazon ECR.
- Se não estiver anexada, os nodes não conseguem baixar a imagem e os pods ficam em `ImagePullBackOff`.

## Questão 4: Networking e Exposição (Teórica)

### a) Diferença entre ClusterIP, NodePort e LoadBalancer
- ClusterIP: expõe o serviço somente dentro do cluster Kubernetes.
- NodePort: expõe o serviço em uma porta de cada node, permitindo acesso externo através do IP do node + porta.
- LoadBalancer: cria um balanceador de carga externo (na AWS, um ELB) e expõe o serviço publicamente.

### b) O que acontece na AWS com Service LoadBalancer
- A AWS provisiona automaticamente um recurso de Load Balancer (Elastic Load Balancer – ELB) e associa o serviço Kubernetes a ele.

### c) Por que deletar o Service LoadBalancer antes do cluster
- Para evitar que o recurso de Load Balancer continue ativo e gere custo após a remoção do cluster.
- Deletar o Service garante que o ELB e outros recursos associados sejam removidos antes do cluster ser destruído.

## Questão 5: Tarefa Prática - Comandos EKS (Simulação)

### a) Criar o namespace
```bash
kubectl create namespace minha-app
```

### b) Criar o Deployment
```bash
kubectl create deployment web-app \
  --image=111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0 \
  --replicas=3 -n minha-app
```
```
Ou em YAML:
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

### c) Expor a aplicação com LoadBalancer
```bash
kubectl expose deployment web-app \
  --type=LoadBalancer --port=80 --target-port=80 -n minha-app
```

### d) Escalar de 3 para 5 réplicas
```bash
kubectl scale deployment web-app --replicas=5 -n minha-app
```

### e) Verificar pods e endpoint
```bash
kubectl get pods -n minha-app
kubectl get svc -n minha-app
```

## Questão 6: Evidências Práticas da Execução do Lab013

### Comandos executados no Lab013
- `docker build --no-cache -t ads-unifaat-site:v1.0 .`
- `docker run -d -p 3000:80 --name teste-ads ads-unifaat-site:v1.0`
- `curl -s http://localhost:3000 | head -5`
- `docker stop teste-ads && docker rm teste-ads`
- `aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION`
- `aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com`
- `docker tag ads-unifaat-site:v1.0 $REPO_URI:v1.0`
- `docker push $REPO_URI:v1.0`
- `aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION`
- `aws eks create-cluster --name $CLUSTER_NAME --role-arn $EKS_ROLE --resources-vpc-config subnetIds=$SUBNET_IDS --kubernetes-version 1.32`
- `aws eks wait cluster-active --name $CLUSTER_NAME`
- `aws eks create-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes --node-role $NODE_ROLE --subnets $SUBNET_IDS --instance-types t3.medium --scaling-config minSize=2,maxSize=3,desiredSize=2`
- `aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes`
- `aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION`
- `kubectl create namespace ads-unifaat`
- `kubectl apply -f deployment.yaml`
- `kubectl apply -f service.yaml`
- `kubectl get deployments -n ads-unifaat`
- `kubectl get pods -n ads-unifaat`
- `kubectl get svc -n ads-unifaat`
- `curl -s http://$ENDPOINT | head -10`
- `kubectl delete pod $POD_NAME -n ads-unifaat`
- `kubectl get pods -n ads-unifaat -w`

### Observações
- O build local do Docker foi testado no ambiente WSL. O comando executado foi `docker build --no-cache -t ads-unifaat-site:v1.0 .`.
- A presença de `Aula 013/app/Dockerfile` confirma que a aplicação está pronta para containerização.
- Caso o docker não esteja disponível no WSL, a execução deve ser feita em um ambiente Linux com Docker ativo.
- A limpeza AWS deve seguir a ordem: deletar Service LoadBalancer, deletar Deployment/Pods, deletar NodeGroup, deletar Cluster, deletar VPC e IAM roles.

---

> Nota: Este README deve ser complementado com prints e evidências reais do terminal, além do título do PR no formato `RA - Nome do Aluno`.
