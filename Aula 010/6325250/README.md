# TF010 - Respostas de Fabio Panosian (RA: 6325250)

## Questão 1: Modelos de Serviço em Nuvem (Teórica)

a) O AWS EC2 representa o modelo **IaaS (Infrastructure as a Service)**. A principal responsabilidade do usuário é gerenciar o sistema operacional, aplicações, dados e configurações de rede, enquanto a AWS fornece a infraestrutura física (servidores, armazenamento, rede).

b) Exemplo de SaaS: Amazon WorkDocs (software de produtividade acessível via navegador). Exemplo de PaaS: AWS Elastic Beanstalk (plataforma para deploy de aplicações sem gerenciar infraestrutura).

## Questão 2: Identidade e Acesso (IAM) (Teórica)

a) A diferença fundamental é que um **Usuário IAM** é uma entidade individual com credenciais próprias (como chaves de acesso), enquanto um **Grupo IAM** é uma coleção de usuários que permite gerenciar permissões de forma coletiva, facilitando a administração.

b) É uma melhor prática usar uma Role IAM porque roles fornecem credenciais temporárias e são assumidas pelas instâncias EC2, evitando a exposição de chaves permanentes do usuário Root ou Administrador, o que reduz riscos de segurança e vazamentos.

## Questão 3: Rede Virtual na AWS (VPC) (Teórica)

a) Uma **Subnet** é uma subdivisão de uma VPC que agrupa recursos em uma zona de disponibilidade específica. A diferença crucial é que uma **Subnet Pública** está conectada a um Internet Gateway (IGW), permitindo acesso direto à internet, enquanto uma **Subnet Privada** não tem essa conexão, isolando recursos internos.

b) O componente obrigatório é o **Internet Gateway (IGW)** para conectar à internet. O componente usado para inspecionar tráfego é o **Network ACL (NACL)**, que controla entrada/saída em nível de subnet.

## Questão 4: Instâncias EC2 (Prática Teórica)

a) O termo é **AMI (Amazon Machine Image)**, que é uma imagem pré-configurada do sistema operacional e software.

b) O comando é: `ssh -i minha_chave.pem ec2-user@54.123.45.67`

## Questão 5: Comandos AWS CLI (Prática)

1. **Configurar credenciais:** `aws configure`
2. **Listar instâncias EC2:** `aws ec2 describe-instances`
3. **Criar um bucket S3:** `aws s3 mb s3://meu-bucket-tf10 --region sa-east-1`
4. **Descrever VPCs:** `aws ec2 describe-vpcs`

