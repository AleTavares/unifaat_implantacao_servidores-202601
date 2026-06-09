# TF - Aula 12 — RA 6325216

Este README contém as respostas teóricas, os comandos simulados para ECR/Docker e a lista de evidências solicitadas no Lab012.

## 1. Respostas teóricas

- **CI (Integração Contínua):** objetivo principal: integrar alterações de código frequentemente, automatizar builds e executar testes (unitários, lint, análise estática). O código é compilado/empacotado e gera artefatos versionados.

- **CD (Entrega/Implantação Contínua):** objetivo principal: disponibilizar automaticamente os artefatos construídos em ambientes (staging/produção) ou preparar pipelines de deploy com aprovação; inclui deploy, testes de aceitação e validação operacional.

## 2. Ferramentas CI (exemplos)

- GitHub Actions
- Jenkins
- AWS CodeBuild

## 3. Amazon ECR

- **Vantagem sobre Docker Hub público:** ECR fornece repositórios privados com controle fino via IAM, integração com VPC/endpoints, criptografia (em trânsito e em repouso) e políticas de acesso — mais adequado para aplicações privadas e requisitos de segurança.
- **Escopo e URI padrão:** ECR é regional. Formato: `<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<REPOSITORY_NAME>`

Exemplo com os dados do enunciado: `123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

## 4. Passos para fazer push de uma imagem ao ECR

1. **Autenticação:** obter token com `aws ecr get-login-password` e usar `docker login`.
2. **Tagging:** `docker tag` para marcar a imagem local com o URI do ECR.
3. **Upload:** `docker push` para enviar a imagem ao repositório.

## 5. Comandos simulados (valores fornecidos)

- Criar repositório (garantir existência):

```
aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

- Autenticação (login Docker):

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

- Tagging da imagem local `web-app:v1`:

```
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

- Push final:

```
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

Verificação opcional do repositório:

```
aws ecr describe-repositories --repository-names web-app-repo --region us-east-1
```

## 6. Comandos e evidências a coletar (Lab012)

### Parte 1 — Preparação e configuração

1. `aws configure list` — capture a saída mostrando as credenciais configuradas (chaves aparecem ocultas).
2. Login ECR (deve mostrar `Login Succeeded`):

```
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

3. Build da imagem Docker (exemplo):

```
docker build -t web-app:v1 .
```

### Parte 2 — Registro e push da imagem

1. Criar / descrever repositório:

```
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

2. Tag da imagem:

```
docker tag web-app:v1 $REPO_URI:v1
```

3. Verificar imagem local marcada:

```
docker images | grep $REPO_URI
```

4. Push (mostrando upload das camadas):

```
docker push $REPO_URI:v1
```

### Parte 3 — Verificação remota e (bônus) EKS

1. Verificar tags no ECR:

```
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query "imageDetails[].imageTags[0]"
```

2. (Bônus) Comandos para validar deploy no EKS:

```
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
curl http://$ENDPOINT
```

### Parte 4 — Organização das evidências no repositório

Crie a pasta `Aula 012/6325216/` com os seguintes arquivos:

- `README.md` (este arquivo) — contém respostas, lista de comandos e descrição das evidências.
- `evidences/` — pasta com prints e capturas de terminal (nomeie os arquivos claramente, ex: `01-aws-config.png`, `02-ecr-login.png`, `03-docker-build.png`, `04-docker-push.png`).
- `lab-commands.sh` (opcional) — script com os comandos executados (para reprodução local).

Para a PR use o título no formato: `6325216 - Nome do Aluno` (substitua pelo seu nome completo).

---

Se precisar, posso também gerar o `lab-commands.sh` com todos os comandos prontos e/ou adicionar arquivos de exemplo na pasta `evidences/` como placeholders.
