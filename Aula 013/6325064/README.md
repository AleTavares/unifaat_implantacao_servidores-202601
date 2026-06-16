## TF Aula 13

# Questão 1: Conceitos de Kubernetes e EKS (Teórica)
a) Qual é a diferença entre o Control Plane e os Worker Nodes em um cluster EKS? Quem gerencia cada um?

Control Plane (Plano de Controle): É o "cérebro" do Kubernetes. Ele toma decisões globais sobre o cluster (como agendamento de pods), detecta e responde a eventos no cluster. No EKS, ele é 100% gerenciado pela AWS, o que significa que o usuário não tem acesso direto às máquinas virtuais que o rodam, garantindo alta disponibilidade e escalabilidade automática.

Worker Nodes (Nós de Trabalho): São as máquinas (instâncias EC2) que efetivamente executam os containers das aplicações. Eles contêm os componentes necessários para rodar os Pods (como o kubelet e o Docker/containerd). No modelo padrão do EKS, eles são gerenciados pelo usuário (ou via Managed Node Groups), sendo de nossa responsabilidade a escolha do tamanho da instância e atualizações do sistema operacional.

b) Explique o conceito de self-healing no Kubernetes. O que acontece quando um pod falha?

Self-healing (Auto-recuperação): É a capacidade do Kubernetes de monitorar continuamente o estado do cluster e garantir que ele corresponda ao estado desejado (declarado nos manifestos).

Quando um Pod falha: O Kubernetes (através do Replication Controller ou Deployment) detecta que o container morreu ou parou de responder. Ele destrói o container/pod defeituoso e inicia um novo Pod automaticamente em um nó saudável para restabelecer o número de réplicas configurado, sem necessidade de intervenção humana.

# Questão 2: Objetos Kubernetes (Teórica)
a) Qual é a diferença entre um Deployment e um Service no Kubernetes?

Deployment: É o objeto responsável por gerenciar o ciclo de vida da aplicação (os Pods). Ele define qual imagem Docker usar, quantas réplicas (cópias) devem rodar, e como fazer atualizações de versão (rollouts) sem derrubar o sistema.

Service: É o objeto responsável pela rede e comunicação. Como os Pods nascem e morrem a todo momento (ganhando IPs novos), o Service atua como um endereço IP estático e um balanceador de carga interno fixo na frente desses Pods, permitindo que eles sejam acessados de forma confiável.

b) Explique o que são Labels e Selectors e como eles conectam um Service aos Pods corretos.

Labels (Etiquetas): São pares de chave-valor anexados aos objetos (como Pods). Exemplo: app: web-app.

Selectors (Seletores): São filtros definidos no Service para encontrar os Pods.

A conexão: O Service busca no cluster por qualquer Pod que possua exatamente as mesmas Labels especificadas no seu campo Selector. Se o seletor diz app: web-app, o Service automaticamente direciona o tráfego para todos os Pods marcados com essa etiqueta.

c) Qual é a função das Probes (livenessProbe e readinessProbe)? Dê um exemplo prático de quando cada uma é útil.

livenessProbe (Sonda de Sobrevivência): Verifica se a aplicação ainda está viva/rodando. Se falhar, o Kubernetes reinicia o container.

Exemplo Prático: Uma aplicação trava em um deadlock (paralisada) ou estoura a memória, parando de responder, mas o processo continua de pé. A probe detecta a falta de resposta e reinicia o container para restaurar o serviço.

readinessProbe (Sonda de Prontidão): Verifica se a aplicação está pronta para receber tráfego. Se falhar, o Kubernetes remove o Pod do balanceador de carga (Service), mas não o reinicia.

Exemplo Prático: No momento em que um Pod de backend inicia, ele precisa carregar 100MB de dados do banco de dados na memória antes de aceitar requisições. A probe garante que o tráfego só chegue a ele após a conclusão desse carregamento inicial.

# Questão 3: IAM e Permissões (Teórica)

a) Por que o cluster EKS precisa de uma IAM Role própria (EKSClusterRole)? Que tipo de ações essa role permite?
O Control Plane do EKS (gerenciado pela AWS) precisa interagir diretamente com outros recursos da sua conta AWS. Essa role permite que o Kubernetes crie, modifique e delete recursos como Security Groups, Network Interfaces (ENIs) para comunicação interna e instâncias EC2.

b) Por que os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly? O que acontece se essa política não estiver anexada?
Os Worker Nodes precisam dessa permissão para poder autenticar e fazer o download (pull) das imagens Docker que estão armazenadas de forma privada no Amazon ECR. Se essa política não estiver anexada, o Kubernetes falhará ao tentar subir os Pods, gerando o erro ErrImagePull ou ImagePullBackOff.

# Questão 4: Networking e Exposição (Teórica)
a) Qual a diferença entre os tipos de Service ClusterIP, NodePort e LoadBalancer no Kubernetes?

ClusterIP (Padrão): Expõe o serviço apenas internamente dentro do cluster. Útil para bancos de dados ou APIs internas que não devem ser vistas na internet.

NodePort: Abre uma porta específica e idêntica (entre 30000-32767) em todos os nós (máquinas) do cluster. A aplicação pode ser acessada pelo <IP-do-No>:<Porta-NodePort>.

LoadBalancer: Expõe o serviço externamente usando o balanceador de carga do provedor de nuvem.

b) O que acontece na AWS quando você cria um Service do tipo LoadBalancer? Qual recurso AWS é provisionado automaticamente?
O Kubernetes conversa com a API da AWS e provisiona automaticamente um balanceador de carga físico na infraestrutura da AWS, que pode ser um Classic Load Balancer (CLB) ou um Network Load Balancer (NLB). Um endereço DNS público (URL) é gerado e associado ao seu Service.

c) Por que é importante deletar o Service LoadBalancer antes de deletar o cluster EKS?
Porque o LoadBalancer é um recurso criado fora do escopo direto do cluster (na infraestrutura da AWS). Se você deletar o cluster EKS primeiro, o Kubernetes perde a capacidade de limpar o LoadBalancer na AWS. Ele ficará "órfão" rodando na sua conta, gerando custos financeiros desnecessários até que você o delete manualmente pelo painel da AWS.

# Questão 5: Tarefa Prática - Comandos EKS (Simulação / LocalStack)

a) Criar o namespace no cluster:

kubectl create namespace minha-app

b) Criar um Deployment com 3 réplicas usando a imagem informada:

kubectl apply -f deployment.yaml

c) Expor a aplicação ao mundo com um Service LoadBalancer na porta 80:

kubectl expose deployment web-app-deployment --type=LoadBalancer --port=80 --target-port=80 -n minha-app

d) Escalar o deployment de 3 para 5 réplicas usando kubectl:

kubectl scale deployment web-app-deployment --replicas=5 -n minha-app

e) Verificar se todos os pods estão rodando e obter o endpoint do LoadBalancer:

Para verificar os pods:
kubectl get pods -n minha-app

Para obter o endpoint (EXTERNAL-IP):
kubectl get svc -n minha-app

# Questão 6: Evidências Práticas da Execução do Lab013



