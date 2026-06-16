## Questão 1: Conceitos de Kubernetes e EKS

### a) Qual é a diferença entre o Control Plane e os Worker Nodes em um cluster EKS? Quem gerencia cada um?

O Control Plane é a parte responsável por controlar o cluster Kubernetes. Ele possui componentes como API Server, Scheduler, Controller Manager e etcd. No Amazon EKS, o Control Plane é gerenciado pela AWS, ou seja, a AWS cuida da disponibilidade, manutenção e operação dessa parte do cluster.

Os Worker Nodes são as máquinas onde os containers realmente executam. Eles rodam os pods da aplicação e recebem as cargas de trabalho enviadas pelo Kubernetes. No EKS, os Worker Nodes podem ser criados por Node Groups com instâncias EC2 e precisam de uma IAM Role própria.

Resumo:

- Control Plane: controla o cluster e é gerenciado pela AWS.
- Worker Nodes: executam os pods e aplicações, sendo configurados pelo usuário ou por node groups gerenciados.

### b) Explique o conceito de self-healing no Kubernetes. O que acontece quando um pod falha?

Self-healing é a capacidade do Kubernetes de recuperar automaticamente o estado desejado da aplicação. Se um pod falha, trava ou é deletado, o Kubernetes percebe que o número atual de réplicas está abaixo do número configurado no Deployment.

Quando isso acontece, o Kubernetes cria automaticamente um novo pod para substituir o pod com problema. Por exemplo, se um Deployment foi configurado com 2 réplicas e um dos pods é deletado, o Kubernetes cria outro pod para voltar ao total de 2 pods em execução.

---

## Questão 2: Objetos Kubernetes

### a) Qual é a diferença entre um Deployment e um Service no Kubernetes?

O Deployment define como a aplicação deve ser executada. Ele informa a imagem Docker que será usada, a quantidade de réplicas, as labels, as probes e as configurações dos pods.

O Service define como a aplicação será acessada na rede. Como os pods podem ser recriados e mudar de IP, o Service fornece um ponto de acesso estável para encaminhar o tráfego até os pods corretos.

Resumo:

- Deployment: cria e mantém os pods da aplicação.
- Service: expõe e encaminha tráfego para os pods.

### b) Explique o que são Labels e Selectors e como eles conectam um Service aos Pods corretos.

Labels são etiquetas em formato chave/valor usadas para identificar objetos no Kubernetes, como pods.

Exemplo:

    labels:
      app: ads-site

Selectors são filtros usados para encontrar recursos com determinadas labels.

Exemplo:

    selector:
      app: ads-site

Assim, um Service com selector app: ads-site envia tráfego para os pods que possuem a label app: ads-site. Dessa forma, o Service não depende do nome individual dos pods, mas sim das labels. Isso é importante porque pods podem ser deletados e recriados com nomes diferentes.

### c) Qual é a função das Probes (livenessProbe e readinessProbe)? Dê um exemplo prático de quando cada uma é útil.

As probes são verificações de saúde usadas pelo Kubernetes para identificar se o container está funcionando corretamente e se está pronto para receber tráfego.

A livenessProbe verifica se a aplicação ainda está viva. Se essa verificação falhar repetidamente, o Kubernetes pode reiniciar o container. Um exemplo prático seria uma aplicação web que travou e parou de responder na rota /.

A readinessProbe verifica se a aplicação está pronta para receber requisições. Se essa verificação falhar, o pod continua existindo, mas deixa de receber tráfego pelo Service até estar pronto novamente. Um exemplo prático seria uma aplicação que acabou de iniciar, mas ainda está carregando configurações ou inicializando o servidor web.

---

## Questão 3: IAM e Permissões

### a) Por que o cluster EKS precisa de uma IAM Role própria (EKSClusterRole)? Que tipo de ações essa role permite?

O cluster EKS precisa de uma IAM Role própria para permitir que o serviço Amazon EKS assuma permissões necessárias dentro da conta AWS.

Essa role permite que o EKS interaja com recursos da AWS relacionados à operação do cluster, como rede, controle do cluster e integração com outros serviços necessários ao funcionamento do Kubernetes gerenciado.

