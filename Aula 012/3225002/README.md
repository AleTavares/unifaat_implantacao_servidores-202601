# TF - Tarefa Final - Aula 12

**Aluno:** José Luiz Henrique
**RA:** 3225002
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)
**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD (Teórica)

### a) CI (Continuous Integration)

O objetivo principal da fase de **Continuous Integration (Integração Contínua)** é **integrar continuamente as alterações de código de todos os desenvolvedores em um repositório central e validar essas alterações automaticamente**.

O que acontece com o código:
- Cada commit/push dispara um pipeline automatizado
- O código é **buildado** (compilado/transpilado quando necessário)
- São executados **testes automatizados** (unitários, integração)
- São rodadas verificações de **qualidade de código** (linter, formatador, análise estática)
- Se tudo passa, gera o **artefato** (ex: imagem Docker, JAR, bundle)
- Se algo falha, o time é notificado imediatamente

**Objetivo central:** detectar erros o mais cedo possível, evitar conflitos de merge gigantes, e garantir que o código no `main` esteja sempre em estado funcional.

### b) CD (Continuous Delivery/Deployment)

O objetivo principal da fase de **Continuous Delivery/Deployment (Entrega/Implantação Contínua)** é **automatizar a entrega do artefato buildado para os ambientes (homologação, produção)**.

O que acontece com o artefato buildado:
- O artefato gerado pela fase de CI (ex: imagem Docker no ECR) é **publicado em um registry**
- Em seguida, é **implantado** automaticamente no ambiente alvo:
  - **Continuous Delivery:** deploy pra homologação automático, mas produção exige aprovação manual
  - **Continuous Deployment:** deploy pra produção também é automático após passar nos testes
- Pode envolver atualização de containers (Kubernetes, ECS), invalidação de cache CDN, migrações de banco, etc.

**Objetivo central:** reduzir o tempo entre escrever código e ele estar rodando em produção, com segurança e reprodutibilidade.

---

## Questão 2: Ferramentas de Pipeline (Teórica)

Três ferramentas que podem ser usadas pra automatizar a fase de CI (build da imagem Docker + testes):

1. **GitHub Actions** — solução nativa do GitHub. Pipelines definidos em YAML (`.github/workflows/`), trigger por push/PR. Gratuito pra repos públicos, oferece runners hospedados pelo próprio GitHub. Muito usado pra projetos cloud-native.

2. **GitLab CI/CD** — solução nativa do GitLab. Pipelines em `.gitlab-ci.yml`. Possui runners próprios e suporta múltiplas linguagens. Inclusive tem Container Registry integrado, similar ao ECR.

3. **AWS CodeBuild** — serviço gerenciado da AWS específico pra build e teste. Roda em containers efêmeros, integrado com CodePipeline (orquestrador), CodeCommit (repo), CodeDeploy (deploy) e ECR. Ideal pra fluxos 100% AWS.

**Outras opções comuns (bônus):**
- **Jenkins** — open source clássico, autohospedado, com vasto ecossistema de plugins
- **CircleCI** — SaaS de CI/CD, runners rápidos
- **Bitbucket Pipelines** — solução nativa do Bitbucket (Atlassian)
- **Azure DevOps Pipelines** — equivalente da Microsoft

---

## Questão 3: Amazon ECR (Teórica)

### a) Vantagem do ECR vs Docker Hub público (aplicação privada)

A principal vantagem é a **privacidade + integração nativa com IAM (segurança gerenciada pela AWS)**:

- **Repositórios privados por padrão** — as imagens só ficam acessíveis a quem tem permissão IAM explícita (não há "exposição pública acidental"). Já no Docker Hub público, qualquer pessoa com acesso à internet pode pull a imagem.
- **Autenticação via IAM** — usa as mesmas credenciais AWS (Access Key/IAM Role) que o resto da infraestrutura. Sem precisar gerenciar usuário/senha separados de Docker Hub.
- **Imagens dentro da mesma VPC/região** — reduz latência e custo de transferência (data transfer dentro da AWS é mais barato do que ir até hub.docker.com).
- **Scan de vulnerabilidades automático** — ECR integra com Amazon Inspector pra detectar CVEs nas imagens.
- **Encryption at rest** — KMS encryption automático.
- **Lifecycle policies** — apaga automaticamente imagens antigas/sem uso, controlando custo.
- **Rate limits do Docker Hub** — Docker Hub público tem limites severos de pull anônimo (100 pulls/6h por IP). ECR não tem esse problema.

Em resumo: **pra aplicação privada de produção, ECR é mais seguro, integrado, performático e sem limites de rate**.

### b) ECR é global ou regional? Formato do URI

**ECR é REGIONAL.** Cada repositório existe em uma região AWS específica. Pra usar a mesma imagem em múltiplas regiões, você precisa replicar (ou habilitar replicação cross-region automática do ECR).

**Formato padrão do URI de um repositório ECR:**

```
<aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>
```

**Exemplo concreto** (com os valores do enunciado):

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

Com tag:

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Questão 4: Processo de Push (Prática Teórica)

Os 3 passos pra enviar uma imagem Docker local pro ECR:

### Passo 1 — Autenticação

**Ferramenta:** `aws ecr` (AWS CLI) + `docker login`

Comando combinado (pipe do token AWS direto pro Docker):

```bash
aws ecr get-login-password --region <region> | \
  docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
```

