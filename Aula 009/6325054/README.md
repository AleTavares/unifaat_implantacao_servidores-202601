**RA:** 6325054
**Nome:** Leonardo Rafael Contini Costa

---

## 🧠 Questão 1: Arquitetura e Componentes

**a)**
O Control Plane é responsável por gerenciar o cluster Kubernetes, garantindo que o estado desejado seja mantido. Ele realiza funções como agendamento de Pods e controle geral do cluster.
Um componente chave é o **etcd**, que armazena o estado do cluster.

**b)**
O principal software nos Worker Nodes é o **kubelet**, responsável por garantir que os Pods estejam rodando conforme definido.

---

## 🧠 Questão 2: O Pod

**a)**
Um Pod pode conter múltiplos contêineres para permitir que aplicações trabalhem juntas (ex: padrão sidecar).
Eles compartilham:

* Rede (mesmo IP e portas)
* Volumes de armazenamento

**b)**
Não é recomendado criar Pods diretamente em produção porque eles não são gerenciados.
Se um Pod falhar, ele não será recriado automaticamente.
O ideal é usar um Deployment.

---

## 🧠 Questão 3: Manifesto YAML

Campos obrigatórios:

* apiVersion
* kind
* metadata
* spec

---

## ⚙️ Questão 4: Deployment

Arquivo: `deployment.yaml`

```yaml
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
```

---

## ⚙️ Questão 5: Service

Arquivo: `service.yaml`

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
      nodePort: 30000
```

---

## 🔄 Fluxo de Comunicação no Kubernetes

1. A requisição chega no Node pela porta **NodePort (30000)**
2. O Service `web-service-tf09` recebe a requisição
3. O Service usa o **selector (app: web-tf09)** para encontrar os Pods
4. O **kube-proxy** faz o balanceamento de carga
5. A requisição chega em um dos Pods na porta 80

---

## 🚀 Passo a Passo para Executar

### 1. Aplicar os manifestos

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 2. Verificar os recursos

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

### 3. Ver detalhes do Service

```bash
kubectl describe service web-service-tf09
```

### 4. Acessar a aplicação

Abra no navegador:

```
http://<IP_DO_NODE>:30000
```

> Exemplo:

```
http://192.168.0.10:30000
```

---

