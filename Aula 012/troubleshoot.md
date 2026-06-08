# Troubleshoot Aula 12 - CI/CD e ECR

## 1. Criando a Access Key e a Secret Key

Se a conta AWS ainda não tiver credenciais configuradas no terminal, siga estes passos:

### 1.1 Acessar o AWS Management Console
1. Abra o navegador e faça login no Console AWS.
2. No menu superior, selecione o serviço `IAM`.
3. No painel lateral, clique em `Users`.
4. Selecione seu usuário IAM (ou crie um novo usuário se ainda não existir).

### 1.2 Criar credenciais Programáticas
1. Dentro do usuário IAM, clique na aba `Security credentials`.
2. Role até `Access keys` e clique em `Create access key`.
3. Escolha `AWS CLI` como método de criação.
4. Anote imediatamente:
   - `Access key ID`
   - `Secret access key`

> IMPORTANTE: O segredo (`Secret access key`) é mostrado apenas uma vez. Salve em um local seguro.

### 1.3 Políticas recomendadas
O usuário deve ter permissão para ECR e, se utilizar outras etapas do lab, também:
- `AmazonEC2ContainerRegistryFullAccess`
- `AmazonS3ReadOnlyAccess` (se houver uso adicional de S3)
- `AmazonECRPublicFullAccess` (se ECR público for usado)

## 2. Configurando as credenciais no terminal

### 2.1 Usando `aws configure`
Se você não estiver logado no CLI, basta configurar as credenciais:

```bash
aws configure
```

Quando solicitado, informe:
- AWS Access Key ID [None]: `SUA_ACCESS_KEY_ID`
- AWS Secret Access Key [None]: `SUA_SECRET_ACCESS_KEY`
- Default region name [None]: `sa-east-1` ou `us-east-2`
- Default output format [None]: `json`

### 2.2 Verificar a configuração

```bash
aws configure list
aws sts get-caller-identity
```

A saída deve mostrar seu `Account` e `UserId`.

### 2.3 Alternativa: variáveis de ambiente
Se você não quiser salvar no `~/.aws/credentials`, use variáveis no terminal:

```bash
export AWS_ACCESS_KEY_ID="SUA_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="SUA_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="sa-east-1"
```

Para ver se funcionou:

```bash
aws sts get-caller-identity
```

### 2.4 Usando perfil alternativo
Se tiver mais de uma credencial configurada:

```bash
aws configure --profile meu-perfil
```

E use assim nos comandos:

```bash
aws ecr describe-repositories --region sa-east-1 --profile meu-perfil
```

## 3. Problemas comuns durante o Lab 12

### 3.1 Erro: `Unable to locate credentials`

**Causa:** CLI não encontra credenciais válidas.

**Solução:**
- Execute `aws configure`.
- Ou exporte `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`.
- Verifique `aws configure list`.

### 3.2 Erro: `Login Succeeded` não aparece ou `docker login` falha

**Causa:** credenciais inválidas ou região incorreta.

**Solução:**
- Verifique se `AWS_REGION` está igual à região do ECR.
- Use o comando correto:

```bash
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

- Se usar perfil, inclua `--profile meu-perfil`.

### 3.3 Erro: `repository name already exists`

**Causa:** repositório ECR já foi criado antes.

**Solução:**
- Ignore o erro e continue com o `docker tag` e `docker push`.
- Ou use outro `REPO_NAME`.

### 3.4 Erro: `AccessDeniedException` ao criar repositório ou autenticar

**Causa:** usuário IAM sem permissão ECR.

**Solução:**
- Peça ao administrador para anexar `AmazonEC2ContainerRegistryFullAccess`.
- Verifique se o usuário não está usando credenciais antigas.

### 3.5 Erro: `InvalidClientTokenId` ou `SignatureDoesNotMatch`

**Causa:** Access key ou Secret key incorretos.

**Solução:**
- Refaça `aws configure` com as credenciais corretas.
- Confirme se o `Secret access key` está completo e sem espaços extras.

### 3.6 Erro: `Could not connect to the Docker daemon`

**Causa:** Docker Desktop não está rodando.

**Solução:**
- Abra o Docker Desktop e aguarde o status `Docker is running`.
- No WSL, confirme com `docker version`.

### 3.7 Erro: `no basic auth credentials`

**Causa:** Docker não foi autenticado no ECR.

**Solução:**
- Execute novamente o login do ECR.
- Verifique se não há caracteres especiais ou cópia incorreta no comando.

### 3.8 Erro: `RepositoryNotFoundException`

**Causa:** URI do ECR incorreto ou repositório não existe.

**Solução:**
- Verifique `REPO_URI`:

```bash
echo $REPO_URI
```

- Confirme que `$AWS_ACCOUNT_ID`, `$AWS_REGION` e `$REPO_NAME` estão corretos.

### 3.9 Erro: `Image already exists in repository` no push

**Causa:** a mesma imagem e tag já estão no ECR.

**Solução:**
- Use outra tag ou force rebuild:

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:novo-tag
```

### 3.10 Erro: região errada durante comandos AWS

**Causa:** o comando usa região diferente da configuração.

**Solução:**
- Verifique `aws configure get region`.
- Adicione `--region $AWS_REGION` a todos os comandos AWS.

## 4. Dicas extras

- Sempre execute `aws sts get-caller-identity` antes de iniciar para confirmar que está usando a conta correta.
- Se o CLI estiver usando perfil errado, force o `--profile` no comando.
- Não compartilhe `AWS_SECRET_ACCESS_KEY` em capturas de tela ou arquivos públicos.
- Se tiver dúvidas de permissão, valide com `aws iam get-user`.
- Use `docker images` para confirmar que a imagem local existe antes do `docker tag`.

---

## 5. Passo a passo rápido para configuração do Lab

1. Configure o AWS CLI:
   ```bash
   aws configure
   ```
2. Defina variáveis do Lab:
   ```bash
   export AWS_ACCOUNT_ID="123123123123"
   export AWS_REGION="sa-east-1"
   export REPO_NAME="app-frontend"
   export IMAGE_TAG="V1.0"
   ```
3. Crie o repositório ECR:
   ```bash
   aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
   ```
4. Faça login no Docker:
   ```bash
   aws ecr get-login-password --region $AWS_REGION | \
     docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
   ```
5. Faça o push da imagem para o ECR.
