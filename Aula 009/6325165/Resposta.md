Se um Pod morrer, o Deployment é o objeto responsável por manter o número desejado de réplicas: o Deployment gerencia um ReplicaSet, que cria ou substitui Pods conforme necessário.

Para comunicação interna entre aplicações no cluster deve-se usar um Service (tipo ClusterIP), que fornece um endereço estável (DNS) e faz o balanceamento de tráfego para os Pods corretos.

Quando tráfego externo chega na porta 30080 de um Node, ele entra via um Service do tipo NodePort (porta 30080) e é roteado para a porta 80 do container Nginx definida em targetPort: 80 (o Service encaminha para os Pods que expõem essa porta).

A label que vincula o Deployment ao Service é:
app: web-app

Questao 1: Arquitetura e Componentes
a) O Control Plane é o conjunto de componentes que gerencia o cluster Kubernetes: expõe a API (kube-apiserver), armazena o estado (etcd), toma decisões (kube-controller-manager) e agenda Pods (kube-scheduler). Ele recebe as solicitações via API e garante que o estado real converge para o estado desejado.

b) Nos Worker Nodes, o kubelet é o agente responsável por garantir que os Pods definidos sejam executados e estejam saudáveis; ele interage com o Control Plane e com o runtime de contêiner (por exemplo containerd) para criar/monitorar containers.

Questao 2: Pod
a) Um Pod pode ter múltiplos containers quando há necessidade de execução conjunta e compartilhamento de recursos, por exemplo um container principal e um sidecar. Containers no mesmo Pod compartilham IP, portas de rede e podem montar os mesmos volumes.

b) Criar Pods diretamente em produção não é recomendado porque Pods são efêmeros e não fornecem, por si só, mecanismos de recriação, escalonamento ou atualização. Para produção, usa-se Deployment, ReplicaSet ou StatefulSet, que gerenciam ciclos de vida e disponibilidade.

Questao 3: Campos obrigatorios de um manifesto YAML
Os quatro campos principais no nível raiz de um manifesto Kubernetes são:
- apiVersion
- kind
- metadata
- spec

Questao 4: Manifesto Deployment
Arquivo criado: deployment.yaml

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

Questao 5: Manifesto Service
Arquivo criado: service.yaml

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

Tarefa Pratica Integrada
Fluxo de comunicação e gerenciamento:
- O usuário acessa a aplicação via IP do Node e porta do NodePort: NodeIP:30080.
- A requisição chega ao Service web-service-tf09, que usa o selector (app: web-tf09) para localizar os Pods disponíveis.
- O kube-proxy aplica as regras locais de rede nos Nodes e roteia o tráfego do Service para um dos Pods destino.
- O tráfego alcança um Pod gerenciado pelo Deployment nginx-deploy-tf09, que expõe o container Nginx na porta 80.
- O Deployment mantém 3 réplicas; se um Pod falhar, ele cria outro para manter o estado desejado.

Passo a passo para subir o ambiente
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