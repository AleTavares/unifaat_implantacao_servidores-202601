## Questão 1:

## A:

O Control Plane é a parte responsável por gerenciar o cluster Kubernetes e nele é incluido: API Server, Controller Manager, etcd e Scheduler. Já no Amazon EKS o Control Plane é gerenciado pela AWS, o que significa que a AWS cuida de coisas como: Provisionamento dos componentes, Atualizações e patches, Alta disponibilidade, Backup e manutenção da infraestrutura do plano de controle.
Os Worker Nodes são as máquinas onde os contêineres e pods realmente executam. Eles executam componentes como kubelet e kube-proxy. Já a responsabilidade depende da configuração como por exemplo a AWS Fargate onde a AWS gerencia completamente a infraestrutura de nós.

## B:

Self-healing é a capacidade do Kubernetes de detectar falhas e restaurar automaticamente o estado desejado da aplicação. Em caso de falha o Kubernetes detecta que o pod está em falha, O controlador responsável percebe que o número de réplicas em execução ficou abaixo do desejado, o Kubernetes cria automaticamente um novo pod para substituir o que falhou, o Scheduler escolhe um Worker Node disponível para executar esse novo pod e a aplicação volta ao estado desejado sem intervenção manual

## Questão 2:

## A: 

Um Deployment é um objeto responsável por gerenciar a execução dos Pods da aplicação. Um Service fornece um ponto de acesso estável para um conjunto de Pods.

## B:

Labels são pares chave=valor adicionados aos objetos Kubernetes para identificá-los e organizá-los. Selectors são critérios utilizados para selecionar objetos que possuem determinadas labels. Um Service utiliza selectors para descobrir quais Pods devem receber tráfego.

## C: 

As Probes são verificações automáticas que o Kubernetes utiliza para monitorar a saúde dos contêineres. A livenessProbe verifica se a aplicação ainda está funcionando corretamente. Exemplo: Uma aplicação Java entra em deadlock e deixa de responder às requisições. A livenessProbe detecta a falta de resposta e reinicia o contêiner, recuperando o serviço sem intervenção manual.

## Questão 3:

## A:

O cluster EKS precisa de uma IAM Role própria porque o plano de controle (Control Plane) gerenciado pela AWS precisa interagir com outros serviços da AWS em nome do cluster. Essa role, normalmente chamada de EKSClusterRole, concede permissões para que o Kubernetes gerenciado pela AWS possa:Gerenciar e monitorar recursos do cluster.
Descobrir e registrar Worker Nodes, Consultar informações de instâncias EC2, Gerenciar interfaces de rede (ENIs) utilizadas pelos nós e pods e Integrar-se com serviços da AWS necessários ao funcionamento do cluster.

## B: 

Os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly para poder acessar e baixar imagens armazenadas no Amazon ECR. Quando um Pod é criado, o Kubernetes instrui o nó a baixar a imagem do contêiner antes de executá-lo. Para isso, o Worker Node precisa: Autenticar-se no ECR, Consultar os repositórios, Fazer o download das imagens. A política AmazonEC2ContainerRegistryReadOnly fornece permissões de leitura para essas operações.

## Questão 4:

## A:

O Kubernetes oferece diferentes tipos de Service para expor aplicações. O ClusterIP expõe a aplicação apenas dentro do cluster Kubernetes.O NodePort expõe a aplicação através de uma porta fixa em todos os Worker Nodes. O LoadBalancer expõe a aplicação através de um balanceador de carga externo.

## B:


o Kubernetes comunica-se com a AWS através da integração do provedor de nuvem. Automaticamente é provisionado um ELB 

## C:

É importante remover primeiro os Services do tipo LoadBalancer porque eles criam recursos externos na AWS que possuem custo e precisam ser limpos corretamente. 