No lab, essa role é chamada de EKSClusterRole-ADS. Sem essa role, o serviço EKS não teria autorização para criar, consultar ou gerenciar corretamente os recursos associados ao cluster.

### b) Por que os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly? O que acontece se essa política não estiver anexada?

Os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly porque eles precisam baixar a imagem Docker armazenada no Amazon ECR.

No lab, a imagem ads-unifaat-site:v1.0 é enviada para o ECR, e os pods do Kubernetes usam essa imagem no Deployment. Quando o pod é criado, o node precisa puxar essa imagem do ECR.

Se essa política não estiver anexada à IAM Role dos Worker Nodes, os pods podem falhar ao iniciar, pois os nodes não conseguirão acessar a imagem no ECR. O erro mais comum nesse caso é ImagePullBackOff ou ErrImagePull.

---

## Questão 4: Networking e Exposição

### a) Qual a diferença entre os tipos de Service ClusterIP, NodePort e LoadBalancer no Kubernetes?

ClusterIP é o tipo padrão de Service. Ele expõe a aplicação apenas dentro do cluster, usando um IP interno.

NodePort expõe a aplicação em uma porta fixa nos Worker Nodes. Assim, é possível acessar a aplicação usando o IP de um node e a porta configurada.

LoadBalancer expõe a aplicação externamente usando um balanceador de carga do provedor de nuvem. No caso da AWS, ele cria automaticamente um Load Balancer para distribuir o tráfego para os pods.

Resumo:

- ClusterIP: acesso interno dentro do cluster.
- NodePort: acesso externo usando IP do node e porta.
- LoadBalancer: acesso externo usando um balanceador de carga da nuvem.

### b) O que acontece na AWS quando você cria um Service do tipo LoadBalancer? Qual recurso AWS é provisionado automaticamente?

Quando um Service do tipo LoadBalancer é criado em um cluster EKS, a AWS provisiona automaticamente um recurso de Elastic Load Balancing. Esse Load Balancer recebe um DNS público e encaminha o tráfego externo para os pods da aplicação.

No lab, isso acontece com o Service ads-site-service, que expõe a aplicação na porta 80.

### c) Por que é importante deletar o Service LoadBalancer antes de deletar o cluster EKS?

É importante deletar o Service do tipo LoadBalancer antes de deletar o cluster porque esse Service cria um recurso externo na AWS. Se o cluster for removido antes do Service, o Load Balancer pode continuar existindo de forma órfã e gerar cobrança.

Por isso, no cleanup, o correto é remover primeiro os recursos Kubernetes, principalmente o Service LoadBalancer, e depois remover o Node Group, o cluster EKS, a VPC, as IAM Roles e o repositório ECR.

---

## Questão 5: Tarefa Prática - Comandos EKS

Valores utilizados na simulação:

- Cluster: producao-cluster
- Namespace: minha-app
- Imagem ECR: 111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0
- Réplicas iniciais: 3

### a) Criar o namespace no cluster

    kubectl create namespace minha-app

### b) Criar um Deployment com 3 réplicas usando a imagem acima

Arquivo deployment.yaml:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
      namespace: minha-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: web-app
      template:
        metadata:
          labels:
            app: web-app
        spec:
          containers:
          - name: web-app
            image: 111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0
            ports:
            - containerPort: 80

Comando para aplicar:

    kubectl apply -f deployment.yaml

Também seria possível criar diretamente por comando:

    kubectl create deployment web-app --image=111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0 --replicas=3 -n minha-app

### c) Expor a aplicação ao mundo com um Service LoadBalancer na porta 80

    kubectl expose deployment web-app --type=LoadBalancer --port=80 --target-port=80 -n minha-app

### d) Escalar o Deployment de 3 para 5 réplicas usando kubectl

    kubectl scale deployment web-app --replicas=5 -n minha-app

### e) Verificar se todos os pods estão rodando e obter o endpoint do LoadBalancer

    kubectl get pods -n minha-app
    kubectl get deployments -n minha-app
    kubectl get svc -n minha-app

Para consultar somente o Service:

    kubectl get svc web-app -n minha-app

---

## Questão 6: Evidências Práticas da Execução do Lab013

As evidências devem ser colocadas na pasta:

    Aula 013/6325192/prints

