# TF012 - CI/CD Basico e Registro de Imagens no ECR

**RA:** 6325123  
**Aula:** 12 - CI/CD Basico e Registro de Imagens (ECR)

## Questao 1: Conceitos de CI/CD

### a) CI (Continuous Integration)

CI e a fase em que o codigo dos desenvolvedores e integrado com frequencia ao repositorio principal. Nessa etapa, normalmente sao executados testes automatizados, validacoes, analise de codigo e o build da aplicacao.

No contexto de containers, a fase de CI tambem pode gerar a imagem Docker da aplicacao, criando um artefato versionado e pronto para ser publicado.

### b) CD (Continuous Delivery/Deployment)

CD e a fase em que o artefato gerado no CI e preparado para entrega ou implantado em um ambiente.

Em **Continuous Delivery**, o artefato fica pronto para deploy, mas a publicacao final pode depender de aprovacao manual. Em **Continuous Deployment**, o deploy acontece automaticamente apos a validacao do pipeline.

## Questao 2: Ferramentas de Pipeline

Tres ferramentas ou servicos que podem automatizar a fase de CI sao:

- **GitHub Actions**
- **GitLab CI/CD**
- **AWS CodeBuild**

Outras opcoes possiveis seriam Jenkins, Azure DevOps Pipelines e Bitbucket Pipelines.

## Questao 3: Amazon ECR

### a) Vantagem do ECR em aplicacoes privadas

A principal vantagem do Amazon ECR e permitir armazenar imagens Docker privadas dentro da AWS, com controle de acesso via IAM, integracao com servicos como ECS/EKS, criptografia e auditoria.

Em comparacao com um repositorio Docker Hub publico, o ECR e mais adequado para aplicacoes privadas porque evita expor imagens da empresa e permite aplicar permissoes especificas por usuario, role ou servico.

### b) Servico regional e formato do URI

O ECR e um servico **regional**. Um repositorio criado em uma regiao, como `us-east-1`, nao e automaticamente o mesmo em outra regiao, como `sa-east-1`.

Formato padrao do URI:

```text
[AWS_ACCOUNT_ID].dkr.ecr.[AWS_REGION].amazonaws.com/[REPO_NAME]
```

Exemplo:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

## Questao 4: Processo de Push

### 1. Passo de Autenticacao

Ferramentas usadas: **AWS CLI** e **Docker CLI**.

```bash
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Esse comando gera uma senha temporaria do ECR e autentica o Docker no registry da conta AWS.

### 2. Passo de Tagging

Ferramenta usada: **Docker CLI**.

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```

Esse comando cria uma nova tag da imagem local apontando para o endereco completo do repositorio ECR.

### 3. Passo de Upload

Ferramenta usada: **Docker CLI**.

```bash
docker push $REPO_URI:$IMAGE_TAG
```

Esse comando envia as camadas da imagem Docker para o repositorio ECR.

## Questao 5: Simulacao com AWS CLI e Docker

Valores assumidos:

```bash
AWS_ACCOUNT_ID="123456789012"
AWS_REGION="us-east-1"
REPO_NAME="web-app-repo"
IMAGE_LOCAL="web-app:v1"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
```

### a) Criacao do repositorio

```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

### b) Autenticacao no ECR

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

## Questao 6: Evidencias Praticas do Lab012

### Comandos executados ou preparados

Os comandos completos foram organizados no arquivo [comandos_lab012.sh](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/comandos_lab012.sh>).

Principais etapas:

```bash
aws configure list
docker build -t web-app-v1:V1.0 .
aws ecr create-repository --repository-name app-frontend --region us-east-2
aws ecr describe-repositories --repository-names app-frontend --region us-east-2
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com
docker tag web-app-v1:V1.0 $REPO_URI:V1.0
docker images | grep $REPO_URI
docker push $REPO_URI:V1.0
aws ecr describe-images --repository-name app-frontend --region us-east-2 --query 'imageDetails[].imageTags[0]'
```

### Artefatos criados

- [Dockerfile](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/Dockerfile>): imagem baseada em `nginx:alpine`.
- [index.html](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/index.html>): pagina estatica usada na imagem.
- [deployment.yaml](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/deployment.yaml>): deployment Kubernetes para usar a imagem do ECR.
- [service.yaml](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/service.yaml>): service `LoadBalancer` para expor a aplicacao no EKS.
- [validacao_local.md](</opt/lampp/htdocs/unifaat_implantacao_servidores-202601/Aula 012/6325123/validacao_local.md>): registro da validacao feita no ambiente local.

### Descricao das evidencias solicitadas

| Evidencia | Comando | Resultado esperado |
| --- | --- | --- |
| Configuracao AWS | `aws configure list` | Profile, regiao e credenciais mascaradas |
| Login no ECR | `aws ecr get-login-password ... \| docker login ...` | Mensagem `Login Succeeded` |
| Build Docker | `docker build -t web-app-v1:V1.0 .` | Imagem criada com sucesso |
| Repositorio ECR | `aws ecr create-repository` e `aws ecr describe-repositories` | Repositorio `app-frontend` criado/listado |
| Tagging | `docker tag web-app-v1:V1.0 $REPO_URI:V1.0` | Tag remota criada localmente |
| Verificacao local | `docker images \| grep $REPO_URI` | Imagem com URI do ECR |
| Push | `docker push $REPO_URI:V1.0` | Upload das layers para o ECR |
| Verificacao remota | `aws ecr describe-images ...` | Tag `V1.0` exibida |

### Bonus EKS

Arquivos preparados:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
```

O campo `image` do arquivo `deployment.yaml` usa a imagem:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

Em uma execucao real, esse valor deve ser ajustado para a conta, regiao, repositorio e tag usados no ECR.

## Observacoes

Esta entrega documenta o fluxo do Lab012 e deixa os artefatos prontos para execucao. Para executar em uma conta AWS real, e necessario substituir o `AWS_ACCOUNT_ID`, confirmar a regiao correta, garantir permissoes IAM para ECR/EKS e remover os recursos ao final para evitar cobrancas.

Credenciais sensiveis nao devem ser salvas no repositorio. Prints de terminal devem ocultar access keys, secret keys e tokens.

No ambiente atual, o build Docker foi tentado, mas o acesso ao Docker daemon foi negado por permissao no socket `/var/run/docker.sock`. Por isso, as etapas que dependem de Docker daemon, AWS ECR real e EKS devem ser executadas em um terminal com Docker ativo e credenciais AWS configuradas.
