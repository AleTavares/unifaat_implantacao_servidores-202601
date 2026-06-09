# TF - Aula 12 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno:** Claudio Luiz Pereirda da Silva Neto
**RA:** 6325101
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)
**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

# Questão 1 – Conceitos de CI/CD

## a) CI (Continuous Integration)

A Integração Contínua (CI) tem como objetivo integrar frequentemente as alterações de código realizadas pelos desenvolvedores em um repositório central.

Durante essa fase:

* O código é enviado para o repositório.
* Testes automatizados são executados.
* O código é validado.
* É realizado o processo de build para geração do artefato ou imagem.

## b) CD (Continuous Delivery/Deployment)

A Entrega Contínua (CD) tem como objetivo automatizar a disponibilização do artefato gerado na fase de CI.

Durante essa fase:

* O artefato é armazenado em um repositório.
* Pode ser implantado em ambientes de teste ou produção.
* O deploy pode ser manual (Continuous Delivery) ou automático (Continuous Deployment).

---

# Questão 2 – Ferramentas de Pipeline

Três ferramentas que podem ser utilizadas para automatizar a fase de Continuous Integration são:

1. Jenkins
2. GitHub Actions
3. AWS CodeBuild

---

# Questão 3 – Amazon ECR

## a) Vantagem do ECR

A principal vantagem do Amazon ECR é a integração nativa com os serviços AWS e o controle de acesso através do IAM.

Benefícios:

* Repositórios privados.
* Controle de permissões.
* Criptografia.
* Integração com ECS, EKS e CodePipeline.
* Maior segurança para aplicações corporativas.

## b) Serviço Regional e URI

O Amazon ECR é um serviço regional.

Formato padrão do URI:

<ID_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<NOME_REPOSITORIO>

Exemplo:

123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo

---

# Questão 4 – Processo de Push

## Passo de Autenticação

Ferramentas utilizadas:

* AWS CLI
* Docker CLI

Comando:

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ID_CONTA>.dkr.ecr.us-east-1.amazonaws.com

## Passo de Tagging

Ferramenta utilizada:

* Docker CLI

Comando:

docker tag web-app:v1 <ID_CONTA>.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

## Passo de Upload

Ferramenta utilizada:

* Docker CLI

Comando:

docker push <ID_CONTA>.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

---

# Questão 5 – Simulação com AWS CLI e Docker

## a) Criação do Repositório

aws ecr create-repository --repository-name web-app-repo --region us-east-1

## b) Autenticação

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

## c) Tagging da Imagem

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

## d) Push Final

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

---

# Questão 6 – Evidências Práticas

## Parte 1 – Preparação e Configuração

### Evidência 1 – Configuração AWS

Comando executado:

aws configure list

Arquivo:
01-aws-configure-list.png

---

### Evidência 2 – Build da Imagem Docker

Comando executado:

docker build -t web-app-v1:v1.0 .

Arquivo:
02-build-imagem.png

---

### Evidência 3 – Verificação da Imagem

Comando executado:

docker images | grep web-app-v1

Arquivo:
03-docker-images.png

---

## Parte 2 – Registro e Push da Imagem

### Evidência 4 – Criação do Repositório ECR

Comando executado:

aws ecr create-repository --repository-name app-frontend --region us-east-2

Arquivo:
04-create-repository.png

---

### Evidência 5 – Descrição do Repositório

Comando executado:

aws ecr describe-repositories --repository-names app-frontend --region us-east-2

Arquivo:
05-describe-repository.png

---

### Evidência 6 – Login no ECR

Comando executado:

aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 990117608299.dkr.ecr.us-east-2.amazonaws.com

Resultado:

Login Succeeded

Arquivo:
06-login-succeeded.png

---

### Evidência 7 – Tagging da Imagem

Comando executado:

docker tag web-app-v1:v1.0 990117608299.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0

Arquivo:
07-tag-imagem.png

---

### Evidência 8 – Verificação da Tag

Comando executado:

docker images | grep app-frontend

Arquivo:
08-verificacao-tag.png

---

### Evidência 9 – Push da Imagem

Comando executado:

docker push 990117608299.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0

Resultado:

Upload realizado com sucesso para o Amazon ECR.

Arquivo:
09-push-ecr.png

---

## Parte 3 – Verificação Remota

### Evidência 10 – Verificação da Imagem no ECR

Comando executado:

aws ecr describe-images --repository-name app-frontend --region us-east-2 --query 'imageDetails[].imageTags[0]'

Resultado:

[
"v1.0"
]

Arquivo:
10-describe-images.png

---

# Lista de Comandos Utilizados

aws configure list ![alt text](image.png)

docker build -t web-app-v1:v1.0 . ![alt text](image-1.png)

docker images | grep web-app-v1 ![alt text](image-2.png)

aws ecr create-repository --repository-name app-frontend --region us-east-2 ![alt text](image-3.png)

aws ecr describe-repositories --repository-names app-frontend --region us-east-2 ![alt text](image-4.png)

aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 990117608299.dkr.ecr.us-east-2.amazonaws.com 

docker tag web-app-v1:v1.0 990117608299.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0

docker images | grep app-frontend ![alt text](image-5.png)

docker push 990117608299.dkr.ecr.us-east-2.amazonaws.com/app-frontend:v1.0 ![alt text](image-6.png)

aws ecr describe-images --repository-name app-frontend --region us-east-2 --query 'imageDetails[].imageTags[0]' ![alt text](image-7.png)

---

# Observações

Durante a execução do laboratório ocorreu uma falha inicial no comando docker push devido à configuração incorreta da variável REPO_URI, que continha um ID de conta AWS inválido.

Após corrigir o valor da variável AWS_ACCOUNT_ID, recriar o REPO_URI e executar novamente o comando docker tag, o push da imagem foi realizado com sucesso para o Amazon ECR.

O upload foi validado através do comando aws ecr describe-images, que retornou a tag v1.0 armazenada no repositório remoto.

