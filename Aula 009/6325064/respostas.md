## Respostas TF - Aula 09 (Kubernetes)


# Questão 1: Arquitetura e Componentes

a)
O Control Plane é responsável por gerenciar o cluster Kubernetes, mantendo o estado desejado dos recursos, tomando decisões de agendamento e controlando a comunicação entre os componentes.

Um componente chave é o etcd, que armazena o estado do cluster.

b)
O principal software nos Worker Nodes é o kubelet, responsável por garantir que os Pods estejam rodando corretamente conforme definido.

# Questão 2: O Pod

a)
Um Pod pode conter múltiplos contêineres para suportar aplicações que precisam de componentes acoplados (ex: sidecar).
Eles compartilham:

Rede (mesmo IP)
Storage (volumes)

b)
Criar Pods diretamente é inadequado porque:

Não há controle de auto-recuperação (self-healing)
Não há escalabilidade automática
Não permite atualizações controladas

Por isso usamos Deployments.

# Questão 3: Manifesto YAML

Os quatro campos obrigatórios são:

apiVersion
kind
metadata
spec

# Questão 4: Deployment YAML

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
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80

# Questão 5: Service YAML

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


# Tarefa Prática Integrada (Fluxo)

Fluxo da requisição:

1 Entrada:
A requisição chega no Node através da porta NodePort (NodeIP:30080)
2 Service:
O Service web-service-tf09 recebe a requisição e usa o campo selector (app: web-tf09) para identificar os Pods
3 Proxy (kube-proxy):
O kube-proxy faz o balanceamento de carga entre os Pods disponíveis
4 Destino final:
A requisição chega em um dos Pods na porta 80, onde o container Nginx responde

## Passo a passo

1 - Acessar a pasta da atividade

cd "unifaat_implantacao_servidores-202601/Aula 009/6325064"

2 - Iniciar o cluster Kubernetes

minikube start 

3 - Aplicar os manifestos

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

4 - Verificar recursos criados

kubectl get pods
kubectl get services

5 - Acessar a aplicação (Nginx)

minikube service web-service-tf09 --url



