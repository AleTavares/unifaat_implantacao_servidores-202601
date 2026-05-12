## Questão 1: Arquitetura e Componentes (Teórica)
O Cluster Kubernetes é dividido em dois conjuntos de Nós (Nodes) principais: o **Control Plane (Master)** e os **Worker Nodes**.

a) **Explique** a função do **Control Plane** e cite o nome de um componente chave que reside nele (ex: etcd).
**R: Ele é o "cérebro" do cluster. O Controller Manager mantém o estado desejado da aplicação, monitorando clusters e executando loops de reconciliação.**

b) Qual é o principal software que reside nos **Worker Nodes** e é responsável por garantir que o Pod desejado esteja rodando e saudável (mantendo o "estado desejado")?
**R: Kubelet gerencia os pods do nó.**


## Questão 2: O Pod (Conceito Fundamental) (Teórica)
O **Pod** é a unidade de *deployment* mais básica no Kubernetes.

a) **Explique** por que um Pod pode conter **múltiplos contêineres** e qual é a principal regra que esses contêineres compartilham (ex: rede, *storage*).
**R: Um Pod no Kubernetes pode ter múltiplos contêineres para separar funções de um mesmo aplicativo que precisam trabalhar juntos (ex: padrão sidecar).Eles compartilham o mesmo IP/rede (localhost) e podem c ompartilhar volumes de armazenamento dentro do Pod.**

b) Por que é uma prática **inadequada** criar Pods diretamente (via manifesto Pod puro) em um ambiente de produção?
**R: Pois a vida útil deles é limitada, eles estão constantemente caindo e subindo com novos IPs etc.**


## Questão 3: Manifesto YAML (Prática Teórica)
Todo objeto Kubernetes é definido por um manifesto YAML. Quais são os **quatro campos obrigatórios** que devem estar presentes na raiz de **qualquer** manifesto YAML de objeto K8s?
**R: apiVersion → versão da API do recurso; kind → tipo do objeto (Pod, Deployment, Service, etc.); metadata → informações como nome e labels; spec → definição/estado desejado do objeto**


## Questão 4: Deployment (Prática)
O **Deployment** é o objeto que gerencia o estado desejado dos Pods, sendo responsável pela escalabilidade e atualizações *rolling*.

Crie um manifesto YAML completo para um **Deployment** que atenda aos seguintes requisitos:
1.  **Nome:** `nginx-deploy-tf09`.
2.  **Imagem:** `nginx:latest`.
3.  **Réplicas:** 3 instâncias do Pod.
4.  **Label:** O Pod deve ter a *label* `app: web-tf09`.

## Questão 5: Service (Prática)
O **Service** é o objeto que garante que a aplicação (Pods) seja exposta de forma estável, seja interna ou externamente.

Crie um manifesto YAML completo para um **Service** que atenda aos seguintes requisitos:
1.  **Nome:** `web-service-tf09`.
2.  O Service deve selecionar os Pods com a *label* `app: web-tf09` (criados na Questão 4).
3.  O tipo de Service deve ser **NodePort** (para acesso externo).
4.  A porta de acesso do Service (Service Port) deve ser **80** e a porta do contêiner (Target Port) deve ser **80**.

## Tarefa Prática Integrada (Obrigatória - Conceitual)
Descreva o fluxo de comunicação e gerenciamento entre os objetos criados nas Questões 4 e 5, desde o acesso externo até o Pod.

### Cenário:
O usuário final tenta acessar a aplicação Nginx através de um dos Nodes do Cluster K8s.

### Descrição do Fluxo:
Descreva o caminho percorrido pela requisição, citando **quatro** objetos ou componentes do K8s envolvidos, na ordem correta:

1.  **Entrada:** Requisição chega na porta do **NodePort** (ex: Node IP:30000).
2.  **Service:** O Service `web-service-tf09` intercepta a requisição e usa qual campo para saber quais Pods são elegíveis?
3.  **Proxy:** Qual objeto (ou componente) dentro do K8s é responsável por rotear o tráfego do Service para um dos Pods ativos?
4.  **Destino Final:** A requisição chega a um dos **Pods** (gerenciados pelo Deployment) na porta 80.
**R:No Kubernetes, a requisição chega ao Node pela porta NodePort. O Service web-service-tf09 intercepta a requisição e usa o campo spec.selector para identificar os Pods elegíveis. O kube-proxy realiza o roteamento e balanceamento da requisição para um dos Pods ativos. Por fim, a requisição chega ao Pod gerenciado pelo Deployment na porta 80, onde o Nginx processa a resposta.**