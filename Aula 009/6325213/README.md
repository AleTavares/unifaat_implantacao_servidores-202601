Respostas:

### Teórica
## Questão 1
a) Ele é responsavel por todo gerenciamento e decisões do clouster, o seu componente chave é ectd, pois ele é o "banco de dados" de geral.

b) É o proprio Kubelet

## Questão 2:
a) Ele pode conter mutiplos container para trabalharem juntos, utilizam tudo o mesmo storage/rede, assim é como se estivessem em um  mini-servidor

b) Pq ele fica sem controle, n pode ser modificado, fica menos util é efêmero

## Questão 3:
apiVersion → qual API
kind → que tipo de objeto
metadata → quem é o objeto
spec → como ele deve ser

## Questão 4: Deployment (Prática)
Criar um documento deployment.yaml e colocar esses dados nele:
´´´bash
    apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-tf09
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
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
´´´

## Questão 5: Service
Criar um documento service.yaml com esses dados:
´´´bash
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
      protocol: TCP
      # nodePort: 30007  # opcional (Kubernetes pode atribuir automaticamente)
´´´

## Tarefa Prática Integrada
Fluxo:
1-A requisição externa chega ao cluster através do Node IP + NodePort configurado no Service.
2-O Service web-service-tf09 recebe a requisição e utiliza o campo selector (app: web-tf09) para identificar os Pods disponíveis.
3-O tráfego é roteado internamente pelo kube-proxy, que encaminha a requisição para um dos Pods ativos.
4-A requisição chega a um dos Pods gerenciados pelo Deployment, na porta 80, onde o Nginx responde ao cliente.

# Passo a Passo:
1- Pré-requisitos

Ter o Kubernetes instalado (ex: Minikube)
Ter o kubectl configurado

2- Iniciar o cluster
´´´bash
    minikube start

3- Aplicar o Deployment
´´´bash
    kubectl apply -f deployment.yaml

4- Aplicar Service
´´´bash
    kubectl apply -f service.yaml

5- Verificar Pods
´´´bash
    kubectl get pods

6- Verificar Service
´´´bash
    kubectl get svc

7- Acessar a aplicação
´´´bash
    minikube service web-service-tf09