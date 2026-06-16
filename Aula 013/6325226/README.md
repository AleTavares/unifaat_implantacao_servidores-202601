# TF - Aula 13 - Deploy de Containers na AWS com EKS

**Aluno:** Lucas Kenway
**RA:** 6325226

---

# Questão 1 - Conceitos de Kubernetes e EKS

## a) Qual é a diferença entre o Control Plane e os Worker Nodes em um cluster EKS? Quem gerencia cada um?

O Control Plane é responsável pelo gerenciamento do cluster Kubernetes. Ele controla o agendamento dos pods, monitora o estado dos recursos e mantém o ambiente funcionando corretamente.

No Amazon EKS, o Control Plane é gerenciado pela AWS.

Os Worker Nodes são as máquinas responsáveis por executar os containers da aplicação. Eles hospedam os pods e processam as cargas de trabalho do cluster. Os Worker Nodes são administrados pelo usuário ou por Node Groups gerenciados.

## b) Explique o conceito de self-healing no Kubernetes. O que acontece quando um pod falha?

Self-healing é a capacidade do Kubernetes de corrigir automaticamente falhas na aplicação.

Quando um pod falha, o Kubernetes detecta o problema e cria automaticamente um novo pod para substituir o que foi perdido, mantendo a quantidade de réplicas definida no Deployment.

---

# Questão 2 - Objetos Kubernetes

## a) Qual é a diferença entre um Deployment e um Service no Kubernetes?

### Deployment

O Deployment é responsável por criar, atualizar e gerenciar os pods da aplicação.

Funções principais:

* Controlar a quantidade de réplicas.
* Realizar atualizações.
* Executar rollback quando necessário.
* Garantir disponibilidade da aplicação.

### Service

O Service fornece uma forma estável de acesso aos pods.

Funções principais:

* Expor a aplicação.
* Balancear tráfego.
* Permitir comunicação entre componentes.

## b) Explique o que são Labels e Selectors e como eles conectam um Service aos Pods corretos.

Labels são identificadores atribuídos aos recursos Kubernetes.

Exemplo:

```yaml
labels:
  app: web-app
```

Selectors são filtros utilizados para localizar recursos que possuem determinadas labels.

Exemplo:

```yaml
selector:
  app: web-app
```

O Service utiliza os Selectors para localizar os Pods corretos e encaminhar as requisições para eles.

## c) Qual é a função das Probes (livenessProbe e readinessProbe)? Dê um exemplo prático de quando cada uma é útil.

### Liveness Probe

Verifica se a aplicação continua funcionando corretamente.

Se falhar, o Kubernetes reinicia o container.

Exemplo: aplicação travada e sem responder requisições.

### Readiness Probe

Verifica se a aplicação está pronta para receber tráfego.

Se falhar, o pod permanece em execução, porém não recebe novas requisições.

Exemplo: aplicação ainda carregando dependências durante a inicialização.

---

# Questão 3 - IAM e Permissões

## a) Por que o cluster EKS precisa de uma IAM Role própria (EKSClusterRole)? Que tipo de ações essa role permite?

A EKSClusterRole permite que o serviço EKS gerencie recursos necessários para o funcionamento do cluster.

Essa role permite ações relacionadas a:

* EC2
* Rede VPC
* Security Groups
* Load Balancers
* Comunicação entre serviços AWS

Sem essa role o cluster não consegue operar corretamente.

## b) Por que os Worker Nodes precisam da política AmazonEC2ContainerRegistryReadOnly? O que acontece se essa política não estiver anexada?

Essa política permite que os Worker Nodes baixem imagens armazenadas no Amazon ECR.

Sem essa permissão:

* As imagens não podem ser baixadas.
* Os containers não iniciam.
* Os pods entram em estado ImagePullBackOff ou ErrImagePull.

---

# Questão 4 - Networking e Exposição

## a) Qual a diferença entre os tipos de Service ClusterIP, NodePort e LoadBalancer no Kubernetes?

### ClusterIP

Permite acesso apenas dentro do cluster Kubernetes.

### NodePort

Expõe a aplicação através de uma porta específica dos Worker Nodes.

### LoadBalancer

Cria um balanceador de carga externo e fornece acesso público à aplicação.

## b) O que acontece na AWS quando você cria um Service do tipo LoadBalancer? Qual recurso AWS é provisionado automaticamente?

Quando um Service do tipo LoadBalancer é criado, a AWS provisiona automaticamente um Elastic Load Balancer (ELB).

Esse Load Balancer recebe as requisições externas e distribui o tráfego entre os pods da aplicação.

## c) Por que é importante deletar o Service LoadBalancer antes de deletar o cluster EKS?

Porque o Load Balancer é um recurso separado do cluster.

Caso o cluster seja removido antes do Service, o Load Balancer pode permanecer ativo e gerar custos desnecessários na conta AWS.

---

# Questão 5 - Tarefa Prática - Comandos EKS

## a) Criar o namespace

```bash
kubectl create namespace minha-app
```

## b) Criar um Deployment com 3 réplicas

```yaml
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
```

Aplicação:

```bash
kubectl apply -f deployment.yaml
```

## c) Expor a aplicação ao mundo com um Service LoadBalancer

```yaml
apiVersion: v1
kind: Service

metadata:
  name: web-app-service
  namespace: minha-app

spec:
  type: LoadBalancer

  selector:
    app: web-app

  ports:
  - port: 80
    targetPort: 3000
```

Aplicação:

```bash
kubectl apply -f service.yaml
```

## d) Escalar o deployment de 3 para 5 réplicas

```bash
kubectl scale deployment web-app --replicas=5 -n minha-app
```

## e) Verificar pods e obter endpoint

```bash
kubectl get pods -n minha-app

kubectl get deployments -n minha-app

kubectl get svc -n minha-app

kubectl get all -n minha-app
```

---

# Lista dos Comandos Executados no Lab013

```bash
docker build --no-cache -t ads-unifaat-site:v1.0 .

docker run -d --name ads-site -p 3000:80 ads-unifaat-site:v1.0

curl -s http://localhost:3000 | head -5

docker images | grep ads-unifaat

aws ecr create-repository --repository-name ads-unifaat-site --region us-east-2

aws ecr get-login-password --region us-east-2

docker login

docker tag ads-unifaat-site:v1.0

docker push

aws ecr describe-images

kubectl get nodes

kubectl get deployments -n ads-unifaat

kubectl get pods -n ads-unifaat

kubectl get svc -n ads-unifaat
```

---

# Evidências Coletadas

## Print 1

Build da imagem Docker com sucesso.

## Print 2

Teste local utilizando curl mostrando o HTML da aplicação.

## Print 3

Listagem da imagem Docker criada.

## Print 4

Criação do repositório ECR.

## Print 5

Login no Amazon ECR com mensagem "Login Succeeded".

## Print 6

Push da imagem para o Amazon ECR.

## Print 7

Verificação da imagem publicada no ECR.

---

# Observações

Durante a execução do laboratório ocorreu um problema inicial de autenticação na AWS CLI relacionado às credenciais de acesso. Após a atualização das credenciais, foi possível realizar o login, criar o repositório ECR, construir a imagem Docker e prosseguir com a atividade normalmente.

Todos os recursos criados deverão ser removidos ao final da atividade para evitar cobranças na conta AWS.
