# TF012 - CI/CD Basico e Registro de Imagens (ECR)

RA: 6325149  
Aluno: Gabriel  
Disciplina: Implementacao de servidor e nuvem (cloud)  
Data: 08/06/2026

## Questao 1 - Conceitos de CI/CD (Teorica)

### a) CI (Continuous Integration)
Objetivo principal: integrar mudancas de codigo com frequencia em uma branch principal, executando automaticamente validacoes de qualidade.

Na pratica, o pipeline de CI faz:
- checkout do codigo;
- instalacao de dependencias;
- execucao de testes automatizados;
- analise estatica/lint;
- build do artefato (por exemplo, imagem Docker).

Resultado esperado: detectar erros cedo e manter o codigo sempre integravel.

### b) CD (Continuous Delivery/Deployment)
Objetivo principal: automatizar a entrega do artefato ja buildado para ambientes de homologacao/producao.

No CD, o artefato aprovado no CI segue para:
- publicacao em repositorio (ex.: Amazon ECR);
- deploy em ambiente de destino (ex.: ECS/EKS/EC2);
- validacoes pos-deploy.

Diferenca:
- Continuous Delivery: artefato fica pronto para publicar, geralmente com aprovacao manual para producao.
- Continuous Deployment: publicacao em producao ocorre automaticamente apos passar nas validacoes.

## Questao 2 - Ferramentas de Pipeline (Teorica)

Tres ferramentas/servicos que podem automatizar CI:
- Jenkins
- GitHub Actions
- AWS CodeBuild

Outros exemplos validos: GitLab CI, AWS CodePipeline (orquestracao), CircleCI.

## Questao 3 - Amazon ECR (Teorica)

### a) Vantagem do ECR vs Docker Hub publico
A principal vantagem para aplicacoes privadas e seguranca e o controle de acesso integrado ao IAM da AWS, com repositorios privados por padrao, politicas granulares e melhor integracao com servicos AWS (ECS, EKS, CodeBuild, Lambda com imagem).

Beneficios diretos:
- autenticacao e autorizacao centralizadas com IAM;
- menor exposicao de imagens sensiveis;
- trafego e integracao nativa no ecossistema AWS;
- suporte a scan de vulnerabilidades e criptografia.

### b) ECR e global ou regional + formato do URI
O ECR e regional.

Formato padrao do URI:

`<aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>`

Exemplo:

`123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

## Questao 4 - Processo de Push (Pratica Teorica)

Sequencia correta para enviar imagem local ao ECR:

1. Passo de Autenticacao (AWS CLI + Docker CLI)
	- Gerar token com AWS CLI e autenticar Docker:
	- `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com`

2. Passo de Tagging (Docker CLI)
	- Marcar a imagem local com o URI remoto do ECR:
	- `docker tag <imagem_local>:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>`

3. Passo de Upload (Docker CLI)
	- Enviar os layers para o repositiorio ECR:
	- `docker push <account_id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>`

## Questao 5 - Simulacao AWS CLI + Docker

Valores exigidos no enunciado:
- AWS Account ID: 123456789012
- Regiao: us-east-1
- Repositorio: web-app-repo
- Imagem local: web-app:v1

### a) Criacao do repositorio
```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

### b) Autenticacao (login Docker)
```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### c) Tagging da imagem
```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### d) Push final
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

## Questao 6 - Evidencias Praticas da Execucao do Lab012

As evidencias abaixo seguem o fluxo do Lab012 e podem ser geradas por prints de terminal (txt ou imagem).

## Parte 1 - Preparacao e Configuracao

1. Configuracao AWS
```bash
aws configure list
```
Evidencia esperada: credenciais e regiao configuradas (ocultar dados sensiveis).

2. Login no ECR
```bash
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```
Evidencia esperada: mensagem `Login Succeeded`.

3. Build da imagem Docker
```bash
IMAGE_TAG="v1.0"
docker build -t web-app-v1:$IMAGE_TAG .
```
Evidencia esperada: build concluido com sucesso.

## Parte 2 - Registro e Push da Imagem

1. Criacao e descricao do repositorio
```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

2. Tagging
```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```

3. Verificacao de imagem marcada
```bash
docker images | grep $REPO_URI
```

4. Push para ECR
```bash
docker push $REPO_URI:$IMAGE_TAG
```
Evidencia esperada: upload dos layers.

## Parte 3 - Verificacao Remota e Bonus EKS

1. Verificacao no ECR
```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```
Evidencia esperada: tag da imagem publicada.

2. Bonus EKS (opcional)
```bash
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
curl http://$ENDPOINT
```

## Lista de Comandos Executados (Roteiro Consolidado)

```bash
# 1) Variaveis
AWS_ACCOUNT_ID="SEU_ACCOUNT_ID"
AWS_REGION="sa-east-1"
REPO_NAME="app-frontend"
IMAGE_TAG="v1.0"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

# 2) Build local
docker build -t web-app-v1:$IMAGE_TAG .
docker images | grep web-app-v1

# 3) ECR
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION

# 4) Login
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 5) Tag e push
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI
docker push $REPO_URI:$IMAGE_TAG

# 6) Verificacao final
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].imageTags[0]'
```

## Observacoes

- Se ocorrer `no basic auth credentials` no push, repetir o login Docker no ECR.
- Se ocorrer `repository not found`, criar o repositorio antes do push e confirmar a regiao.
- Se ocorrer erro de permissao IAM, validar politicas ECR no usuario/role.
- Em ambiente Windows/WSL, manter Docker Desktop em execucao antes dos comandos Docker.

## Evidencias Coletadas (Execucao Real)

Diretorio das evidencias:

`Aula 012/6325149/evidencias`

Evidencias exigidas pelo TF012:

Parte 1 - Preparacao e Configuracao

1. Configuracao AWS (`aws configure list`)
- Arquivo: `print01-aws-configure-list.txt`

2. Teste de login no ECR (`Login Succeeded`)
- Arquivo: `print03-ecr-login.txt`

3. Build da imagem Docker (`docker build -t web-app-v1:$IMAGE_TAG .`)
- Arquivo: `print04-docker-build.txt`

Parte 2 - Registro e Push da Imagem

1. Criacao/descricao do repositorio ECR
- Arquivos: `print06-ecr-create-repository.txt` e `print07-ecr-describe-repository.txt`

2. Tagging da imagem
- Arquivo: `print08-docker-tag.txt`

3. Verificacao da imagem local marcada (`docker images | grep $REPO_URI`)
- Arquivo: `print09-docker-images-ecr-tag.txt`

4. Push para o ECR (upload dos layers)
- Arquivo: `print10-docker-push.txt`

Parte 3 - Verificacao Remota e Bonus EKS

1. Verificacao do ECR (`describe-images` mostrando a tag)
- Arquivo: `print11-ecr-describe-images.txt`

2. Bonus EKS
- Nao executado nesta entrega.

Observacao:
- Foram mantidas somente as evidencias obrigatorias descritas no TF012.
