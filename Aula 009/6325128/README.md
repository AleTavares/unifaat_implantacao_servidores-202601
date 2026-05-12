# TF009 - Tarefa Final: Fundamentos de Kubernetes

**RA:** 6325128

---

## Respostas às Questões Teóricas

### Questão 1: Arquitetura e Componentes

#### a) Função do Control Plane (Master)
O **Control Plane** é responsável por gerenciar todo o estado do cluster Kubernetes. Suas funções principais incluem:
- Receber e processar solicitações de API (via kube-apiserver)
- Armazenar o estado desejado do cluster (via etcd)
- Tomar decisões de agendamento de Pods (via kube-scheduler)
- Controlar os estados dos recursos (via kube-controller-manager)

**Componente chave:** `etcd` - banco de dados distribuído que armazena todos os dados do cluster em pares chave-valor, garantindo persistência e consistência do estado desejado.

#### b) Software responsável nos Worker Nodes
O **Kubelet** é o principal software que reside nos Worker Nodes. Ele funciona como um agente local que:
- Garante que os Pods desejados estejam em execução
- Monitora a saúde dos Pods
- Executa as ações necessárias para manter o estado desejado (iniciar, parar, reiniciar Pods)

---

### Questão 2: O Pod (Conceito Fundamental)

#### a) Por que um Pod pode conter múltiplos contêineres
Um Pod pode conter múltiplos contêineres porque compartilham a **mesma pilha de rede**. Isso significa que:
- **Rede:** Todos os contêineres em um Pod compartilham o mesmo endereço IP e namespace de rede; quando escutam conexões, devem usar portas distintas dentro do Pod
- **Storage:** Podem compartilhar volumes (storage) montados no Pod
- **Contexto:** Operam como uma unidade coesa, criada e gerenciada em conjunto pelo Kubernetes

Essa abordagem permite padrões de design como "sidecar containers" (contêiner auxiliar) e "ambassador pattern" para logging, monitoramento e proxy reverso.

#### b) Por que é inadequado criar Pods diretamente em produção
Criar Pods diretamente é inadequado porque:
- **Falta de resiliência:** Se um Pod morrer, ele não será automaticamente recriado
- **Sem escalabilidade:** Não há mecanismo automático para replicar Pods quando necessário
- **Atualizações difíceis:** Não há suporte a rolling updates ou versionamento
- **Gerenciamento manual:** Requer intervenção manual para manutenção, recuperação e escalagem

O correto é usar **Deployments**, que gerenciam ReplicaSets, que por sua vez criam e mantêm os Pods.

---

### Questão 3: Quatro Campos Obrigatórios no Manifesto YAML

Os **quatro campos obrigatórios** presentes na raiz de qualquer manifesto YAML de objeto Kubernetes são:

1. **`apiVersion`** - Versão da API Kubernetes utilizada (ex: `v1`, `apps/v1`)
2. **`kind`** - Tipo de objeto Kubernetes (ex: `Pod`, `Deployment`, `Service`)
3. **`metadata`** - Informações sobre o objeto (deve conter `name`, pode conter `labels`, `namespace`, etc.)
4. **`spec`** - Especificação desejada do objeto (estrutura varia conforme o `kind`)

---

### Questão 4: Deployment

Consulte o arquivo `deployment.yaml` nesta pasta.

---

### Questão 5: Service

Consulte o arquivo `service.yaml` nesta pasta.

---

### Tarefa Prática Integrada: Fluxo de Comunicação

#### Cenário:
Um usuário final tenta acessar a aplicação Nginx através de um dos Nodes do Cluster Kubernetes.

#### Fluxo Detalhado:

**1. Entrada - NodePort**
- A requisição chega na porta **30xxx** (porta NodePort atribuída pelo Service) em um dos Nodes do cluster
- O usuário acessa: `http://<NODE_IP>:30xxx`

**2. Service (web-service-tf09)**
- O Service intercepta a requisição na porta de serviço (80)
- Utiliza o campo **`selector`** (que contém `app: web-tf09`) para identificar quais Pods são elegíveis para receber o tráfego
- O Service consulta o endpoint controller para obter a lista de IPs dos Pods que correspondem ao seletor

**3. kube-proxy (Componente de Roteamento)**
- O **kube-proxy** é o componente responsável por rotear o tráfego do Service para um dos Pods ativos
- Utiliza regras de iptables (ou IPVS, dependendo da configuração) para realizar o load balancing
- Seleciona um Pod de forma distribuída entre as réplicas ativas

**4. Destino Final - Pod**
- A requisição é entregue ao Pod selecionado na porta de container (80)
- O Pod executa o contêiner Nginx, que processa a requisição HTTP
- A resposta retorna pelo mesmo caminho ao cliente

#### Objetos/Componentes Envolvidos:
1. **NodePort** (porta de acesso externo)
2. **Service (web-service-tf09)** - define selector e roteamento
3. **kube-proxy** - realiza o load balancing
4. **Pods gerenciados pelo Deployment** - executam a aplicação

---

## Passo a Passo para Subir o Ambiente

### Pré-requisitos
- Cluster Kubernetes instalado e funcionando (ex: Minikube, Kind ou cluster real)
- `kubectl` configurado e conectado ao cluster
- Acesso ao terminal/shell

### Passos

#### 1. Aplicar os manifestos YAML
```bash
# Aplicar o Deployment
kubectl apply -f deployment.yaml

# Aplicar o Service
kubectl apply -f service.yaml
```

#### 2. Verificar se o Deployment foi criado
```bash
kubectl get deployments
```
Saída esperada:
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy-tf09  3/3     3            3           10s
```

#### 3. Verificar se os Pods foram criados
```bash
kubectl get pods
```
Saída esperada (3 Pods em execução):
```
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deploy-tf09-xxxx-xxxxx       1/1     Running   0          10s
nginx-deploy-tf09-xxxx-xxxxx       1/1     Running   0          10s
nginx-deploy-tf09-xxxx-xxxxx       1/1     Running   0          10s
```

#### 4. Verificar se o Service foi criado
```bash
kubectl get services
```
Saída esperada:
```
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
web-service-tf09  NodePort   10.96.xxx.xxx  <none>        80:30xxx/TCP   5s
```

#### 5. Obter a porta NodePort
```bash
kubectl get service web-service-tf09 -o jsonpath='{.spec.ports[0].nodePort}'
```
Isso retornará a porta (ex: 30123)

#### 6. Obter o IP do Node (para Minikube)
```bash
kubectl get nodes -o wide
# ou para Minikube especificamente:
minikube ip
```

#### 7. Acessar a aplicação
```bash
# Substituir <NODE_IP> e <NODE_PORT> pelos valores obtidos
curl http://<NODE_IP>:<NODE_PORT>

# Exemplo para Minikube:
curl http://192.168.x.x:30123
```

Você deverá receber a página padrão do Nginx em HTML.

#### 8. Limpeza (se necessário)
```bash
# Remover o Service
kubectl delete service web-service-tf09

# Remover o Deployment
kubectl delete deployment nginx-deploy-tf09
```

---

## Arquivos Incluídos

- `README.md` - Este arquivo
- `deployment.yaml` - Manifesto YAML para o Deployment
- `service.yaml` - Manifesto YAML para o Service
