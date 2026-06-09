# TF - Aula 12 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno:** Emar  
**RA:** 6325192  
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)

## Questão 1 - Conceitos de CI/CD

### a) CI

CI significa Continuous Integration. O objetivo principal é integrar frequentemente as alterações de código em um repositório central, executando validações automáticas como testes e build da aplicação.

### b) CD

CD significa Continuous Delivery ou Continuous Deployment. O objetivo é entregar ou implantar o artefato gerado no build em um ambiente de teste, homologação ou produção.

## Questão 2 - Ferramentas de Pipeline

Três ferramentas que podem automatizar CI são:

- Jenkins
- GitHub Actions
- AWS CodeBuild

## Questão 3 - Amazon ECR

### a)

A principal vantagem do ECR é armazenar imagens Docker privadas com segurança, integradas ao IAM da AWS, permitindo controle de acesso e evitando exposição pública da aplicação.

### b)

O Amazon ECR é um serviço regional.

### Formato padrão:
ID_DA_CONTA.dkr.ecr.REGIAO.amazonaws.com/NOME_DO_REPOSITORIO

Exemplo:

`123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

### Questão 4 - Processo de Push
Autenticação: usar AWS CLI com aws ecr get-login-password e fazer login no Docker.
Tagging: usar docker tag para marcar a imagem local com o URI do ECR.
Upload: usar docker push para enviar a imagem para o ECR.

### Questão 5 - Simulação dos Comandos
### a) Criação do repositório
aws ecr create-repository --repository-name web-app-repo --region us-east-1

### b) Autenticação
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

### c) Tagging da imagem
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

### d) Push final
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

### Comandos Executados no Lab012:
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

### Evidências / Prints 
![### 01 - aws configure list](image) configuração da AWS CLI.
![### 02 - docker-build](image-1.png) build da imagem Docker local.
![### 03 - create-repository](image.png) tentativa de criação do repositório ECR.
![### 04-describe-repository](image.png) descrição do repositório ECR criado/existente.
![### 05 - login-ecr](image.png) autenticação Docker no ECR com Login Succeeded.
![### 06 - tagged-image](image.png) imagem local marcada com o URI do ECR.
![### 07 - docker-push](image.png) push da imagem Docker para o ECR.
![### 08 - describe-images](image.png) verificação da imagem armazenada no ECR.

### Observações

O repositório app-frontend já existia na conta AWS, por isso o comando de criação retornou RepositoryAlreadyExistsException. O laboratório foi concluído normalmente utilizando o repositório existente.

O bônus com EKS não foi executado, pois era opcional e poderia gerar custos adicionais na AWS.

