# TF012 - CI/CD Basico e Registro de Imagens no Amazon ECR

Aluno: Andreyh Rodrigues de Souza  
RA: 6325231  
Disciplina: Implementacao de servidor e nuvem (cloud)  
Aula: 12 - CI/CD Basico e Registro de Imagens (ECR)

## Questao 1: Conceitos de CI/CD

### a) CI - Continuous Integration

CI e a fase de integracao continua. O objetivo principal e integrar o codigo dos desenvolvedores com frequencia em um repositorio central, executando validacoes automatizadas como testes, analise de codigo e build. Em um projeto com containers, normalmente a fase de CI tambem constroi a imagem Docker da aplicacao.

### b) CD - Continuous Delivery/Deployment

CD e a fase que leva o artefato gerado pela CI para um ambiente de execucao. No Continuous Delivery, o artefato fica pronto para ser implantado com aprovacao manual. No Continuous Deployment, a implantacao acontece automaticamente em ambientes como homologacao ou producao. No contexto da aula, o artefato buildado e a imagem Docker publicada no ECR e depois usada em um deploy.

## Questao 2: Ferramentas de Pipeline

Tres ferramentas ou servicos que podem automatizar a fase de CI sao:

- GitHub Actions
- Jenkins
- AWS CodeBuild

Outras opcoes possiveis seriam GitLab CI/CD, CircleCI, Bitbucket Pipelines e AWS CodePipeline integrado ao CodeBuild.

## Questao 3: Amazon ECR

### a) Vantagem do ECR para aplicacao privada

A principal vantagem do Amazon ECR em relacao a um repositorio publico no Docker Hub e a integracao nativa com a seguranca da AWS. O acesso pode ser controlado por IAM, politicas de permissao, autenticacao temporaria via AWS CLI, criptografia e auditoria. Isso e mais adequado para imagens privadas de aplicacoes internas ou corporativas.

### b) ECR global ou regional e formato do URI

O Amazon ECR e um servico regional. Um repositorio criado em uma regiao, como `us-east-1`, pertence aquela regiao.

Formato padrao do URI:

```text
<aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/<repository-name>
```

Exemplo:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

## Questao 4: Processo de Push

1. Passo de Autenticacao: usar `aws ecr get-login-password` com `docker login` para autenticar o Docker no registry ECR.
2. Passo de Tagging: usar `docker tag` para marcar a imagem local com o URI completo do repositorio ECR.
3. Passo de Upload: usar `docker push` para enviar a imagem marcada para o ECR.

## Questao 5: Tarefa Pratica Integrada

Valores assumidos:

- ID da Conta AWS: `123456789012`
- Regiao: `us-east-1`
- Nome do Repositorio ECR: `web-app-repo`
- Imagem Local: `web-app:v1`

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

## Questao 6: Evidencias Praticas da Execucao do Lab012

Os arquivos do lab foram preparados nesta pasta:

- `Dockerfile` - imagem baseada em `nginx:alpine`.
- `index.html` - pagina estatica copiada para o Nginx.
- `comandos_lab012.md` - lista dos comandos usados no fluxo ECR e no bonus EKS.
- `deployment.yaml` - manifesto Kubernetes do bonus EKS.
- `service.yaml` - Service LoadBalancer do bonus EKS.
- `evidencias/README_EVIDENCIAS.md` - checklist dos prints/capturas esperados.

### Parte 1: Preparacao e Configuracao

Evidencias esperadas:

1. `evidencia-01-aws-configure-list.png` - `aws configure list` com chaves sensiveis ocultas.
2. `evidencia-02-ecr-login-succeeded.png` - login no ECR retornando `Login Succeeded`.
3. `evidencia-03-docker-build.png` - build da imagem `web-app-v1:V1.0`.

Comandos:

```bash
export IMAGE_TAG="V1.0"
export AWS_ACCOUNT_ID="<id-da-conta-aws>"
export AWS_REGION="us-east-2"
export REPO_NAME="app-frontend"
export REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

aws configure list
docker build -t web-app-v1:$IMAGE_TAG .
docker images | grep web-app-v1
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### Parte 2: Registro e Push da Imagem

Evidencias esperadas:

1. `evidencia-04-ecr-create-describe.png` - criacao ou descricao do repositorio ECR.
2. `evidencia-05-docker-tag.png` - tagging da imagem.
3. `evidencia-06-docker-images-repo-uri.png` - imagem local marcada com URI do ECR.
4. `evidencia-07-docker-push.png` - push mostrando upload das layers.

Comandos:

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI
docker push $REPO_URI:$IMAGE_TAG
```

### Parte 3: Verificacao Remota e Bonus EKS

Evidencia esperada:

1. `evidencia-08-ecr-describe-images.png` - tag carregada no ECR.

Comando:

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

Bonus EKS, se executado:

```bash
kubectl create namespace app-frontend
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
ENDPOINT=$(kubectl get svc app-frontend-service -n app-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ENDPOINT
```

Observacao: o bonus EKS e opcional e pode gerar cobranca na AWS. Se nao for executado, registrar que somente o fluxo principal de ECR foi realizado.

## Observacoes sobre erros ou diferencas

- Verificacao local: o Docker esta instalado neste ambiente, mas o comando `aws --version` retornou `aws: command not found`. Portanto, os comandos AWS/ECR ficaram documentados para execucao em um terminal com AWS CLI instalada e credenciais configuradas.
- O erro `repository name already exists` pode aparecer se o repositorio ECR ja existir. Nesse caso, basta seguir usando o repositorio existente ou executar `describe-repositories`.
- O erro `Could not connect to the Docker daemon` indica que o Docker Desktop nao esta em execucao.
- O erro `AccessDeniedException` indica falta de permissao IAM para ECR.
- O erro `no basic auth credentials` indica que o login no ECR precisa ser executado novamente.
- Tokens de login do ECR expiram, portanto o comando de autenticacao pode precisar ser repetido.

## Checklist de entrega

- [x] Pasta `Aula 012/6325231` criada.
- [x] `README.md` com respostas teoricas.
- [x] Comandos do fluxo ECR documentados.
- [x] `Dockerfile` e `index.html` preparados para build local.
- [x] Manifestos opcionais do bonus EKS adicionados.
- [x] Checklist de evidencias criado em `evidencias/README_EVIDENCIAS.md`.
