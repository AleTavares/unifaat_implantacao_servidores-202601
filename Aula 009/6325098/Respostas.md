1: a) O Control Plane é responsável por gerenciar todo o cluster Kubernetes, tomando decisões globais (como agendamento de Pods), mantendo o estado desejado dos objetos e respondendo a eventos do cluster. Um componente chave que reside nele é o kube-apiserver (além do etcd, scheduler e controller-manager).

b) O principal software nos Worker Nodes é o kubelet, responsável por garantir que os Pods estejam rodando e saudáveis, mantendo o "estado desejado" conforme definido pelo Control Plane

2: Questão 2: O Pod (Conceito Fundamental) (Teórica)
O **Pod** é a unidade de *deployment* mais básica no Kubernetes.

a) a) Um Pod pode conter múltiplos contêineres para que eles possam trabalhar juntos de forma acoplada, compartilhando recursos e comunicação local (por exemplo, um contêiner principal e um auxiliar "sidecar"). A principal regra é que todos os contêineres de um Pod compartilham a mesma rede (IP e portas) e, se configurado, volumes de armazenamento.

b) É inadequado criar Pods diretamente em produção porque Pods criados dessa forma não possuem mecanismos automáticos de replicação, atualização ou recuperação em caso de falha. O ideal é usar objetos como Deployments, que gerenciam o ciclo de vida dos Pods e garantem alta disponibilidade.
...existing code...

3: Os quatro campos obrigatórios na raiz de qualquer manifesto YAML de objeto Kubernetes são:
- **apiVersion**
- **kind**
- **metadata**
- **spec**
...existing code...

4: apiVersion: apps/v1
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

    5:  apiVersion: v1
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

  

Tarefa Prática Integrada

1. **Entrada:** A requisição chega na porta do NodePort em um dos Nodes do cluster (exemplo: Node IP:30000).
2. **Service:** O Service `web-service-tf09` intercepta a requisição e utiliza o campo **selector** (label `app: web-tf09`) para identificar quais Pods podem receber o tráfego.
3. **Proxy:** O componente **kube-proxy** é responsável por rotear o tráfego do Service para um dos Pods ativos.
4. **Destino Final:** A requisição chega a um dos **Pods** (gerenciados pelo Deployment) na porta 80, onde a aplicação Nginx está rodando.
...existing code...   