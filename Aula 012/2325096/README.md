# TF012 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno:** Seu Nome
**RA:** Seu RA

# Questão 1 - Conceitos de CI/CD

## a) CI (Continuous Integration)

Continuous Integration é a etapa onde o código desenvolvido pelos programadores é integrado frequentemente em um repositório central. Nessa fase são executados testes automáticos, validações e builds para verificar se o código está funcionando corretamente.

## b) CD (Continuous Delivery/Deployment)

Continuous Delivery/Deployment é a etapa responsável por disponibilizar o artefato gerado no processo de CI para ambientes de teste, homologação ou produção de forma automatizada ou semiautomatizada.

# Questão 2 - Ferramentas de Pipeline

Três ferramentas que podem ser utilizadas para CI:

1. Jenkins
2. GitHub Actions
3. AWS CodeBuild

# Questão 3 - Amazon ECR

## a)

A principal vantagem do Amazon ECR é permitir o armazenamento seguro de imagens privadas integrado ao IAM da AWS, oferecendo controle de acesso, autenticação e integração com outros serviços da nuvem.

## b)

O Amazon ECR é um serviço regional.

Formato do URI:

123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo

# Questão 4 - Processo de Push

## Passo de Autenticação

Obter o token de autenticação e realizar login:

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

## Passo de Tagging

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

## Passo de Upload

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

# Questão 5 - Simulação dos Comandos

## a) Criação do Repositório

aws ecr create-repository --repository-name web-app-repo --region us-east-1

## b) Autenticação

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

## c) Tagging

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

## d) Push

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

# Questão 6 - Evidências

## Evidência 1 - Build da Imagem Docker

Comando executado:

docker build -t web-app-v1:V1.0 .

Resultado:
Imagem Docker criada com sucesso utilizando nginx:alpine como base.

## Evidência 2 - Verificação da Imagem

Comando executado:

docker images | grep web-app-v1

Resultado obtido:

web-app-v1:V1.0

## Observações

Foi possível realizar a preparação do ambiente Docker, criação do Dockerfile, build da imagem e validação da imagem local.

Não foi possível concluir a integração com a AWS ECR devido à ausência da configuração completa da AWS CLI e das credenciais necessárias para autenticação e execução dos comandos do laboratório.