Sugestão de organização:

    Aula 013/6325192/
    ├── README.md
    └── prints/
        ├── 01-docker-build.png
        ├── 02-teste-local-curl.png
        ├── 03-docker-images.png
        ├── 04-ecr-login.png
        ├── 05-ecr-push.png
        ├── 06-ecr-describe-images.png
        ├── 07-eks-active.png
        ├── 08-nodes-ready.png
        ├── 09-deployments.png
        ├── 10-pods-running.png
        ├── 11-service-loadbalancer.png
        ├── 12-curl-endpoint.png
        ├── 13-browser-loadbalancer.png
        ├── 14-self-healing.png
        └── 15-cleanup.png

---

## Lista dos comandos executados no Lab013

### 1. Atualização do fork

    git remote -v
    git remote add upstream https://github.com/AleTavares/unifaat_implantacao_servidores-202601.git
    git fetch upstream
    git checkout main
    git merge upstream/main
    git push origin main

Caso o remote upstream já exista, não é necessário adicionar novamente. Basta seguir a partir do git fetch upstream.

### 2. Preparação do ambiente do Lab013

    cd "Aula 013"

    AWS_ACCOUNT_ID="SEU_ACCOUNT_ID"
    AWS_REGION="us-east-2"
    REPO_NAME="ads-unifaat-site"
    IMAGE_TAG="v1.0"
    CLUSTER_NAME="cluster-eks-ads"
    REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

Verificação das ferramentas:

    aws --version
    docker --version
    kubectl version --client
    aws sts get-caller-identity

### 3. Construção e teste local

Entrar na pasta da aplicação:

    cd "Aula 013/app"
    ls -la

Build da imagem:

    docker build --no-cache -t ads-unifaat-site:v1.0 .

Teste local do container:

    docker run -d -p 3000:80 --name teste-ads ads-unifaat-site:v1.0
    curl -s http://localhost:3000 | head -5

Listagem da imagem:

    docker images | grep ads-unifaat

Parar e remover o container de teste:

    docker stop teste-ads && docker rm teste-ads

### 4. Publicação da imagem no ECR

Voltar ao diretório da Aula 013:

    cd ..

Configurar variáveis:

    AWS_REGION="us-east-2"
    REPO_NAME="ads-unifaat-site"
    IMAGE_TAG="v1.0"
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

Criar o repositório ECR:

    aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

Login no ECR:

    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

Tag da imagem:

    docker tag ads-unifaat-site:$IMAGE_TAG $REPO_URI:$IMAGE_TAG

Push da imagem:

    docker push $REPO_URI:$IMAGE_TAG

Verificação da imagem no ECR:

    aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].{Tags:imageTags,Size:imageSizeInBytes,Pushed:imagePushedAt}'

### 5. Configuração do cluster EKS

Criar IAM Role do cluster:

    aws iam create-role --role-name EKSClusterRole-ADS --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

Anexar política ao cluster:

    aws iam attach-role-policy --role-name EKSClusterRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

Criar IAM Role dos Worker Nodes:

    aws iam create-role --role-name EKSNodeRole-ADS --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

Anexar políticas aos Worker Nodes:

    aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
    aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    aws iam attach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

Criar VPC com CloudFormation:

    aws cloudformation create-stack --stack-name eks-vpc-ads --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
    aws cloudformation wait stack-create-complete --stack-name eks-vpc-ads

Obter subnets:

    SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name eks-vpc-ads --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' --output text)
    echo "Subnets: $SUBNET_IDS"

Criar cluster EKS:

    aws eks create-cluster --name $CLUSTER_NAME --role-arn $(aws iam get-role --role-name EKSClusterRole-ADS --query 'Role.Arn' --output text) --resources-vpc-config subnetIds=$SUBNET_IDS --kubernetes-version 1.32

Aguardar cluster ativo:

    aws eks wait cluster-active --name $CLUSTER_NAME
    aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status'

Criar Node Group:

    aws eks create-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes --node-role $(aws iam get-role --role-name EKSNodeRole-ADS --query 'Role.Arn' --output text) --subnets $(echo $SUBNET_IDS | tr ',' ' ') --instance-types t3.medium --scaling-config minSize=2,maxSize=3,desiredSize=2

