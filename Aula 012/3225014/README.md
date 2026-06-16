# TF - Tarefa Final - Aula 12

Obs: Tive problemas com a instalação do aws cli, pedi a ajuda para a execução dos comandos para meu colega.

## Disciplina: Implementação de Servidor e Nuvem (Cloud)

## Aula: 12 - CI/CD Básico e Registro de Imagens (ECR)

---

# Questão 1 - Conceitos de CI/CD

## a) CI (Continuous Integration)

A Integração Contínua (CI) tem como objetivo integrar frequentemente as alterações de código realizadas pelos desenvolvedores em um repositório central. Durante essa fase são executados processos automáticos como compilação, validação e testes, garantindo que novas alterações não introduzam erros na aplicação.

## b) CD (Continuous Delivery/Deployment)

A Entrega Contínua (CD) tem como objetivo automatizar a disponibilização dos artefatos gerados na fase de CI. Após a construção da aplicação e geração da imagem Docker, o artefato é publicado em ambientes de homologação ou produção de forma automatizada, reduzindo erros manuais e acelerando as entregas.

---

# Questão 2 - Ferramentas de Pipeline

Três ferramentas utilizadas para automatizar a fase de CI são:

1. Jenkins
2. GitHub Actions
3. AWS CodeBuild

Outras ferramentas possíveis incluem GitLab CI/CD, CircleCI e AWS CodePipeline.

---

# Questão 3 - Amazon ECR

## a) Vantagem do ECR

A principal vantagem do Amazon ECR é permitir o armazenamento seguro de imagens Docker privadas dentro da infraestrutura AWS, utilizando autenticação integrada com IAM, controle de acesso granular e comunicação segura.

Diferentemente de um repositório público, as imagens podem permanecer restritas à organização, aumentando a segurança da aplicação.

## b) Regionalidade e formato do URI

O Amazon ECR é um serviço regional.

Formato padrão:

```text
<ID_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<NOME_REPOSITORIO>
```

Exemplo:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

---

# Questão 4 - Processo de Push para o ECR

## 1. Passo de Autenticação

Ferramentas utilizadas:

* AWS CLI
* Docker CLI

Comando:

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
123456789012.dkr.ecr.us-east-1.amazonaws.com
```

Objetivo:
Autenticar o Docker no repositório ECR.

---

## 2. Passo de Tagging

Ferramenta utilizada:

* Docker CLI

Comando:

```bash
docker tag web-app:v1 \
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

Objetivo:
Associar a imagem local ao URI do repositório ECR.

---

## 3. Passo de Upload

Ferramenta utilizada:

* Docker CLI

Comando:

```bash
docker push \
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

Objetivo:
Enviar a imagem para o repositório ECR.

---

# Questão 5 - Simulação dos Comandos

## a) Criação do Repositório

```bash
aws ecr create-repository \
--repository-name web-app-repo \
--region us-east-1
```

---

## b) Autenticação (Login Docker)

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
123456789012.dkr.ecr.us-east-1.amazonaws.com
```

---

## c) Tagging da Imagem

```bash
docker tag web-app:v1 \
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## d) Push Final

```bash
docker push \
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

# Questão 6 - Evidências Práticas

## Parte 1 - Preparação e Configuração

### Evidência 1 - Configuração AWS

Arquivo:

```text
prints/aws-configure-list.png
```

Descrição:

Resultado do comando:

```bash
aws configure list
```

Mostrando credenciais e região configuradas.

---

### Evidência 2 - Login no ECR

Arquivo:

```text
prints/ecr-login.png
```

Descrição:

Resultado do comando:

```bash
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS \
--password-stdin \
$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Com a mensagem:

```text
Login Succeeded
```

---

### Evidência 3 - Build da Imagem

Arquivo:

```text
prints/docker-build.png
```

Descrição:

Execução do comando:

```bash
docker build -t web-app-v1:$IMAGE_TAG .
```

Com conclusão bem-sucedida do build.

---

## Parte 2 - Registro e Push

### Evidência 4 - Criação do Repositório

Arquivo:

```text
prints/ecr-create-repository.png
```

Descrição:

Execução dos comandos:

```bash
aws ecr create-repository \
--repository-name $REPO_NAME \
--region $AWS_REGION
```

e

```bash
aws ecr describe-repositories \
--repository-names $REPO_NAME \
--region $AWS_REGION
```

---

### Evidência 5 - Tagging

Arquivo:

```text
prints/docker-tag.png
```

Descrição:

Execução do comando:

```bash
docker tag web-app-v1:$IMAGE_TAG \
$REPO_URI:$IMAGE_TAG
```

---

### Evidência 6 - Verificação Local

Arquivo:

```text
prints/docker-images.png
```

Descrição:

Resultado do comando:

```bash
docker images | grep $REPO_URI
```

Mostrando a imagem marcada corretamente.

---

### Evidência 7 - Push para o ECR

Arquivo:

```text
prints/docker-push.png
```

Descrição:

Execução do comando:

```bash
docker push $REPO_URI:$IMAGE_TAG
```

Mostrando o upload dos layers para o ECR.

---

## Parte 3 - Verificação Remota

### Evidência 8 - Verificação da Imagem no ECR

Arquivo:

```text
prints/ecr-describe-images.png
```

Descrição:

Execução do comando:

```bash
aws ecr describe-images \
--repository-name $REPO_NAME \
--region $AWS_REGION \
--query 'imageDetails[].imageTags[0]'
```

Mostrando a tag armazenada no repositório.

---

## Bônus EKS (Opcional)

### Evidência 9 - Deploy

Arquivos:

```text
prints/eks-deployments.png
prints/eks-pods.png
prints/eks-service.png
prints/eks-curl.png
```

Comandos executados:

```bash
kubectl get deployments -n app-frontend
```

```bash
kubectl get pods -n app-frontend
```

```bash
kubectl get svc app-frontend-service -n app-frontend
```

```bash
curl http://$ENDPOINT
```

---

# Lista de Comandos Executados

```bash
aws configure list

aws ecr create-repository --repository-name web-app-repo --region us-east-1

aws ecr describe-repositories --repository-names web-app-repo --region us-east-1

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

docker build -t web-app-v1:$IMAGE_TAG .

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

docker images

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

aws ecr describe-images --repository-name web-app-repo --region us-east-1
```

---

# Observações

Durante a execução do laboratório não foram identificados erros críticos.

Caso ocorram erros de autenticação no ECR, recomenda-se verificar:

* Configuração do AWS CLI.
* Permissões IAM.
* Região configurada.
* Existência do repositório ECR.
* Login válido do Docker no ECR.

Todos os testes foram realizados seguindo o fluxo de CI/CD apresentado na aula.
    