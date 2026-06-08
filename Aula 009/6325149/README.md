# Questões Teóricas

## Questão 1: Arquitetura e Componentes

**a) Função do Control Plane e Componente Chave**  
O *Control Plane* (o "Cérebro") é responsável por manter o estado global do cluster, tomar decisões de alocação e responder a eventos do sistema. Ele funciona como a inteligência central que gerencia, mas nunca executa as aplicações dos usuários.  
Um componente chave que reside nele é o **etcd** (conhecido como "O Cofre Forte"), que é o banco de dados que guarda o "Estado Desejado" de todo o cluster.  
Outros exemplos incluem o **API Server** e o **Scheduler**.

**b) Software nos Worker Nodes**  
O principal software responsável por garantir que os Pods estejam rodando e saudáveis é o **Kubelet** (o "Capitão"). Ele escuta as ordens do API Server e assegura que o estado real do nó corresponda ao estado desejado.

---

## Questão 2: O Pod (Conceito Fundamental)

**a) Múltiplos Contêineres e Regra Compartilhada**  
Um Pod funciona como um invólucro (*wrapper*) que pode envolver um ou mais contêineres que precisam trabalhar de forma muito próxima.  
A principal regra é que eles compartilham o mesmo isolamento mínimo e contexto de execução, sendo tratados como uma única unidade atômica de computação.

**b) Prática em Produção**  
Criar Pods diretamente é inadequado porque eles são efêmeros (*mortalidade*).  
Eles são tratados como "Gado" (*Cattle*), o que significa que se um Pod falhar ou o nó cair, ele é descartado e não será reiniciado automaticamente.  
Em produção, utiliza-se o **Deployment**, que garante que o número exato de réplicas esteja sempre rodando através do loop de auto-cura (*self-healing*).

---

## Questão 3: Manifesto YAML

Embora as fontes foquem na natureza declarativa do YAML (detalhando "o quê" você deseja em vez de "como" fazer), a estrutura padrão exigida na raiz de qualquer manifesto de objeto Kubernetes consiste nos seguintes quatro campos obrigatórios:

- **apiVersion**: Versão da API do Kubernetes utilizada para criar o objeto.  
- **kind**: O tipo de objeto que está sendo criado (ex: Pod, Service, Deployment).  
- **metadata**: Dados que ajudam a identificar o objeto (como *name* e *labels*).  
- **spec**: A definição do estado desejado para o objeto (onde se detalha contêineres, portas, réplicas, etc.).

---

## Questão 4: Deployment (Prática)

Manifesto YAML completo para o Deployment `nginx-deploy-tf09`:

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

**Explicação:**
- **apiVersion: apps/v1** - Versão da API para Deployments
- **kind: Deployment** - Tipo de objeto
- **metadata.name** - Nome único do Deployment
- **spec.replicas: 3** - Garante que 3 Pods sempre estejam rodando
- **selector.matchLabels** - O Deployment gerencia Pods com a label `app: web-tf09`
- **template.metadata.labels** - Label que conecta o Pod ao Deployment e ao Service
- **containers.image: nginx:latest** - Imagem Docker a ser utilizada
- **containerPort: 80** - Porta onde o Nginx escuta

---

## Questão 5: Service (Prática)

Manifesto YAML completo para o Service `web-service-tf09`:

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
```

**Explicação:**
- **apiVersion: v1** - Versão da API para Services
- **kind: Service** - Tipo de objeto
- **type: NodePort** - Expõe o serviço em uma porta em cada Node (ideal para desenvolvimento/teste)
- **selector.app: web-tf09** - Seleciona todos os Pods com essa label
- **port: 80** - Porta interna do Service
- **targetPort: 80** - Porta onde o contêiner Nginx escuta

---

## Tarefa Prática Integrada: Fluxo de Comunicação

### Cenário
Um usuário final tenta acessar a aplicação Nginx através de um dos Nodes do Cluster Kubernetes.

### Descrição do Fluxo de Requisição (4 Componentes K8s)

1. **Entrada - NodePort do Node:** 
   - Requisição chega na porta 30080 (ou outra atribuída) do IP do Node
   - Exemplo: `http://192.168.1.100:30080`

2. **Service (web-service-tf09):**
   - O Service intercepta a requisição na porta 80
   - Usa o campo **selector** (`app: web-tf09`) para identificar quais Pods são elegíveis
   - Verifica o ReplicaSet do Deployment para encontrar todos os Pods com essa label

3. **Kube-Proxy (Roteamento):**
   - O **kube-proxy** (componente do K8s que roda em cada Worker Node) é responsável por rotear o tráfego
   - Implementa um algoritmo de load balancing (round-robin por padrão)
   - Encaminha a requisição para um dos 3 Pods do Deployment

4. **Pod Nginx (Destino Final):**
   - A requisição chega a um dos Pods gerenciados pelo Deployment `nginx-deploy-tf09`
   - Chega na porta 80 (targetPort) do contêiner Nginx
   - O Nginx processa a requisição HTTP e retorna a resposta

### Benefícios dessa Arquitetura

- **Alta Disponibilidade:** Se um Pod falhar, o Deployment cria outro automaticamente
- **Load Balancing:** O Service distribui requisições entre os 3 Pods
- **Escalabilidade:** Pode-se aumentar/diminuir réplicas com `kubectl scale`
- **Endereço Estável:** O Service fornece um IP/porta fixos, mesmo com Pods sendo recriados

---

## Passo a Passo para Subir o Ambiente

### Pré-requisitos
- Minikube instalado
- kubectl instalado
- Docker Desktop rodando

### Instruções

1. **Iniciar o cluster Minikube:**
```bash
minikube start
```

2. **Verificar status do cluster:**
```bash
kubectl cluster-info
kubectl get nodes
```

3. **Clonar/Baixar os manifestos YAML:**
   - Coloque os arquivos `deployment.yaml` e `service.yaml` em um diretório de trabalho
```bash
mkdir -p ~/k8s-lab && cd ~/k8s-lab
```

4. **Aplicar o Deployment:**
```bash
kubectl apply -f deployment.yaml
```

5. **Aplicar o Service:**
```bash
kubectl apply -f service.yaml
```

6. **Verificar recursos criados:**
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

7. **Obter a URL do serviço:**
```bash
minikube service web-service-tf09 --url
```

8. **Testar a aplicação no navegador ou via curl:**
```bash
curl http://<IP>:<PORTA>
```

9. **Escalar o Deployment para 5 réplicas (teste):**
```bash
kubectl scale deployment nginx-deploy-tf09 --replicas=5
```

10. **Verificar os novos Pods:**
```bash
kubectl get pods
```

11. **Remover os recursos (limpeza):**
```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```

12. **Parar Minikube:**
```bash
minikube stop
```

---

## Arquivos Entregues

- `README.md` - Este arquivo com respostas teóricas, práticas e instruções
- `deployment.yaml` - Manifesto do Deployment nginx-deploy-tf09
- `service.yaml` - Manifesto do Service web-service-tf09

