# TF - Aula 09 - Fundamentos de Kubernetes

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)
**Aula:** 09 — Fundamentos de Kubernetes (K8s)

---

## Respostas das Questões

### Questão 1 — Arquitetura e Componentes

**a) Função do Control Plane e um componente chave:**

O **Control Plane** (também chamado de Master) é o cérebro do cluster Kubernetes. Ele é responsável por:
- Manter o **estado desejado** do cluster (o que o usuário declarou via manifestos).
- Tomar decisões globais como agendamento (scheduling) de Pods, escalonamento e detecção/resposta a falhas.
- Expor a API que clientes (kubectl, controllers, etc.) usam pra interagir com o cluster.

**Componente chave que reside nele:** **etcd** — banco de dados distribuído chave-valor que armazena todo o estado do cluster (configurações, especificações, status). Outros componentes que ficam no Control Plane: API Server, Scheduler e Controller Manager.

**b) Software principal nos Worker Nodes:**

O **kubelet** é o agente que roda em cada Worker Node. Ele recebe as especificações dos Pods do API Server e garante que os contêineres definidos estejam rodando e saudáveis no nó, mantendo o estado desejado. Reporta status de volta ao Control Plane periodicamente.

---

### Questão 2 — O Pod (Conceito Fundamental)

**a) Por que múltiplos contêineres num mesmo Pod?**

Um Pod pode conter múltiplos contêineres quando eles precisam estar **fortemente acoplados** e operar como uma unidade lógica. Os contêineres no mesmo Pod compartilham:

- **Mesmo namespace de rede** (mesmo IP, mesmas portas — comunicam via `localhost`).
- **Mesmos volumes de armazenamento** (volumes do Pod são montados em todos os contêineres).
- **Mesmo ciclo de vida** (são iniciados e encerrados juntos).

Caso de uso clássico: **sidecar pattern** — um contêiner principal de aplicação acompanhado de um contêiner auxiliar (ex.: log shipper, proxy reverso, sincronizador de configuração).

**b) Por que é inadequado criar Pods diretamente em produção?**

Pods criados diretamente (manifesto Pod puro) são objetos **efêmeros sem auto-healing**. Eles:
- Não são recriados automaticamente se o nó cair ou o Pod for removido.
- Não suportam rolling updates ou rollback.
- Não têm controle de réplicas (escalabilidade horizontal).

Em produção sempre se usa um **controller** que gerencia os Pods — geralmente **Deployment** (apps stateless), **StatefulSet** (apps com estado persistente) ou **DaemonSet** (1 Pod por nó). O controller mantém o estado desejado: se um Pod morre, ele recria; se falta réplica, ele escala.

---

### Questão 3 — Manifesto YAML: Quatro Campos Obrigatórios

Todo manifesto YAML de objeto Kubernetes deve obrigatoriamente conter:

1. **`apiVersion`** — Versão da API do objeto (ex.: `apps/v1`, `v1`).
2. **`kind`** — Tipo do objeto (ex.: `Pod`, `Deployment`, `Service`).
3. **`metadata`** — Metadados (`name`, `namespace`, `labels`, `annotations`).
4. **`spec`** — Especificação do estado desejado do objeto.

---

### Questão 4 — Deployment (Manifesto YAML)

Arquivo: [`deployment.yaml`](./deployment.yaml)

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
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

Atende aos requisitos:
- ✅ Nome: `nginx-deploy-tf09`
- ✅ Imagem: `nginx:latest`
- ✅ Réplicas: 3
- ✅ Label do Pod: `app: web-tf09`

---

### Questão 5 — Service (Manifesto YAML)

Arquivo: [`service.yaml`](./service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-tf09
  labels:
    app: web-tf09
spec:
  type: NodePort
  selector:
    app: web-tf09
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Atende aos requisitos:
- ✅ Nome: `web-service-tf09`
- ✅ Selector: `app: web-tf09` (mesmo label dos Pods do Deployment)
- ✅ Tipo: `NodePort` (acesso externo)
- ✅ Service Port: `80`, Target Port: `80`

---

### Tarefa Prática Integrada — Fluxo de Comunicação

**Cenário:** Usuário externo acessa a aplicação Nginx através de um dos nós do cluster.

**Fluxo na ordem:**

1. **Entrada (NodePort):** A requisição chega na porta exposta do Node — `<Node-IP>:<NodePort>` (ex.: `192.168.0.10:30000`). O `kube-proxy` em cada nó monitora essa porta.

2. **Service (`web-service-tf09`):** O Service intercepta a requisição e usa o campo **`selector`** (`app: web-tf09`) para identificar quais Pods são elegíveis. Internamente, isso é resolvido via lista de **Endpoints** (objeto `Endpoints`/`EndpointSlice`) que contém os IPs dos Pods que casam com a label.

3. **Proxy (`kube-proxy`):** O componente **`kube-proxy`** que roda em cada Worker Node é o responsável por rotear o tráfego do Service para um dos Pods ativos. Ele faz isso configurando regras de iptables (ou IPVS) que fazem o load balancing entre as réplicas.

4. **Destino Final (Pod):** A requisição chega em um dos 3 **Pods** gerenciados pelo Deployment `nginx-deploy-tf09`, na porta `80` do contêiner Nginx (`targetPort: 80`).

**Resumo visual:**

```
Cliente externo
      ↓
Node IP : NodePort (30000-32767)
      ↓
Service (web-service-tf09) ── usa selector → Endpoints
      ↓
kube-proxy (load balance)
      ↓
Pod (nginx-deploy-tf09 — 1 das 3 réplicas) : 80
```

---

## Passo a Passo — Subir o Ambiente

### Pré-requisitos

- Kubernetes habilitado no Docker Desktop **ou** [minikube](https://minikube.sigs.k8s.io/docs/start/) **ou** [kind](https://kind.sigs.k8s.io/) instalado.
- `kubectl` instalado e configurado pra apontar pro cluster local.

### Passos

1. **Verificar o cluster está ativo:**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

2. **Aplicar o Deployment:**
   ```bash
   kubectl apply -f deployment.yaml
   ```

3. **Aplicar o Service:**
   ```bash
   kubectl apply -f service.yaml
   ```

4. **Verificar que os 3 Pods estão rodando:**
   ```bash
   kubectl get pods -l app=web-tf09
   ```
   Esperado: 3 Pods com status `Running`.

5. **Verificar o Service e descobrir a NodePort:**
   ```bash
   kubectl get svc web-service-tf09
   ```
   Saída de exemplo:
   ```
   NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
   web-service-tf09  NodePort   10.96.123.45    <none>        80:30257/TCP   10s
   ```
   Anote a porta atribuída (no exemplo, `30257`).

6. **Acessar a aplicação no navegador:**
   - Docker Desktop: `http://localhost:<NodePort>` (ex.: `http://localhost:30257`)
   - Minikube: pegar IP com `minikube ip` e acessar `http://<minikube-ip>:<NodePort>`

   Deve aparecer a página padrão do Nginx ("Welcome to nginx!").

7. **Testar load balance via terminal (várias requisições caem em Pods diferentes):**
   ```bash
   for i in $(seq 1 6); do kubectl exec -it <um-pod> -- curl -s http://web-service-tf09 | head -1; done
   ```

### Limpeza do Ambiente

```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```

---

## Estrutura de Arquivos

```
Aula 009/3225002/
├── README.md         ← este arquivo
├── deployment.yaml   ← Questão 4
└── service.yaml      ← Questão 5
```
