# TF - Aula 12: CI/CD e Amazon ECR

**Aluno:** Gabriel Carneiro da Silva
**RA:** 6325300
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)

---

## Questões Teóricas

### Questão 1 — Conceitos de CI/CD

**a) CI (Continuous Integration):**
O objetivo da CI é integrar e validar o código automaticamente toda vez que um desenvolvedor faz um push. O sistema executa testes automáticos e gera o artefato (como uma imagem Docker), garantindo que o código novo não quebrou nada existente.

**b) CD (Continuous Delivery/Deployment):**
O objetivo do CD é pegar o artefato gerado pela CI (a imagem Docker já construída e testada) e entregá-lo automaticamente ao ambiente de destino — seja um repositório como o ECR, seja diretamente em produção via ECS ou Kubernetes.

---

### Questão 2 — Ferramentas de CI

Três ferramentas que automatizam a fase de CI:

1. **GitHub Actions** — integrado ao GitHub, executa pipelines direto no repositório via arquivos .yml
2. **Jenkins** — ferramenta open source, amplamente usada em ambientes corporativos
3. **AWS CodeBuild** — serviço gerenciado da AWS que executa builds e testes sem necessidade de servidor próprio

---

### Questão 3 — Amazon ECR

**a) Vantagem do ECR sobre o Docker Hub público:**
O ECR é privado e integrado ao ecossistema AWS. As imagens ficam protegidas por IAM, ou seja, só acessa quem tem permissão. Elimina o risco de expor código proprietário publicamente, e a comunicação entre o ECR e serviços como ECS ou EKS ocorre dentro da própria rede AWS, sem tráfego externo.

**b) ECR é regional.** O URI do repositório utilizado neste projeto é:

123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo

---

### Questão 4 — Processo de Push (ordem correta)

**1. Passo de Autenticação — AWS CLI:**
Obter o token de login e autenticar o Docker no ECR usando aws ecr get-login-password redirecionado para docker login.

**2. Passo de Tagging — Docker CLI:**
Marcar a imagem local com o URI completo do repositório ECR usando docker tag.

**3. Passo de Upload — Docker CLI:**
Enviar a imagem marcada para o ECR usando docker push.

---

### Questão 5 — Simulação de Comandos

**a) Criação do repositório:**
aws ecr create-repository --repository-name web-app-repo --region us-east-1

**b) Autenticação:**
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

**c) Tagging da imagem:**
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

**d) Push final:**
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

---
