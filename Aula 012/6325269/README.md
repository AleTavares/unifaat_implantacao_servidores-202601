# TF012 — Respostas (Questões 1 a 5)

**RA:** 6325269  
**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Aula:** 12 — CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD (Teórica)

**a) CI (Continuous Integration):** O objetivo principal da Integração Contínua é integrar alterações de código com frequência e validá-las automaticamente. Sempre que há *commit* ou *merge*, o pipeline executa *build*, testes e verificações de qualidade. O código é compilado/construído e testado de forma contínua, detectando erros de integração o mais cedo possível.

**b) CD (Continuous Delivery/Deployment):** O objetivo principal da Entrega/Implantação Contínua é levar o artefato já *buildado* (por exemplo, uma imagem Docker) até os ambientes de destino. O artefato é publicado, implantado ou disponibilizado de forma automatizada e repetível, reduzindo intervenção manual no deploy.

---

## Questão 2: Ferramentas de Pipeline (Teórica)

Três ferramentas ou serviços que automatizam a fase de **CI**, executando testes e *build* da imagem Docker:

1. **AWS CodeBuild** — serviço gerenciado da AWS que compila, testa e gera artefatos, incluindo imagens Docker.
2. **Jenkins** — ferramenta de código aberto que executa pipelines de build, testes e integração.
3. **GitHub Actions** — serviço de CI/CD integrado ao GitHub que dispara workflows para testar o código e construir imagens Docker.

---

## Questão 3: Amazon ECR (Teórica)

**a)** A principal vantagem do ECR em relação ao Docker Hub público, para uma aplicação privada, é o controle de acesso e a segurança: o repositório é privado por padrão, integrado ao IAM da AWS, com criptografia em repouso e em trânsito, scan de vulnerabilidades e integração nativa com serviços AWS (EKS, ECS). As imagens não ficam expostas publicamente.

**b)** O ECR é um serviço **regional** — cada repositório existe em uma região específica da AWS.

Formato padrão do URI:

```
{account-id}.dkr.ecr.{region}.amazonaws.com/{repository-name}
```

Exemplo:

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

---

## Questão 4: Processo de Push (Prática Teórica)

1. **Passo de Autenticação (AWS CLI + Docker CLI):** Obter o token temporário com `aws ecr get-login-password` e autenticar o Docker via `docker login --username AWS --password-stdin` no endpoint do ECR.

2. **Passo de Tagging (Docker CLI):** Marcar a imagem local com o URI completo do repositório ECR usando `docker tag`, associando o nome local ao endereço remoto.

3. **Passo de Upload (Docker CLI):** Enviar a imagem marcada para o registry remoto com `docker push`, fazendo o upload das *layers* para o ECR.

---

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI e Docker)

**a) Criação do Repositório:**

```bash
aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

**b) Autenticação (Login Docker):**

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

**c) Tagging da Imagem:**

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

**d) Push Final:**

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```
