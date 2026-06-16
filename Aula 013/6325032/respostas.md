Questão 1: Conceitos de Kubernetes e EKS
a)

Control Plane: Gerencia o cluster Kubernetes (API Server, Scheduler, etcd e Controller Manager). No EKS, é gerenciado pela AWS.

Worker Nodes: São as instâncias EC2 que executam os Pods e aplicações. São gerenciadas pelo usuário.

b)

Self-healing é a capacidade do Kubernetes de recuperar automaticamente falhas.

Quando um Pod falha:

O Kubernetes detecta o problema.
Remove o Pod defeituoso.
Cria automaticamente outro Pod para manter o estado desejado.
Questão 2: Objetos Kubernetes
a)

Deployment

Gerencia Pods.
Define quantidade de réplicas.
Faz atualizações e rollback.

Service

Expõe os Pods na rede.
Fornece acesso estável à aplicação.
b)

Labels
São pares chave/valor usados para identificar recursos.

Exemplo:

labels:
  app: ads-site

Selectors
Selecionam recursos com determinadas labels.

Exemplo:

selector:
  app: ads-site

O Service encontra os Pods através das Labels e Selectors.

c)

livenessProbe

Verifica se a aplicação está viva.
Se falhar, o Pod é reiniciado.

Exemplo:

Aplicação travou e não responde.

readinessProbe

Verifica se a aplicação está pronta para receber tráfego.
Se falhar, o Pod deixa de receber requisições.

Exemplo:

Aplicação ainda carregando dados ao iniciar.
Questão 3: IAM e Permissões
a)

A EKSClusterRole permite que o EKS gerencie recursos AWS em nome do cluster.

Exemplos:

Criar interfaces de rede.
Integrar com serviços AWS.
Gerenciar balanceadores de carga.
b)

A política:

AmazonEC2ContainerRegistryReadOnly

permite que os Worker Nodes baixem imagens do ECR.

Sem ela:

Os Pods não conseguem baixar imagens.
O status fica como:
ImagePullBackOff

ou

ErrImagePull
Questão 4: Networking e Exposição
a)

ClusterIP

Acesso apenas dentro do cluster.

NodePort

Expõe a aplicação através de uma porta dos Nodes.

LoadBalancer

Cria um balanceador de carga externo.
Permite acesso pela internet.
b)

Ao criar um Service do tipo LoadBalancer, a AWS cria automaticamente um:

Elastic Load Balancer (ELB)

e associa o tráfego aos Pods.

c)

Porque o Load Balancer continua existindo e gerando custos na AWS.

Removê-lo antes evita:

Recursos órfãos.
Cobranças desnecessárias.
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)
![alt text](image.png)