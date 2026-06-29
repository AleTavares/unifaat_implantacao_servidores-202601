# TF012 - Aula 12 - CI/CD Basico e Registro de Imagens no Amazon ECR

## Questao 1: Conceitos de CI/CD

### a) CI (Continuous Integration)

CI, ou Integracao Continua, e a fase em que as alteracoes de codigo sao integradas com frequencia ao repositorio principal. O objetivo e validar rapidamente cada mudanca por meio de testes automatizados, verificacoes de qualidade e build da aplicacao, reduzindo erros de integracao.

No contexto de containers, a etapa de CI normalmente tambem constroi a imagem Docker da aplicacao.

### b) CD (Continuous Delivery/Deployment)

CD, ou Entrega/Implantacao Continua, e a fase em que o artefato gerado no build, como uma imagem Docker, e preparado e enviado para um ambiente de execucao.

Na entrega continua, o artefato fica pronto para ser implantado com aprovacao manual. Na implantacao continua, o deploy ocorre automaticamente apos a validacao do pipeline.

## Questao 2: Ferramentas de Pipeline

Tres ferramentas ou servicos que podem automatizar a fase de CI sao:

- GitHub Actions
- Jenkins
- AWS CodeBuild

Essas ferramentas podem executar testes, validar o codigo, construir a imagem Docker e preparar o artefato para publicacao em um registry como o Amazon ECR.

## Questao 3: Amazon ECR

### a) Vantagem do ECR para aplicacoes privadas

A principal vantagem do Amazon ECR em relacao a um repositorio publico do Docker Hub e a integracao com a seguranca da AWS. O ECR permite controlar acesso por IAM, manter imagens privadas, auditar operacoes e integrar o registry com servicos como ECS, EKS, CodeBuild e CodePipeline.

Isso e mais adequado para aplicacoes privadas, pois evita expor imagens publicamente e permite aplicar permissoes especificas por usuario, role ou servico.

### b) Servico global ou regional e formato do URI

O Amazon ECR e um servico regional. Isso significa que os repositorios sao criados dentro de uma regiao especifica da AWS.

Formato padrao do URI de um repositorio ECR:

```bash
<aws_account_id>.dkr.ecr.<regiao>.amazonaws.com/<nome_do_repositorio>
```

Exemplo:

```bash
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

## Questao 4: Processo de Push

### 1. Passo de Autenticacao

Ferramentas usadas: AWS CLI e Docker CLI.

O comando `aws ecr get-login-password` gera uma senha temporaria para o ECR, que e enviada ao `docker login`.

```bash
aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<regiao>.amazonaws.com
```

### 2. Passo de Tagging

Ferramenta usada: Docker CLI.

A imagem local recebe uma nova tag com o URI completo do repositorio ECR.

```bash
docker tag <imagem_local>:<tag> <aws_account_id>.dkr.ecr.<regiao>.amazonaws.com/<repositorio>:<tag>
```

### 3. Passo de Upload

Ferramenta usada: Docker CLI.

A imagem marcada com o URI do ECR e enviada para o repositorio remoto.

```bash
docker push <aws_account_id>.dkr.ecr.<regiao>.amazonaws.com/<repositorio>:<tag>
```

## Questao 5: Tarefa Pratica Integrada

Valores assumidos:

- ID da Conta AWS: `123456789012`
- Regiao: `us-east-1`
- Nome do Repositorio ECR: `web-app-repo`
- Imagem Local: `web-app:v1`

### a) Criacao do repositorio

```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

### b) Autenticacao no Docker com ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### c) Tagging da imagem

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### d) Push final

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

## Questao 6: Evidencias Praticas da Execucao do Lab012

### Parte 1: Preparacao e Configuracao

Evidencias solicitadas:

1. Configuracao AWS:

```bash
aws configure list
```

Descricao esperada: deve mostrar o profile, a regiao configurada e indicar que as credenciais estao configuradas. Chaves sensiveis devem ser ocultadas no print.

2. Teste de login no ECR:

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Descricao esperada: a saida deve conter `Login Succeeded`.

3. Build da imagem Docker:

```bash
docker build -t web-app-v1:$IMAGE_TAG .
```

Descricao esperada: a saida deve mostrar o build concluido com sucesso e a imagem criada.

### Parte 2: Registro e Push da Imagem

1. Criacao do repositorio ECR:

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
```

2. Descricao do repositorio ECR:

```bash
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

3. Tagging da imagem:

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```

4. Verificacao da imagem local marcada:

```bash
docker images | grep $REPO_URI
```

5. Push para o ECR:

```bash
docker push $REPO_URI:$IMAGE_TAG
```

Descricao esperada: o terminal deve mostrar o upload das layers da imagem para o ECR.

### Parte 3: Verificacao Remota e Bonus EKS

1. Verificacao da imagem no ECR:

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

Descricao esperada: a saida deve mostrar a tag enviada, por exemplo `V1.0`.

2. Bonus EKS, caso executado:

```bash
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
curl http://$ENDPOINT
```

Descricao esperada: os comandos devem mostrar o deployment, pods em execucao, service do tipo LoadBalancer e resposta HTTP da aplicacao.

## Lista de Comandos do Lab012

```bash
mkdir -p ~/aulas_lab/aula012
cd ~/aulas_lab/aula012
```

```bash
IMAGE_TAG="V1.0"
docker build -t web-app-v1:$IMAGE_TAG .
docker images | grep web-app-v1
```

```bash
AWS_ACCOUNT_ID="123123123123"
AWS_REGION="us-east-2"
REPO_NAME="app-frontend"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo "URI do ECR: $REPO_URI"
```

```bash
aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION
```

```bash
aws ecr describe-repositories \
  --repository-names $REPO_NAME \
  --region $AWS_REGION
```

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI
docker push $REPO_URI:$IMAGE_TAG
```

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

## Descricao das Evidencias Anexadas

As evidencias devem ser anexadas na pasta `6325128` junto deste README, quando o laboratorio for executado em ambiente com AWS CLI, Docker e credenciais validas.


## Observacoes

Este README contem as respostas teoricas, os comandos praticos simulados e a lista de evidencias exigidas no TF012.

A execucao real dos comandos AWS/ECR/EKS depende de credenciais AWS validas, Docker em execucao e permissao para criar recursos na nuvem. O bonus de EKS pode gerar custos, pois cria cluster, node group, LoadBalancer, VPC e outros recursos associados.

Caso o laboratorio seja executado em conta AWS real, e importante remover os recursos ao final usando os comandos de limpeza do `Lab012.md`, principalmente EKS, LoadBalancer, ECR, CloudFormation e imagens Docker locais.
