## Questão 1: Modelos de Serviço em Nuvem
## a
O AWS EC2 (Elastic Compute Cloud) pertence ao modelo **IaaS (Infrastructure as a Service)**.

Nesse modelo, a AWS fornece a infraestrutura da nuvem, como servidores virtuais, armazenamento, rede e virtualização.

A principal responsabilidade do usuário é gerenciar o sistema operacional e o ambiente da instância. Isso inclui:
- instalar softwares;
- configurar o servidor;
- aplicar atualizações e patches de segurança;
- administrar usuários e permissões;
- monitorar aplicações.

Ou seja, no EC2 o usuário possui controle sobre a máquina virtual e deve administrar o sistema operacional e os recursos utilizados.  

### b Exemplo de Serviço SaaS ou PaaS na AWS

Um exemplo de serviço da AWS no modelo **PaaS (Platform as a Service)** é o **AWS Elastic Beanstalk**.

Nesse modelo, a AWS gerencia a infraestrutura, o sistema operacional e grande parte da configuração do ambiente, enquanto o usuário apenas envia e gerencia sua aplicação.

O Elastic Beanstalk permite realizar o deploy de aplicações sem a necessidade de configurar servidores manualmente.  

## Questão 2: Identidade e Acesso (IAM)

### a Diferença entre Usuário IAM e Grupo IAM

Um **Usuário IAM** representa uma identidade individual criada na AWS para uma pessoa ou aplicação. Cada usuário possui credenciais próprias, como login e senha ou chaves de acesso, além de permissões específicas.

Já um **Grupo IAM** é um conjunto de usuários IAM utilizado para facilitar o gerenciamento de permissões. As permissões são atribuídas ao grupo, e todos os usuários que fazem parte dele herdam essas permissões.

Por exemplo, é possível criar um grupo chamado "Administradores" e adicionar vários usuários nele, evitando configurar permissões individualmente para cada usuário.  
### b) Uso de Role IAM em vez de chaves Root ou Administrador

Criar uma **Role IAM** para uma instância EC2 é uma melhor prática de segurança porque evita o uso de chaves de acesso permanentes de usuários Root ou Administradores dentro da aplicação ou servidor.

As Roles IAM fornecem credenciais temporárias e automáticas para a instância EC2 acessar serviços da AWS, como o S3, reduzindo o risco de vazamento de credenciais sensíveis.

Além disso, o uso de Roles segue o princípio do menor privilégio, permitindo conceder apenas as permissões necessárias para a instância executar suas tarefas.

Já utilizar chaves de usuários Root ou Administradores é inseguro, pois essas contas possuem permissões excessivas e, caso as credenciais sejam comprometidas, toda a conta AWS pode ficar em risco.  
## Questão 3: Rede Virtual na AWS (VPC)

### a) Conceito de Sub-rede e diferença entre Sub-rede Pública e Privada

Uma **Sub-rede (Subnet)** é uma divisão lógica da rede dentro de uma VPC (Virtual Private Cloud). Ela permite organizar e separar recursos da AWS em diferentes segmentos de rede, facilitando o controle de segurança e comunicação.

A principal diferença entre uma **Sub-rede Pública** e uma **Sub-rede Privada** está no acesso à internet:

- **Sub-rede Pública:** possui uma rota conectada a um Internet Gateway, permitindo que os recursos dentro dela tenham acesso direto à internet. Normalmente é utilizada para servidores web e recursos que precisam ser acessados externamente.

- **Sub-rede Privada:** não possui acesso direto à internet. Os recursos dessa sub-rede ficam protegidos e geralmente são utilizados para bancos de dados, aplicações internas e serviços que não devem ser expostos publicamente.

Dessa forma, a separação entre sub-redes públicas e privadas aumenta a segurança e a organização da infraestrutura na AWS.  
### b) Componentes de rede para acesso à Internet e controle de tráfego

O componente obrigatório para que uma instância EC2 em uma Sub-rede Pública consiga acessar a Internet é o **Internet Gateway (IGW)**. Ele permite o envio e recebimento de tráfego entre a VPC e a Internet.

Além disso, a tabela de rotas da sub-rede deve possuir uma rota apontando para o Internet Gateway.

O componente utilizado para controlar o tráfego de entrada e saída em nível de Sub-rede é o **Network ACL (NACL)**. Ele funciona como uma camada adicional de segurança, permitindo ou negando tráfego para toda a sub-rede.

Enquanto o NACL atua no nível da sub-rede, o Security Group atua no nível da instância EC2.  
## Questão 4: Instâncias EC2

### a) Imagem do Sistema Operacional no EC2

Ao lançar uma instância EC2, a AWS utiliza uma imagem pré-configurada chamada **AMI (Amazon Machine Image)**.

A AMI contém o sistema operacional, aplicações e configurações necessárias para iniciar uma instância EC2.

Exemplos de AMIs incluem:
- Ubuntu
- Amazon Linux
- Windows Server
- Red Hat Enterprise Linux  
### b) Comando para conectar em uma instância EC2 Linux via SSH

Após lançar a instância e liberar a porta 22 no Security Group, o comando utilizado no terminal WSL para acessar a instância é:

ssh -i minha_chave.pem ec2-user@54.123.45.67

 ### Questão 5: Comandos AWS CLI


## Configurar credenciais

Comando utilizado para configurar as credenciais e a região da AWS no ambiente local:

aws configure

### Listar instâncias EC2
Comando utilizado para listar todas as instâncias EC2 da região configurada:

aws ec2 describe-instances

### Criar um bucket S3

Comando utilizado para criar um bucket chamado meu-bucket-tf10 na região sa-east-1:

aws s3api create-bucket \
  --bucket meu-bucket-tf10 \
  --region sa-east-1 \
  --create-bucket-configuration LocationConstraint=sa-east-1

### Descrever VPCs

Comando utilizado para retornar as informações das VPCs existentes na região configurada:

aws ec2 describe-vpcs