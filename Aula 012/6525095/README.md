# TF012 - Respostas das Questões Teóricas

**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD

**a) CI (Continuous Integration):**  
Integrar e validar continuamente o código de diferentes desenvolvedores em um repositório compartilhado, executando builds e testes automatizados a cada alteração.

**b) CD (Continuous Delivery/Deployment):**  
Entregar o artefato buildado (imagem, pacote) a um ambiente de staging ou produção de forma automatizada e confiável.

---

## Questão 2: Ferramentas de Pipeline

Três ferramentas para automatizar a fase de CI:

1. GitHub Actions
2. Jenkins
3. AWS CodeBuild

---

## Questão 3: Amazon ECR

**a)** O ECR é privado por padrão, integrado ao IAM da AWS, garantindo que apenas usuários/serviços autorizados acessem as imagens — sem exposição pública.

**b)** Regional. Formato do URI:
```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>
```

---

## Questão 4: Processo de Push

1. **Passo de Autenticação:** `aws ecr get-login-password` piped para `docker login`
2. **Passo de Tagging:** `docker tag` marcando a imagem local com o URI completo do ECR
3. **Passo de Upload:** `docker push` enviando a imagem taggeada para o ECR

---

## Questão 5: Tarefa Prática Integrada

Valores assumidos:
- **ID da Conta AWS:** `123456789012`
- **Região:** `us-east-1`
- **Nome do Repositório ECR:** `web-app-repo`
- **Imagem Local:** `web-app:v1`

**a) Criação do Repositório:**
```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
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