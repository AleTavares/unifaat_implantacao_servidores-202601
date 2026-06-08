# Questão 1 – Conceitos de CI/CD

## a) CI (Continuous Integration)

Continuous Integration (CI) é a prática de integrar frequentemente alterações de código em um repositório compartilhado. Seu principal objetivo é automatizar a compilação (*build*) e os testes do código, permitindo identificar rapidamente erros e problemas de integração antes que cheguem ao ambiente de produção.

## b) CD (Continuous Delivery/Deployment)

Continuous Delivery/Deployment (CD) é a prática de automatizar a entrega e implantação da aplicação após a fase de integração contínua. Seu principal objetivo é disponibilizar o artefato gerado (como uma imagem Docker ou aplicação) para ambientes de teste, homologação ou produção de forma rápida, segura e confiável.

---

# Questão 2 – Ferramentas de Pipeline

Três ferramentas ou serviços que podem ser utilizados para automatizar a fase de CI (*Continuous Integration*) são:

1. **Jenkins**
2. **GitHub Actions**
3. **AWS CodeBuild**

Essas ferramentas são responsáveis por executar testes automatizados, realizar *builds* e validar o código antes da etapa de entrega.

---

# Questão 3 – Amazon ECR

## a) Qual é a principal vantagem de usar o ECR em vez de um repositório Docker Hub público?

A principal vantagem do Amazon ECR em relação a um repositório Docker Hub público é a segurança. O ECR permite armazenar imagens privadas com controle de acesso através do AWS IAM, além de oferecer integração nativa com os serviços da AWS e maior controle sobre permissões e autenticação.

## b) O ECR é um serviço global ou regional? Qual é o formato padrão do URI de um repositório ECR?

O Amazon ECR é um serviço **regional**.

Formato padrão do URI:

```text
<ID_DA_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<NOME_DO_REPOSITORIO>
```

Exemplo:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

---

# Questão 4 – Processo de Push para o ECR

O envio de uma imagem Docker para o Amazon ECR segue três etapas principais:

## 1. Passo de Autenticação

Utilizando **AWS CLI** e **Docker CLI**, é obtido um token de autenticação no Amazon ECR e realizado o login do Docker no repositório.

## 2. Passo de Tagging

Utilizando **Docker CLI**, a imagem local recebe uma tag contendo o URI completo do repositório ECR para que possa ser enviada corretamente.

## 3. Passo de Upload

Utilizando **Docker CLI**, a imagem marcada é enviada para o Amazon ECR através do comando de *push*.

---

---

# Lista de Comandos Executados

```bash
aws configure list

aws sts get-caller-identity

docker build -t web-app-v1:V1.0 .

aws ecr create-repository --repository-name app-frontend --region sa-east-1

aws ecr describe-repositories --repository-names app-frontend --region sa-east-1

aws ecr get-login-password --region sa-east-1 | docker login --username AWS --password-stdin 730355530667.dkr.ecr.sa-east-1.amazonaws.com

docker tag web-app-v1:V1.0 730355530667.dkr.ecr.sa-east-1.amazonaws.com/app-frontend:V1.0

docker images

docker push 730355530667.dkr.ecr.sa-east-1.amazonaws.com/app-frontend:V1.0

aws ecr describe-images --repository-name app-frontend --region sa-east-1 --query "imageDetails[].imageTags[0]"
```

---

# Evidências Coletadas

## Evidência 1 – Configuração AWS

**Arquivo:** `aws-configure.png`

Comprovação da configuração da AWS CLI através do comando:

```bash
aws configure list
```

Exibindo as credenciais configuradas e a região padrão utilizada no laboratório.

---

## Evidência 2 – Login no Amazon ECR

**Arquivo:** `login-ecr.png`

Comprovação da autenticação do Docker no Amazon ECR utilizando AWS CLI.

Resultado esperado:

```text
Login Succeeded
```

---

## Evidência 3 – Build da Imagem Docker

**Arquivo:** `docker-build.png`

Comprovação da construção da imagem Docker utilizando o Dockerfile do laboratório.

Comando executado:

```bash
docker build -t web-app-v1:V1.0 .
```

---

## Evidência 4 – Criação do Repositório ECR

**Arquivo:** `create-repository.png`

Comprovação da criação e consulta do repositório Amazon ECR.

Comandos executados:

```bash
aws ecr create-repository
aws ecr describe-repositories
```

---

## Evidência 5 – Tagging da Imagem

**Arquivo:** `docker-tag.png`

Comprovação da associação da imagem local ao URI do repositório Amazon ECR.

Comando executado:

```bash
docker tag web-app-v1:V1.0 730355530667.dkr.ecr.sa-east-1.amazonaws.com/app-frontend:V1.0
```

---

## Evidência 6 – Verificação da Imagem Local

**Arquivo:** `docker-images.png`

Comprovação da existência da imagem local e da imagem marcada para o repositório ECR.

Comando executado:

```bash
docker images
```

---

## Evidência 7 – Push da Imagem para o Amazon ECR

**Arquivo:** `docker-push.png`

Comprovação do envio da imagem Docker para o Amazon ECR.

Comando executado:

```bash
docker push 730355530667.dkr.ecr.sa-east-1.amazonaws.com/app-frontend:V1.0
```

---

## Evidência 8 – Verificação da Imagem no ECR

**Arquivo:** `describe-images.png`

Comprovação da presença da imagem no repositório Amazon ECR após o upload.

Comando executado:

```bash
aws ecr describe-images --repository-name app-frontend --region sa-east-1 --query "imageDetails[].imageTags[0]"
```

Resultado obtido:

```json
[
  "V1.0"
]
```

---

# Observações

O laboratório foi executado com sucesso utilizando Docker Desktop e AWS CLI no Windows.

Durante a execução foi necessário iniciar o Docker Desktop antes da etapa de build da imagem, pois inicialmente o daemon Docker não estava em execução.

Após a correção, todas as etapas foram concluídas com sucesso:

* Build da imagem Docker;
* Criação do repositório Amazon ECR;
* Autenticação do Docker no ECR;
* Tagging da imagem;
* Push da imagem para a AWS;
* Verificação da imagem armazenada no ECR.

O bônus referente ao deploy da aplicação no Amazon EKS não foi executado por não ser um requisito obrigatório da atividade.
