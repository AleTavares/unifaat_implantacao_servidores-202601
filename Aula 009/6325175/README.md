Questão 1: Arquitetura e Componentes (Teórica)
O Cluster Kubernetes é dividido em dois conjuntos de Nós (Nodes) principais: o Control Plane (Master) e os Worker Nodes.

a) Explique a função do Control Plane e cite o nome de um componente chave que reside nele (ex: etcd). 
R:Gerencia o cluster Kubernetes e garante o estado desejado.
Componente exemplo: etcd, que armazena o estado do cluster.

b) Qual é o principal software que reside nos Worker Nodes e é responsável por garantir que o Pod desejado esteja rodando e saudável (mantendo o "estado desejado")?
R:O kubelet, que garante que os Pods estejam rodando e saudáveis conforme o estado definido.

Questão 2: O Pod (Conceito Fundamental) (Teórica)
O Pod é a unidade de deployment mais básica no Kubernetes.

a) Explique por que um Pod pode conter múltiplos contêineres e qual é a principal regra que esses contêineres compartilham (ex: rede, storage). 
R:Pod pode ter vários containers quando precisam compartilhar:
- Rede (mesmo IP)
- Storage
- Mesmo ciclo de vida

b) Por que é uma prática inadequada criar Pods diretamente (via manifesto Pod puro) em um ambiente de produção?
R:Porque não têm:
- Auto-restart
- Escalabilidade
- Atualização automática
Em produção usa-se Deployments.

Questão 3: Manifesto YAML (Prática Teórica)
Todo objeto Kubernetes é definido por um manifesto YAML. Quais são os quatro campos obrigatórios que devem estar presentes na raiz de qualquer manifesto YAML de objeto K8s?
R:Campos obrigatórios de um YAML Kubernetes:
- apiVersion
- kind
- metadata
- spec

Tarefa Prática Integrada (Obrigatória - Conceitual)
Entrada: Requisição chega na porta do NodePort (ex: Node IP:30000).
R:NodeIP:30000
A requisição entra no Node do cluster pela porta exposta pelo Service do tipo NodePort.

Service: O Service web-service-tf09 intercepta a requisição e usa qual campo para saber quais Pods são elegíveis?
R:O Service web-service-tf09 recebe a requisição e identifica quais Pods podem responder usando o campo: selector (app: web-tf09)

Proxy: Qual objeto (ou componente) dentro do K8s é responsável por rotear o tráfego do Service para um dos Pods ativos?
R:O componente responsável por rotear o tráfego dentro do cluster é o: kube-proxy. Ele pega a requisição do Service e encaminha para um dos Pods disponíveis usando regras de load balancing.

Destino Final: A requisição chega a um dos Pods (gerenciados pelo Deployment) na porta 80.
R:A requisição chega em um dos Pods gerenciados pelo Deployment nginx-deploy-tf09, na porta 80. O container nginx:latest processa e responde a requisição.

Usuário - NodePort (NodeIP:30000)
        - Service (selector: app=web-tf09)
        - kube-proxy (roteamento)
        - Pod do Deployment (porta 80)