## Questão 1: Arquitetura e Componentes (Teórica)
O Cluster Kubernetes é dividido em dois conjuntos de Nós (Nodes) principais: o **Control Plane (Master)** e os **Worker Nodes**.

a) **Explique** a função do **Control Plane** e cite o nome de um componente chave que reside nele (ex: etcd).
* O Control Plane é responsável por gerenciar o estado desejado do cluster Kubernetes. Ele toma decisões sobre agendamento, mantém registros do cluster e responde a eventos. Um componente chave do Control Plane é o etcd, que armazena o estado do cluster de forma distribuída e consistente.

b) Qual é o principal software que reside nos **Worker Nodes** e é responsável por garantir que o Pod desejado esteja rodando e saudável (mantendo o "estado desejado")?
* O principal software que reside nos Worker Nodes é o kubelet, que garante que os Pods estejam rodando e saudáveis, mantendo o estado desejado conforme definido pelo Control Plane.

## Questão 2: O Pod (Conceito Fundamental) (Teórica)
O **Pod** é a unidade de *deployment* mais básica no Kubernetes.

a) **Explique** por que um Pod pode conter **múltiplos contêineres** e qual é a principal regra que esses contêineres compartilham (ex: rede, *storage*).
* Um Pod pode conter múltiplos contêineres para que eles compartilhem recursos como rede (mesmo IP e porta) e storage (volumes). Isso é útil para contêineres que precisam trabalhar juntos, como um contêiner principal e um auxiliar (sidecar).

b) Por que é uma prática **inadequada** criar Pods diretamente (via manifesto Pod puro) em um ambiente de produção?
* Criar Pods diretamente em produção é inadequado porque eles são efêmeros e não possuem mecanismos de escalabilidade ou gerenciamento de estado. Em vez disso, objetos como Deployments devem ser usados para gerenciar Pods de forma declarativa.

## Questão 3: Manifesto YAML (Prática Teórica)
Todo objeto Kubernetes é definido por um manifesto YAML. Quais são os **quatro campos obrigatórios** que devem estar presentes na raiz de **qualquer** manifesto YAML de objeto K8s?
1. apiVersion: Define a versão da API do Kubernetes usada para o objeto.
2. kind: Especifica o tipo do objeto (ex: Pod, Deployment, Service).
3. metadata: Contém informações como nome e labels do objeto.
4. spec: Define a especificação do estado desejado do objeto.