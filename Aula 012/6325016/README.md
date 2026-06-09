# TF - Aula 12 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno:** Caroline   
**RA:** 6325016
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)

## Questão 1 - Conceitos de CI/CD

### a) CI

CI (Continuous Integration) tem como objetivo integrar o código e executar testes e builds automáticos.

### b) CD

CD (Continuous Delivery/Deployment) tem como objetivo entregar ou implantar a aplicação gerada pelo build.

## Questão 2 - Ferramentas de Pipeline

* Jenkins
* GitHub Actions
* AWS CodeBuild

## Questão 3 - Amazon ECR

### a)

O ECR permite armazenar imagens Docker privadas com mais segurança e controle de acesso.

### b)

O Amazon ECR é um serviço regional.

Formato do URI:

`ID_DA_CONTA.dkr.ecr.REGIAO.amazonaws.com/NOME_DO_REPOSITORIO`

Exemplo:

`123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

## Questão 4 - Processo de Push

1. Autenticação: usar `aws ecr get-login-password` para fazer login no Docker.
2. Tagging: usar `docker tag` para associar a imagem ao ECR.
3. Upload: usar `docker push` para enviar a imagem ao ECR.

## Questão 5 - Simulação dos Comandos

### a) Criação do repositório

```bash
aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

### b) Autenticação

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

## Comandos Executados no Lab012

```bash
aws configure list
aws sts get-caller-identity
docker build -t web-app-v1:v1.0 .
aws ecr create-repository --repository-name app-frontend --region us-east-2
aws ecr describe-repositories --repository-names app-frontend --region us-east-2
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 285034435871.dkr.ecr.us-east-2.amazonaws.com
docker tag web-app-v1:v1.0 285034435871.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0
docker images | grep 285034435871.dkr.ecr.us-east-2.amazonaws.com/app-frontend
docker push 285034435871.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0
aws ecr describe-images --repository-name app-frontend --region us-east-2 --query 'imageDetails[].imageTags[0]'
```

## Observações

O repositório `app-frontend` já existia na AWS, então foi utilizado normalmente.

O bônus com EKS não foi executado por ser opcional.


