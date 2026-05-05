# TF09 - RA 6325104

## Respostas

1. Arquitetura e Componentes
a) Control Plane: gerencia o estado do cluster, faz a orquestração, mantém o registro do estado desejado e expõe a API. Um componente chave do Control Plane é o etcd.
b) Worker Nodes: o software principal é o kubelet, que garante que os Pods desejados estejam rodando e saudáveis.

2. O Pod
a) Um Pod pode conter múltiplos contêineres quando eles precisam rodar juntos e compartilhar rede e volumes, por exemplo em padrões sidecar. Esses contêineres compartilham espaço de rede e storage.
b) Criar Pods diretamente em produção é inadequado porque eles não são auto-recuperáveis, não têm gerenciamento de replicação nem atualizações automáticas; um Deployment oferece escalabilidade e auto-healing.

3. manifesto Kubernetes
- apiVersion
- kind
- metadata
- spec

4. Deployment
- Arquivo: nginx-deploy-tf09.yaml

5. Service
- Arquivo: web-service-tf09.yaml

## Fluxo de comunicação

1. Entrada

A requisição do usuário chega ao cluster Kubernetes através do endereço NodeIP:30000, utilizando a porta exposta do tipo NodePort em um dos Nodes.

2. Service

O Service web-service-tf09 intercepta a requisição e utiliza o campo selector para identificar os Pods elegíveis, selecionando aqueles que possuem a label app: web-tf09.

3. Proxy

O componente kube-proxy é responsável por rotear o tráfego recebido pelo Service, realizando o balanceamento de carga e encaminhando a requisição para um dos Pods disponíveis.

4. Destino Final

A requisição é entregue a um dos Pods gerenciados pelo Deployment nginx-deploy-tf09, sendo atendida pelo container Nginx na porta 80.