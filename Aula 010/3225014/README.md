# Respostas #

## Questão 01 ##
A)IaaS. Neste modelo a principal responsabilidade do usuário é gerenciar tudo que está acima da Infra estrutura, ou seja, SO, softwares, aplicações etc. 

B) PaaS: Amazon Bedrock
SaaS: Amazon RDS (Relational Database Service), Amazon DynamoDB.

## Questão 02 ##
A) Usuário IAM é um usuário criado para interagir com certas aplicações ou recursos dentro da AWS, enquanto grupo IAM é um grupo de usuários com certas permissões assim como citado.

B) É uma melhor prática pois no Role IAM são utilizadas chaves de acesso temporárias, eliminando assim a utilização de uma única chave, e consequentemente, diminuindo o risco de vazamento de dados já que as chaves possuem um período de validade.

## Questão 03 ##
A) Uma VPC é uma divisão / definição lógica da rede virtual da AWS. Nela, podemos separar os diferentes recursos sendo utilizados, controlando melhor o tráfego e o balanceamento de conexões.
Subnets públicas são quando podem ser acessadas diretamente pela internet. Enquanto as públicas não.
Consequentemente, para aplicações como bancos de dados, são utilizadas subnets privadas por exemplo.

B) Para se conectar a internet, o componente necessário é a Internet Gateway.

Já o componente utilizado para controlar o tráfego é o Network ACL.

## Questão 04 ##   
A) AMI (Amazon Machine Image).

B) ssh -i minha_chave.pem ec2-user@54.123.45.67.

## Questão 05 ##

    1. Configurar credenciais: Qual comando AWS CLI é usado para configurar as credenciais e região no seu ambiente local?
        R: 
            aws configure
            # [ENTER] AWS Access Key ID: **********
            # [ENTER] AWS Secret Access Key: **********
            # [ENTER] Default region name: sa-east-1
            # [ENTER] Default output format: json

            aws configure list

    2 . Listar instâncias EC2: Qual comando AWS CLI você usaria para listar todas as instâncias EC2 na região configurada?
        R: 
            aws ec2 describe-instances \
            --query 'Reservations[].Instances[].[InstanceId, State.Name, InstanceType]'

    3. Criar um bucket S3: Qual comando AWS CLI cria um bucket chamado meu-bucket-tf10 na região sa-east-1?
        R:
            aws s3api create-bucket \
            --bucket meu-bucket-tf10 \
            --region sa-east-1 \
            --create-bucket-configuration LocationConstraint=sa-east-1
    4. Descrever VPCs: Qual comando AWS CLI retorna as informações das VPCs existentes na região configurada?
        R:
            aws ec2 describe-vpcs

## Questão 06 ##