Aguardar Node Group ativo:

    aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes

Configurar kubectl:

    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
    kubectl cluster-info
    kubectl get nodes

### 6. Deploy da aplicação no EKS

Criar namespace:

    kubectl create namespace ads-unifaat

Criar deployment.yaml:

    cat > deployment.yaml <<DEPLOY
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ads-site
      namespace: ads-unifaat
      labels:
        app: ads-site
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: ads-site
      template:
        metadata:
          labels:
            app: ads-site
        spec:
          containers:
          - name: ads-site
            image: ${REPO_URI}:${IMAGE_TAG}
            ports:
            - containerPort: 80
            resources:
              requests:
                memory: "64Mi"
                cpu: "50m"
              limits:
                memory: "128Mi"
                cpu: "100m"
            livenessProbe:
              httpGet:
                path: /
                port: 80
              initialDelaySeconds: 10
              periodSeconds: 30
            readinessProbe:
              httpGet:
                path: /
                port: 80
              initialDelaySeconds: 5
              periodSeconds: 10
    DEPLOY

Criar service.yaml:

    cat > service.yaml <<SERVICE
    apiVersion: v1
    kind: Service
    metadata:
      name: ads-site-service
      namespace: ads-unifaat
      labels:
        app: ads-site
    spec:
      type: LoadBalancer
      ports:
      - port: 80
        targetPort: 80
        protocol: TCP
      selector:
        app: ads-site
    SERVICE

Aplicar os manifestos:

    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml

Verificar deployment, pods e service:

    kubectl get deployments -n ads-unifaat
    kubectl get pods -n ads-unifaat
    kubectl get svc -n ads-unifaat

### 7. Acesso e testes

Aguardar o LoadBalancer receber endpoint:

    kubectl get svc ads-site-service -n ads-unifaat -w

