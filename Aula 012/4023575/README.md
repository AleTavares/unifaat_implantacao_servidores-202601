# TF012 - CI/CD Básico e Registro de Imagens (ECR)

## Aluno
Emilly Santos de Oliveira
---

## RA
4023575
---

## Questão 1 - Conceitos de CI/CD

### a)

A Integração Contínua (CI - Continuous Integration) tem como objetivo integrar frequentemente as alterações de código realizadas pelos desenvolvedores em um repositório central. Durante essa fase são executados processos automatizados como compilação, testes e validação do código, permitindo identificar erros rapidamente antes da implantação.

### b)

A Entrega Contínua (CD - Continuous Delivery/Deployment) tem como objetivo automatizar a disponibilização do artefato gerado durante a fase de integração contínua. Após a aprovação dos testes e do build, a aplicação pode ser disponibilizada para homologação ou produção de forma automática ou semiautomática.

---

## Questão 2 - Ferramentas de Pipeline

Três ferramentas ou serviços que podem ser utilizados para automatizar a fase de CI são:

* Jenkins
* GitHub Actions
* AWS CodeBuild

Essas ferramentas são responsáveis pela execução de testes automatizados, compilação da aplicação e criação de imagens Docker.

---

## Questão 3 - Amazon ECR

### a)

A principal vantagem do Amazon ECR é a integração nativa com os serviços AWS e a segurança proporcionada pelo controle de acesso através do IAM. Além disso, o ECR permite armazenar imagens Docker privadas de forma segura e controlada.

### b)

O Amazon ECR é um serviço regional.

Formato padrão do URI de um repositório ECR:

```text
<ID_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<REPOSITORIO>
```

Exemplo:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

---

## Questão 4 - Processo de Push

### Passo de Autenticação

Utilizando AWS CLI e Docker CLI:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### Passo de Tagging

Utilizando Docker CLI:

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### Passo de Upload

Utilizando Docker CLI:

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Questão 5 - Tarefa Prática Integrada

### a) Criação do Repositório

```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

### b) Autenticação (Login Docker)

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### c) Tagging da Imagem

```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### d) Push Final

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Questão 6 - Evidências Práticas

### Evidência 1 - Configuração AWS CLI

Comando executado:

```bash
aws configure list
```

Resultado:

Credenciais AWS configuradas corretamente.

Print:

```text
![alt text](image.png)
```

---

### Evidência 2 - Login no ECR

Comando executado:

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Resultado:

```text
Login Succeeded
```

Print:

```text
![alt text](image.png)
```

---

### Evidência 3 - Build da Imagem Docker

Comando executado:

```bash
docker build -t web-app-v1:$IMAGE_TAG .
```

Resultado:

Imagem criada com sucesso.

Print:

```text
![alt text](image.png)
```

---

### Evidência 4 - Criação do Repositório ECR

Comandos executados:

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
```

```bash
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```

Resultado:

Repositório criado e listado com sucesso.

Print:

```text
![alt text](image.png)
```

---

### Evidência 5 - Tagging da Imagem

Comando executado:

```bash
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```

Resultado:

Imagem marcada com o URI do ECR.

Print:

```text
![alt text](image.png)
```

---

### Evidência 6 - Verificação da Imagem Local

Comando executado:

```bash
docker images | grep $REPO_URI
```

Resultado:

Imagem exibida corretamente na lista local.

Print:

```text
![alt text](image.png)
```

---

### Evidência 7 - Push para o ECR

Comando executado:

```bash
docker push $REPO_URI:$IMAGE_TAG
```

Resultado:

Upload dos layers concluído com sucesso.

Print:

```text
![alt text](image.png)
```

---

### Evidência 8 - Verificação Remota do ECR

Comando executado:

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

Resultado:

Tag da imagem encontrada no repositório ECR.

Print:

```text
![alt text](image.png)
```

**(BONUS) Deploy no EKS:** se você executar o bônus do Lab012, inclua evidências de:
    * `kubectl get deployments -n app-frontend` - ![alt text](image.png)
    * `kubectl get pods -n app-frontend` - ![alt text](image.png)
    * `kubectl get svc app-frontend-service -n app-frontend` - ![alt text](image-1.png)
    * `curl http://$ENDPOINT` (se o LoadBalancer tiver DNS disponível) - ![alt text](image-2.png)


---

## Lista de Comandos Executados

```bash
aws configure list

aws ecr create-repository

aws ecr describe-repositories

aws ecr get-login-password

docker login

docker build

docker tag

docker images

docker push

aws ecr describe-images
```

---

## Observações

Durante a execução do laboratório foram realizados procedimentos de autenticação no Amazon ECR, criação do repositório, build da imagem Docker, marcação da imagem, upload para o registro e validação da imagem armazenada no serviço.

Quaisquer erros encontrados durante a execução foram corrigidos antes da conclusão das atividades.

---

## Conclusão

Durante o laboratório foram aplicados os conceitos fundamentais de CI/CD e gerenciamento de imagens Docker utilizando o Amazon ECR. Foram realizados procedimentos de autenticação, criação de repositório, build de imagem, push para o registro e verificação do armazenamento remoto, demonstrando o funcionamento básico de um pipeline de entrega de aplicações em ambiente AWS.