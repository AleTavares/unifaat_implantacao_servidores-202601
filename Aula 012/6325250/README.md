# Tarefa Final - Aula 12

Disciplina: Implementacao de servidor e nuvem (cloud)  
Aula: 12 - CI/CD Basico e Registro de Imagens (ECR)  
RA: 6325250

## Questao 1: Conceitos de CI/CD

### a) CI (Continuous Integration)

CI, ou Integracao Continua, e a fase em que o codigo desenvolvido e integrado com frequencia ao repositorio principal. A cada alteracao, o pipeline pode executar testes, validacoes e build da aplicacao, incluindo a criacao da imagem Docker. O objetivo principal e identificar erros rapidamente e garantir que o codigo continue funcionando antes de seguir para as proximas etapas.

### b) CD (Continuous Delivery/Deployment)

CD e a fase em que o artefato gerado na CI, como uma imagem Docker, e preparado para entrega ou implantacao em um ambiente.

Na Continuous Delivery, o artefato fica pronto para deploy, mas a publicacao pode depender de uma aprovacao manual.

Na Continuous Deployment, o artefato aprovado e implantado automaticamente no ambiente configurado, como homologacao ou producao.

## Questao 2: Ferramentas de Pipeline

Tres ferramentas ou servicos que podem automatizar a fase de CI sao:

- GitHub Actions
- GitLab CI/CD
- AWS CodeBuild

Essas ferramentas podem executar testes automatizados, comandos de build e construcao de imagens Docker.

## Questao 3: Amazon ECR

### a) Vantagem do ECR

A principal vantagem de usar o Amazon ECR em vez de um repositorio publico no Docker Hub e a seguranca para imagens privadas. O ECR permite controlar acesso com IAM, manter imagens privadas, usar criptografia e integrar diretamente com outros servicos da AWS, como ECS, EKS, CodeBuild e CodePipeline.

### b) Servico global ou regional

O Amazon ECR e um servico regional. Isso significa que o repositorio e criado dentro de uma regiao especifica da AWS.

Formato padrao do URI de um repositorio ECR:

```bash
<ID_DA_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<NOME_DO_REPOSITORIO>
```

Exemplo:

```bash
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

## Questao 4: Processo de Push

O envio de uma imagem Docker local para o Amazon ECR segue tres passos principais.

### 1. Passo de Autenticacao

Ferramentas usadas: AWS CLI e Docker CLI.

Primeiro, a AWS CLI gera uma senha temporaria de login do ECR. Em seguida, essa senha e enviada para o Docker fazer login no registry privado da AWS.

```bash
aws ecr get-login-password --region <REGIAO> | docker login --username AWS --password-stdin <ID_DA_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com
```

### 2. Passo de Tagging

Ferramenta usada: Docker CLI.

Depois, a imagem local recebe uma nova tag com o URI completo do repositorio ECR. Isso indica ao Docker para qual registry a imagem sera enviada.

```bash
docker tag <IMAGEM_LOCAL>:<TAG> <URI_ECR>:<TAG>
```

### 3. Passo de Upload

Ferramenta usada: Docker CLI.

Por fim, a imagem marcada com o URI do ECR e enviada para o repositorio remoto.

```bash
docker push <URI_ECR>:<TAG>
```

## Questao 5: Tarefa Pratica Integrada

Valores usados na simulacao:

- ID da Conta AWS: `123456789012`
- Regiao: `us-east-1`
- Nome do Repositorio ECR: `web-app-repo`
- Imagem Local: `web-app:v1`

### a) Criacao do repositorio

```bash
aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

### b) Autenticacao Login Docker

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

As evidencias foram organizadas na pasta `prints`, dentro do diretorio do RA.

## Comandos executados no Lab012

### 1. Criar diretorio de trabalho

```bash
mkdir -p ~/aulas_lab/aula012
cd ~/aulas_lab/aula012
```

### 2. Criar Dockerfile

```Dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 3. Definir variaveis

Substituir o ID da conta pelo ID real da conta AWS.

```bash
IMAGE_TAG="V1.0"
AWS_ACCOUNT_ID="SEU_ID_DA_CONTA"
AWS_REGION="us-east-2"
REPO_NAME="app-frontend"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo "URI do ECR: $REPO_URI"
```

### 4. Verificar configuracao da AWS CLI

```bash
aws configure list
```

### 5. Build da imagem Docker

```bash
docker build -t web-app-v1:$IMAGE_TAG .
docker images | grep web-app-v1
```

### 6. Criar repositorio no ECR

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

### 7. Fazer login do Docker no ECR

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### 8. Fazer tagging da imagem

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI
```

### 9. Enviar imagem para o ECR

```bash
docker push $REPO_URI:$IMAGE_TAG
```

### 10. Verificar imagem no ECR

```bash
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].imageTags[0]'
```

Não foi possivel configurar com a conta da aws
```
