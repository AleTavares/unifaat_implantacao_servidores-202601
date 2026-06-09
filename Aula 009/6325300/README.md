## Questão 1: Arquitetura e Componentes (Teórica)
O Cluster Kubernetes é dividido em dois conjuntos de Nós (Nodes) principais: o **Control Plane (Master)** e os **Worker Nodes**.

a) **Explique** a função do **Control Plane** e cite o nome de um componente chave que reside nele (ex: etcd).

R: O Control Plane é o "cérebro" do cluster. Ele é responsável por tomar decisões globais sobre o cluster (como agendamento de Pods, detecção e resposta a eventos), bem como por manter o estado desejado do cluster.

Componente chave: etcd (ou kube-apiserver, kube-controller-manager, kube-scheduler).

b) Qual é o principal software que reside nos **Worker Nodes** e é responsável por garantir que o Pod desejado esteja rodando e saudável (mantendo o "estado desejado")?

R: O componente é o kubelet. Ele roda em cada nó e garante que todos os contêineres definidos em um Pod estejam funcionando perfeitamente.

## Questão 2: O Pod (Conceito Fundamental) (Teórica)
O **Pod** é a unidade de *deployment* mais básica no Kubernetes.

a) **Explique** por que um Pod pode conter **múltiplos contêineres** e qual é a principal regra que esses contêineres compartilham (ex: rede, *storage*).

R: Pods podem conter múltiplos contêineres quando estes são altamente acoplados e precisam trabalhar juntos (padrão sidecar).

Principal regra compartilhada: Eles compartilham os mesmos recursos de rede (incluindo o mesmo IP e portas) e volumes de armazenamento (storage).

b) Por que é uma prática **inadequada** criar Pods diretamente (via manifesto Pod puro) em um ambiente de produção?
 
R:Criar Pods puros diretamente é inadequado pois eles são efêmeros e não possuem capacidade de autocura. Se o nó falhar ou o contêiner terminar, o Pod não é substituído automaticamente, enquanto objetos como Deployments gerenciam o ciclo de vida e garantem a alta disponibilidade.

## Questão 3: Manifesto YAML (Prática Teórica)
Todo objeto Kubernetes é definido por um manifesto YAML. Quais são os **quatro campos obrigatórios** que devem estar presentes na raiz de **qualquer** manifesto YAML de objeto K8s?

R: Os quatro campos obrigatórios na raiz de qualquer manifesto do Kubernetes são:

apiVersion

kind

metadata

spec

-------------------------------------------------------------------------------

Descrição do Fluxo: Acesso Externo até o Pod
Entrada: A requisição do usuário chega pelo endereço IP do nó (Node IP) através da porta do NodePort (por exemplo, Node IP:30000 ou a porta dinâmica atribuída ao Service).

Service: O Service web-service-tf09 intercepta a requisição e utiliza o campo selector (definido como app: web-tf09) para identificar e selecionar os Pods que são elegíveis para receber o tráfego.

Proxy: O kube-proxy, componente de rede executado em cada nó do cluster, é responsável por rotear o tráfego do Service para um dos Pods ativos.

Destino Final: A requisição chega a um dos Pods (que foram criados e são gerenciados pelo Deployment nginx-deploy-tf09) na porta 80.

--------------------------------------------------------------------------------
**Tarefa Prática Integrada:**
1. Entrada: Requisição chega na porta do NodePort.
2. Service: Usa o campo `selector` para saber quais Pods são elegíveis.
3. Proxy: kube-proxy.
4. Destino Final: Pod na porta 80.