O `get-login-password` gera um token temporário (válido 12h), e o `docker login` consome esse token. Após isso o Docker tá autorizado a fazer push pro ECR.

### Passo 2 — Tagging

**Ferramenta:** `docker tag`

A imagem local precisa receber uma tag adicional com o URI completo do ECR (Docker usa a tag pra saber onde fazer o push):

```bash
docker tag <imagem_local>:<tag_local> <account_id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>
```

Exemplo:

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### Passo 3 — Upload (Push)

**Ferramenta:** `docker push`

Envia a imagem pra o ECR:

```bash
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>
```

Exemplo:

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

O Docker faz upload dos layers (somente os que ainda não estão no registry, aproveitando o cache).

---

## Questão 5: Tarefa Prática Integrada (Simulação)

Valores do enunciado:
- **ID Conta:** `123456789012`
- **Região:** `us-east-1`
- **Repo ECR:** `web-app-repo`
- **Imagem Local:** `web-app:v1`

### a) Criação do Repositório

```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

Resposta JSON esperada contendo o `repositoryUri`: `123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

Pra evitar erro caso já exista, dá pra usar `describe-repositories` primeiro:

```bash
aws ecr describe-repositories --repository-names web-app-repo --region us-east-1 \
  || aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

### b) Autenticação (Login Docker)

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

Saída esperada: `Login Succeeded`

### c) Tagging da Imagem

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### d) Push Final

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

Saída mostra os layers sendo enviados (`Preparing` → `Pushing` → `Pushed`).

---

## Questão 6: Evidências Práticas da Execução do Lab012

> **Nota:** Esta seção contém os comandos executados e descrição dos passos. Os prints/screenshots ficam na pasta `prints/` desta mesma RA (a serem anexados após execução em ambiente AWS/LocalStack + Docker).

### Parte 1: Preparação e Configuração

#### 1. Configuração AWS

```bash
aws configure list
```

Saída esperada (chaves sensíveis ocultadas):

```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************XXXX shared-credentials-file
secret_key     ****************XXXX shared-credentials-file
    region                us-east-1      config-file    ~/.aws/config
```

**Print:** `prints/01-aws-configure-list.png`

#### 2. Teste de login no ECR

```bash
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=123456789012

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Saída esperada: `Login Succeeded`

**Print:** `prints/02-ecr-login-succeeded.png`

#### 3. Build da imagem Docker

```bash
export IMAGE_TAG=v1
docker build -t web-app-v1:$IMAGE_TAG .
```

Saída esperada termina com algo como: `Successfully tagged web-app-v1:v1`

**Print:** `prints/03-docker-build-success.png`

---

### Parte 2: Registro e Push da Imagem

#### 4. Criação/Descrição do Repositório ECR

```bash
export REPO_NAME=web-app-repo
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

**Prints:**
- `prints/04-ecr-create-repository.png` — criação
- `prints/05-ecr-describe-repositories.png` — confirmação com URI

#### 5. Tagging da Imagem

```bash
export REPO_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```

**Print:** `prints/06-docker-tag.png`

#### 6. Verificação da Imagem Local Marcada

```bash
docker images | grep $REPO_URI
```

Saída esperada: linha com `123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo  v1  <imageId>  <created>  <size>`

**Print:** `prints/07-docker-images-grep.png`

#### 7. Push pro ECR

```bash
docker push $REPO_URI:$IMAGE_TAG
```

Saída mostra cada layer: `Preparing` → `Waiting` → `Pushing` → `Pushed`.

**Print:** `prints/08-docker-push-layers.png`

---

### Parte 3: Verificação Remota e Bônus EKS

#### 8. Verificação do ECR

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

Saída esperada: `["v1"]`

**Print:** `prints/09-ecr-describe-images.png`

#### 9. (BÔNUS) Deploy no EKS

Caso execute o bônus do Lab012:

```bash
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
curl http://$ENDPOINT
```

**Prints (se executar bônus):**
- `prints/10-kubectl-deployments.png`
- `prints/11-kubectl-pods.png`
- `prints/12-kubectl-svc-loadbalancer.png`
- `prints/13-curl-endpoint.png`

---

## Comandos executados no Lab012 (resumo)

```bash
# Variáveis
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=123456789012
export REPO_NAME=web-app-repo
export IMAGE_TAG=v1
export REPO_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME

# 1. Verificar config AWS
aws configure list

# 2. Login no ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. Build da imagem
docker build -t web-app-v1:$IMAGE_TAG .

# 4. Criar repo ECR
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION

# 5. Tag e verify
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI

# 6. Push
docker push $REPO_URI:$IMAGE_TAG

# 7. Confirmar no ECR
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

---

## Observações

- **Ambiente:** WSL Ubuntu 24.04 dentro de Windows 11 (PC desktop)
- **Ferramentas instaladas:** AWS CLI v2.34.57, Docker Desktop, kubectl (caso execute o bônus EKS)
- **Região escolhida:** `us-east-1` (conforme enunciado)
- **Observação sobre LocalStack:** se a conta AWS real não estiver disponível, é possível usar LocalStack adicionando `--endpoint-url=http://localhost:4566` aos comandos `aws ecr`. Para Docker push em LocalStack, é necessário usar o endpoint específico do mock.

---

*TF entregue por José Luiz Henrique — RA 3225002 — 08/06/2026*
