## TF - Aula 12

# Questão 1: Conceitos de CI/CD (Teórica)

a) CI (Continuous Integration): O objetivo principal é automatizar a integração de alterações de código de múltiplos desenvolvedores em um repositório compartilhado de forma frequente. Nesta fase, o código é buildado, testado e validado automaticamente assim que um commit é feito, garantindo a integridade do código.

b) CD (Continuous Delivery/Deployment): O objetivo é automatizar o fluxo que leva o artefato gerado na fase de CI até os ambientes de execução. No Continuous Delivery, o artefato (imagem Docker) é publicado em um registro (como o ECR), pronto para deploy. No Continuous Deployment, ele é implantado automaticamente no ambiente final sem intervenção humana.

# Questão 2: Ferramentas de Pipeline

Três ferramentas/serviços que podem automatizar a fase de CI são:
1. AWS CodeBuild
2. GitHub Actions
3. Jenkins

# Questão 3: Amazon ECR

a) Vantagem de segurança: O ECR oferece controle de acesso privado e refinado integrado nativamente com o AWS IAM, permitindo definir exatamente quem pode dar push/pull nas imagens, além de contar com varredura automática de vulnerabilidades, ao contrário de repositórios públicos do Docker Hub.
b) Escopo e Formato do URI:** O ECR é um serviço Regional. O formato padrão do URI é:  
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME

# Questão 4: Processo de Push

1. Passo de Autenticação: Utiliza-se a AWS CLI com o comando aws ecr get-login-password integrado ao docker login para autenticar o cliente Docker local no registro da AWS.
2. Passo de Tagging: Utiliza-se a Docker CLI com o comando docker tag para referenciar a imagem local com o endereço do URI do repositório remoto.
3. Passo de Upload: Utiliza-se a Docker CLI com o comando docker push para enviar as camadas da imagem para o ECR.

# Questão 5: Tarefa Prática Integrada (Simulação)
Com base nos dados fornecidos (Conta: 123456789012, Região: us-east-1, Repositório: web-app-repo, Imagem: web-app:v1), os comandos são:

a) Criação do Repositório:

aws ecr create-repository --repository-name web-app-repo --region us-east-1

b)Autenticação (Login Docker):

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

c)Tagging da Imagem:

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

d) Push Final:

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1


