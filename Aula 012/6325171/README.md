Questão 1: Conceitos de CI/CD
a) CI (Continuous Integration)
R: Integra continuamente o código ao repositório, executando builds e testes automáticos para identificar erros rapidamente.

b) CD (Continuous Delivery/Deployment)
R: Entrega ou implanta automaticamente o artefato gerado na fase de CI em ambientes de teste ou produção.

Questão 2: Ferramentas de Pipeline
Exemplos de ferramentas para CI:
Jenkins
GitHub Actions
AWS CodeBuild

Questão 3: Amazon ECR
a)R: O ECR oferece armazenamento privado de imagens, integração com IAM e maior segurança em comparação com um Docker Hub público.

b)R: O ECR é regional.
Formato do URI:
<ID_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<REPOSITORIO>

Questão 4: Processo de Push
1. Autenticação: obter token com AWS CLI e fazer login no Docker.
2. Tagging: associar a imagem local ao URI do ECR.
3. Upload: enviar a imagem para o ECR com docker push.

Questão 5: Simulação Prática
a) Criar repositório
R: aws ecr create-repository --repository-name web-app-repo --region us-east-1
b) Login Docker
R: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
c) Tag da imagem
R: docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
d) Push da imagem
R: docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

Questão 6: Evidências Práticas da Execução do Lab012

Parte 1: Preparação e Configuração
1- Configuração AWS: aws configure list mostrando as credenciais configuradas (oculte chaves sensíveis).
R:![alt text](image.png)

2- Teste de login no ECR: resultado do comando aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com com a mensagem Login Succeeded.
R:

3- Build da imagem Docker: comando docker build -t web-app-v1:$IMAGE_TAG . e saída de sucesso.
R:![alt text](image-1.png)

Parte 2: Registro e Push da Imagem
1- Criação/descrição do repositório ECR: aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION e aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION.
R:

2- Tagging da imagem: comando docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG.
R: ![alt text](image-2.png)

3- Verificação da imagem local marcada: saída do comando docker images | grep $REPO_URI.
R: ![alt text](image-3.png)

4- Push para o ECR: comando docker push $REPO_URI:$IMAGE_TAG mostrando o upload dos layers.
R:

Parte 3: Verificação Remota e Bônus EKS
1- Verificação do ECR: aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].imageTags[0]' mostrando a tag carregada.
R:

2- (BONUS) Deploy no EKS:** se você executar o bônus do Lab012, inclua evidências de:
    * kubectl get deployments -n app-frontend
    * kubectl get pods -n app-frontend
    * kubectl get svc app-frontend-service -n app-frontend
    * curl http://$ENDPOINT (se o LoadBalancer tiver DNS disponível)