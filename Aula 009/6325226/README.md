# 📄 TF - Tarefa Final - Aula 09

**Disciplina:** Implementação de servidor e nuvem (cloud)
**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226

---

# ✅ Questão 1: Arquitetura e Componentes

**a)**
O **Control Plane (Master)** é responsável por gerenciar todo o cluster Kubernetes. Ele controla o estado geral do sistema, tomando decisões como agendamento de Pods, monitoramento e resposta a falhas.

Um dos principais componentes é:

* **etcd** → banco de dados distribuído que armazena o estado do cluster.

**b)**

O principal software que roda nos Worker Nodes é:

* **kubelet** → garante que os containers dentro dos Pods estejam rodando corretamente conforme definido.

---

# ✅ Questão 2: O Pod

**a)**

Um Pod pode conter múltiplos containers para que eles trabalhem juntos como uma única unidade.

Eles compartilham:

* Rede (mesmo IP)
* Volumes (armazenamento)

**b)**

Não é recomendado criar Pods diretamente em produção porque:

* Não há recuperação automática de falhas
* Não há escalabilidade
* Não permite atualizações seguras

👉 O ideal é usar **Deployment**

---

# ✅ Questão 3: Estrutura YAML

Campos obrigatórios:

```yaml
apiVersion:
kind:
metadata:
spec:
```

---

# ✅ Questão 4: Deployment

## 📄 deployment.yaml

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

# ✅ Questão 5: Service

## 📄 service.yaml

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
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30000
```

---

# 🔄 Fluxo de Comunicação (Obrigatório)

1. O usuário acessa:

   ```
   NodeIP:30000
   ```

2. O Service **web-service-tf09** recebe a requisição

3. O Service usa o campo:

   ```
   selector
   ```

   para identificar os Pods com:

   ```
   app: web-tf09
   ```

4. O **kube-proxy** faz o roteamento e balanceamento

5. A requisição chega em um dos Pods na porta:

   ```
   80
   ```

---

# 🚀 Passo a passo para executar

```bash
# iniciar cluster
minikube start

# aplicar deployment
kubectl apply -f deployment.yaml

# aplicar service
kubectl apply -f service.yaml

# verificar pods
kubectl get pods

# verificar service
kubectl get svc

# acessar aplicação
minikube service web-service-tf09
```

---

# 📦 Observações

* Deployment gerencia os Pods automaticamente
* Service garante acesso estável
* NodePort expõe a aplicação externamente

---
