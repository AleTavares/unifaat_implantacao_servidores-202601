Respostas:
Questão 1: Modelos de Serviço em Nuvem
a) O AWS EC2 representa o modelo IaaS (Infrastructure as a Service). A principal responsabilidade do usuário é gerenciar o Sistema Operacional, incluindo atualizações, patches de segurança, instalação de softwares e configurações de rede/firewall. A AWS cuida apenas da infraestrutura física (servidores, energia e virtualização).

b) * PaaS: AWS Elastic Beanstalk (plataforma para implantar aplicações sem gerenciar servidores).

SaaS: AWS Amazon Chime ou Amazon WorkDocs (softwares prontos para uso via navegador).

Questão 2: Identidade e Acesso (IAM)
a) Um Usuário IAM é uma identidade individual (pessoa ou serviço) com suas próprias credenciais. Um Grupo IAM é uma coleção de usuários; ao aplicar uma política ao grupo, todos os usuários dentro dele herdam as mesmas permissões, facilitando a gestão.

b) Usar uma Role IAM é mais seguro pois ela fornece credenciais temporárias e automáticas para a instância. Isso evita a necessidade de armazenar chaves permanentes (Access Keys) dentro do servidor, o que seria um risco enorme caso a instância fosse invadida.
Questão 3: Rede Virtual na AWS (VPC)
a) Uma Subnet é um pedaço (segmento de IP) de uma VPC. A Subnet Pública possui uma rota direta para a Internet, enquanto a Subnet Privada não é acessível externamente, sendo usada para bancos de dados e back-ends.

b) Para conexão com a internet, o componente obrigatório é o Internet Gateway (IGW). Para inspecionar o tráfego em nível de Subnet, utiliza-se a Network ACL (NACL).

Questão 4: Instâncias EC2
a) O termo é AMI (Amazon Machine Image).

b) O comando é:

Bash
ssh -i minha_chave.pem ec2-user@54.123.45.67

Para te ajudar a entregar tudo a tempo, preparei as respostas focadas exatamente no que o professor espera, usando os termos técnicos da AWS. Você pode copiar e colar essas respostas no seu arquivo README.md dentro da pasta 6325109.

Questão 1: Modelos de Serviço em Nuvem
a) O AWS EC2 representa o modelo IaaS (Infrastructure as a Service). A principal responsabilidade do usuário é gerenciar o Sistema Operacional, incluindo atualizações, patches de segurança, instalação de softwares e configurações de rede/firewall. A AWS cuida apenas da infraestrutura física (servidores, energia e virtualização).

b) * PaaS: AWS Elastic Beanstalk (plataforma para implantar aplicações sem gerenciar servidores).

SaaS: AWS Amazon Chime ou Amazon WorkDocs (softwares prontos para uso via navegador).

Questão 2: Identidade e Acesso (IAM)
a) Um Usuário IAM é uma identidade individual (pessoa ou serviço) com suas próprias credenciais. Um Grupo IAM é uma coleção de usuários; ao aplicar uma política ao grupo, todos os usuários dentro dele herdam as mesmas permissões, facilitando a gestão.

b) Usar uma Role IAM é mais seguro pois ela fornece credenciais temporárias e automáticas para a instância. Isso evita a necessidade de armazenar chaves permanentes (Access Keys) dentro do servidor, o que seria um risco enorme caso a instância fosse invadida.

Questão 3: Rede Virtual na AWS (VPC)
a) Uma Subnet é um pedaço (segmento de IP) de uma VPC. A Subnet Pública possui uma rota direta para a Internet, enquanto a Subnet Privada não é acessível externamente, sendo usada para bancos de dados e back-ends.

b) Para conexão com a internet, o componente obrigatório é o Internet Gateway (IGW). Para inspecionar o tráfego em nível de Subnet, utiliza-se a Network ACL (NACL).

Questão 4: Instâncias EC2
a) O termo é AMI (Amazon Machine Image).

b) O comando é:

Bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
Questão 5: Comandos AWS CLI
Configurar credenciais: aws configure

Listar instâncias EC2: aws ec2 describe-instances

Criar um bucket S3: aws s3 mb s3://meu-bucket-tf10 --region sa-east-1

Descrever VPCs: aws ec2 describe-vpcs

Questão 6: Evidências Práticas

Parte 1: Evidências de Configuração
Instalação da AWS CLI:
![alt text](<1 - aws -- version-1.png>)

Configuração de Credenciais:
![alt text](<2 - aws configure list --profile.png>)

Health Check do LocalStack:
![alt text](<3 - curl -s -1.png>)

Teste de Conectividade:
![alt text](<4 - Teste de Conectividade LocalStack.png>)

Parte 2: Criação de Recursos
Criação do Bucket S3:
![alt text](<Parte 2 - Criar o Bucket S3-1.png>)

Criação da Instância EC2:
![alt text](<Parte 2 - Criar a Instância EC2-1.png>)
Verificação da Tag TF010:
![alt text](<Parte 2 - Criar uma Instância EC2 com tag TF010-1.png>)