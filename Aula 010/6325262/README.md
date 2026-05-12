# TF - Aula 10 - Conceitos de Infraestrutura em Nuvem e AWS

## Nome

Gabriel Souza

## RA

6325262

---

# Questão 1

## a)

O serviço AWS EC2 representa o modelo IaaS (Infrastructure as a Service).

Nesse modelo, o usuário é responsável por gerenciar:

* Sistema Operacional
* Aplicações
* Configurações
* Segurança da instância

A AWS fornece apenas a infraestrutura virtualizada.

## b)

Exemplo de PaaS:

* AWS Elastic Beanstalk

Exemplo de SaaS:

* Microsoft 365

---

# Questão 2

## a)

Usuário IAM:

* Representa uma pessoa ou aplicação com permissões específicas.

Grupo IAM:

* É um conjunto de usuários IAM que compartilham as mesmas permissões.

## b)

Roles IAM são mais seguras porque evitam o uso de chaves fixas de acesso.

As permissões são entregues temporariamente para a instância EC2, reduzindo riscos de vazamento de credenciais.

---

# Questão 3

## a)

Subnet é uma divisão lógica dentro de uma VPC.

Subnet Pública:

* Possui acesso à internet.

Subnet Privada:

* Não possui acesso direto à internet.

## b)

O componente obrigatório para acesso à internet é o Internet Gateway.

O componente usado para inspecionar tráfego em nível de subnet é o Network ACL (NACL).

---

# Questão 4

## a)

O nome da imagem do sistema operacional usada no EC2 é AMI (Amazon Machine Image).

## b)

Comando SSH:

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

---

# Questão 5

## 1. Configurar credenciais

```bash
aws configure
```

## 2. Listar instâncias EC2

```bash
aws ec2 describe-instances
```

## 3. Criar bucket S3

```bash
aws s3 mb s3://meu-bucket-tf10 --region sa-east-1
```

## 4. Descrever VPCs

```bash
aws ec2 describe-vpcs
```

---

# Questão 6

## Evidências

### AWS CLI instalada

```bash
aws --version
```

### Configuração AWS

```bash
aws configure list
```

### LocalStack iniciado

```bash
docker run --rm -d \
  -e SERVICES=s3,iam,ec2 \
  -e DEFAULT_REGION=sa-east-1 \
  -p 4566:4566 \
  localstack/localstack:0.14.3
```

### Teste LocalStack

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

---

# Criação do Bucket

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf010-6325262
```

---

# Criação da Instância EC2

```bash
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --count 1 \
  --instance-type t2.micro \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=TF010-6325262}]'
```

---

# Observações

* Foi utilizado WSL/Linux para execução dos comandos.
* AWS CLI foi utilizada para gerenciamento da infraestrutura.
* LocalStack foi utilizado para simulação local dos serviços AWS.
* Docker foi utilizado para executar o LocalStack.