Salvar endpoint:

    ENDPOINT=$(kubectl get svc ads-site-service -n ads-unifaat -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo "URL: http://$ENDPOINT"

Testar com curl:

    curl -s http://$ENDPOINT | head -10

Abrir no navegador:

    http://ENDPOINT_DO_LOADBALANCER

### 8. Teste de escalabilidade e resiliência

Escalar para 3 réplicas:

    kubectl scale deployment ads-site -n ads-unifaat --replicas=3
    kubectl get pods -n ads-unifaat

Voltar para 2 réplicas:

    kubectl scale deployment ads-site -n ads-unifaat --replicas=2
    kubectl get pods -n ads-unifaat

Testar self-healing:

    POD_NAME=$(kubectl get pods -n ads-unifaat -o jsonpath='{.items[0].metadata.name}')
    echo "Deletando pod: $POD_NAME"
    kubectl delete pod $POD_NAME -n ads-unifaat
    kubectl get pods -n ads-unifaat -w

### 9. Limpeza dos recursos

Remover recursos Kubernetes:

    kubectl delete -f service.yaml
    kubectl delete -f deployment.yaml
    kubectl delete namespace ads-unifaat

Remover Node Group:

    aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes
    aws eks wait nodegroup-deleted --cluster-name $CLUSTER_NAME --nodegroup-name ads-app-nodes

Remover cluster EKS:

    aws eks delete-cluster --name $CLUSTER_NAME
    aws eks wait cluster-deleted --name $CLUSTER_NAME

Remover VPC:

    aws cloudformation delete-stack --stack-name eks-vpc-ads
    aws cloudformation wait stack-delete-complete --stack-name eks-vpc-ads

Remover IAM Roles:

    aws iam detach-role-policy --role-name EKSClusterRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
    aws iam delete-role --role-name EKSClusterRole-ADS
    aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
    aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    aws iam detach-role-policy --role-name EKSNodeRole-ADS --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
    aws iam delete-role --role-name EKSNodeRole-ADS

Remover repositório ECR:

    aws ecr delete-repository --repository-name $REPO_NAME --region $AWS_REGION --force

Limpeza Docker local:

    docker rmi ads-unifaat-site:$IMAGE_TAG
    docker rmi $REPO_URI:$IMAGE_TAG
    docker system prune -f

Verificação final:

    echo "=== Verificação Final ==="
    echo "Clusters EKS:"
    aws eks list-clusters --region $AWS_REGION
    echo "Repositórios ECR:"
    aws ecr describe-repositories --region $AWS_REGION 2>/dev/null || echo "Nenhum"
    echo "Stacks CloudFormation:"
    aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query 'StackSummaries[].StackName'
    echo "=== Limpeza Concluída ==="

---

## Descrição das evidências coletadas

### Parte 1: Construção e Teste Local

- 01-docker-build.png: evidencia o comando docker build --no-cache -t ads-unifaat-site:v1.0 . executado com sucesso.
- 02-teste-local-curl.png: evidencia o comando curl -s http://localhost:3000 | head -5 retornando o HTML da página.
- 03-docker-images.png: evidencia a imagem ads-unifaat-site:v1.0 listada localmente.

### Parte 2: Publicação no ECR

- 04-ecr-login.png: evidencia o login no ECR com a mensagem Login Succeeded.
- 05-ecr-push.png: evidencia o push da imagem para o ECR, com upload dos layers.
- 06-ecr-describe-images.png: evidencia a imagem publicada no ECR com a tag v1.0.

### Parte 3: Cluster EKS e Deploy

- 07-eks-active.png: evidencia o cluster cluster-eks-ads com status ACTIVE.
- 08-nodes-ready.png: evidencia 2 Worker Nodes com status Ready.
- 09-deployments.png: evidencia o Deployment no namespace ads-unifaat com 2/2 réplicas disponíveis.
- 10-pods-running.png: evidencia 2 pods com status Running.
- 11-service-loadbalancer.png: evidencia o Service ads-site-service com endpoint externo do LoadBalancer.

### Parte 4: Acesso e Testes

- 12-curl-endpoint.png: evidencia acesso à aplicação via curl usando o endpoint do LoadBalancer.
- 13-browser-loadbalancer.png: evidencia a aplicação aberta no navegador com a URL do LoadBalancer visível.
- 14-self-healing.png: evidencia a exclusão de um pod e a recriação automática feita pelo Kubernetes.

### Parte 5: Limpeza

- 15-cleanup.png: evidencia a limpeza dos recursos AWS, mostrando que cluster EKS, repositórios ECR e stacks CloudFormation relacionados ao lab foram removidos.

---

## Observações sobre erros ou diferenças encontradas durante a execução

Durante a execução, podem ocorrer diferenças relacionadas ao Account ID da AWS, tempo de criação do cluster EKS, tempo para o LoadBalancer receber o endpoint externo e permissões IAM da conta utilizada.

Caso ocorra erro de credenciais AWS, é necessário configurar o AWS CLI antes da execução:

    aws configure
    aws sts get-caller-identity

Caso ocorra erro ImagePullBackOff, é necessário verificar:

- se a imagem foi enviada corretamente ao ECR;
- se a tag v1.0 existe;
- se a IAM Role dos Worker Nodes possui a política AmazonEC2ContainerRegistryReadOnly.

Caso o LoadBalancer fique como pending, é necessário aguardar alguns minutos e repetir:

    kubectl get svc ads-site-service -n ads-unifaat

A limpeza dos recursos AWS foi realizada para evitar custos após a finalização do laboratório.

---

## Entrega no GitHub

Após adicionar o README e os prints:

    git status
    git add "Aula 013/6325192"
    git commit -m "docs: adiciona entrega da Aula 13 EKS"
    git push origin main

Título do Pull Request:

    6325192 - Emar Cristian
EOF
### Observação adicional da execução

Durante a criação do Node Group, o tipo de instância `t3.medium` falhou porque a conta AWS utilizada permitia apenas instâncias elegíveis ao Free Tier. O erro retornado foi `The specified instance type is not eligible for Free Tier`.

Para concluir o laboratório, o Node Group foi recriado usando `t3.micro`, mantendo 2 nodes no cluster. Após essa alteração, os nodes ficaram com status `Ready` e o deploy foi concluído com sucesso.

Durante o cleanup, a stack `eks-vpc-ads` apresentou `DELETE_FAILED` inicialmente porque o cluster EKS ainda existia e mantinha dependências nas subnets privadas. Após excluir o cluster EKS, a stack CloudFormation foi removida com sucesso.
