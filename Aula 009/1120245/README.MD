# Questão 1: Arquitetura e Componentes

# A) 
O Control Plane é o "cérebro" do cluster: ele toma todas as decisões de orquestração, monitora o estado do cluster e garante que o estado atual corresponda ao estado desejado. É nele que vivem os componentes responsáveis por agendar workloads, responder a eventos e manter a configuração do cluster.
Um componente chave que reside no Control Plane é o etcd — um banco de dados chave-valor distribuído que armazena todo o estado do cluster (configurações, objetos, secrets etc.). Sem o etcd, o cluster perde a memória de tudo que foi definido.
Outros componentes importantes do Control Plane incluem o kube-apiserver (ponto central de comunicação), o kube-scheduler (decide em qual Node cada Pod será alocado) e o kube-controller-manager (executa os controladores que reconciliam o estado desejado).

# B) 
O principal software que reside nos Worker Nodes e é responsável por garantir que os Pods estejam rodando e saudáveis é o kubelet. Ele é um agente que roda em cada Node, recebe as especificações de Pod (PodSpecs) vindas do Control Plane via API Server e garante que os contêineres descritos estejam de fato rodando e íntegros — reiniciando-os se necessário para manter o estado desejado.

# Questão 2: O Pod 
# A)
Um Pod pode conter múltiplos contêineres quando eles precisam funcionar como uma unidade coesa — por exemplo, um contêiner principal de aplicação e um contêiner auxiliar (sidecar) responsável por coletar logs ou fazer proxy de rede.
A principal regra compartilhada entre esses contêineres é a mesma interface de rede (mesmo IP e namespace de rede) e o acesso aos mesmos volumes de armazenamento. Isso significa que eles se comunicam via localhost entre si e enxergam os mesmos dados em disco.

# B) 
Criar um Pod "puro" diretamente é inadequado porque o Pod é um objeto efêmero e sem autocura. Se ele falhar, travar ou o Node em que reside cair, o Kubernetes não recriará o Pod automaticamente — ele simplesmente desaparece. Não há controle de réplicas, sem rolling update, sem rollback. Em produção, sempre se usa um objeto controlador como o Deployment, que monitora e garante que o número desejado de Pods esteja sempre rodando.

# Questão 3: Manifesto YAML
Os quatro campos obrigatórios que devem estar presentes na raiz de qualquer manifesto YAML de objeto Kubernetes são:

apiVersion - Especifica a versão da API do Kubernetes a ser utilizada (ex: v1, apps/v1, batch/v1)

kind - Define o tipo de objeto Kubernetes (ex: Pod, Deployment, Service, ConfigMap, StatefulSet)

metadata - Contém informações sobre o objeto, como:

name - Nome do objeto
namespace - Namespace onde o objeto será criado
labels - Rótulos para identificação
annotations - Anotações adicionais
spec - Define a especificação/configuração desejada do objeto (seu estado esperado)

Exemplo estrutural:
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod
  namespace: default
spec:
  containers:
  - name: meu-container
    image: nginx:latest
    ports:
    - containerPort: 80



# Questão tarefa pratica integrada

Usuário Externo
     │
     │  HTTP Request → Node IP : 30000 (NodePort)
     ▼
┌─────────────────────────────────────────────────┐
│  1. NODE (Worker Node)                          │
│     Porta NodePort recebe a requisição externa  │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  2. SERVICE  (web-service-tf09)                 │
│     Usa o campo selector: app: web-tf09         │
│     para identificar quais Pods são elegíveis   │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  3. kube-proxy                                  │
│     Componente do Worker Node que mantém regras │
│     de rede (iptables/IPVS) e roteia o tráfego  │
│     do Service para um dos Pods ativos          │
└────────────────────┬────────────────────────────┘
                     │  (balanceamento entre os 3 Pods)
                     ▼
┌─────────────────────────────────────────────────┐
│  4. POD  (gerenciado pelo nginx-deploy-tf09)    │
│     Requisição chega ao contêiner nginx na      │
│     porta 80 → resposta retorna ao usuário      │
└─────────────────────────────────────────────────┘

Detalhamento do fluxo:

Entrada — NodePort: A requisição chega a qualquer Node do cluster na porta NodePort (ex: 30000). O Kubernetes expõe essa porta em todos os Nodes, mesmo que o Pod não esteja naquele Node específico.
Service — selector: O Service web-service-tf09 usa o campo selector: app: web-tf09 para descobrir dinamicamente quais Pods são elegíveis para receber a requisição. Qualquer Pod com essa label é candidato.
kube-proxy — roteamento: O kube-proxy, que roda em cada Node, é responsável por implementar as regras de rede (via iptables ou IPVS) que redirecionam o tráfego do Service para um dos Pods ativos, realizando load balancing entre as 3 réplicas.
Destino — Pod: A requisição chega ao contêiner nginx dentro de um dos 3 Pods na porta 80. O nginx processa e retorna a resposta, que percorre o caminho inverso até o usuário.



    

