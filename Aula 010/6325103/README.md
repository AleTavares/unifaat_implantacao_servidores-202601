# TF Aula 10 - Cloud AWS

Aluno: Samuel Bueno  
RA: 6325103

---

# Questão 1

## a)

A AWS EC2 representa o modelo IaaS (Infrastructure as a Service).

Neste modelo o usuário é responsável por:
- gerenciar sistema operacional
- instalar programas
- configurar servidor
- atualizar sistema

## b)

Exemplo de PaaS:
- AWS Elastic Beanstalk

Exemplo de SaaS:
- Gmail

---

# Questão 2

## a)

Usuário IAM:
- representa uma pessoa ou aplicação

Grupo IAM:
- conjunto de usuários com mesmas permissões

## b)

Roles IAM são mais seguras porque evitam usar chaves fixas de administrador ou root.

---

# Questão 3

## a)

Subnet é uma divisão da rede VPC.

Subnet pública:
- possui acesso à internet

Subnet privada:
- sem acesso direto à internet

## b)

Internet Gateway:
- permite acesso internet

Network ACL:
- controla tráfego da subnet

---

# Questão 4

## a)

AMI (Amazon Machine Image)

## b)

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

---

# Questão 5

## Configurar credenciais

```bash
aws configure
```

## Listar instâncias

```bash
aws ec2 describe-instances
```

## Criar bucket S3

```bash
aws s3api create-bucket \
--bucket meu-bucket-tf10 \
--region sa-east-1 \
--create-bucket-configuration LocationConstraint=sa-east-1
```

## Descrever VPCs

```bash
aws ec2 describe-vpcs
```

---

# Questão 6

## Evidências

### AWS CLI

![AWS CLI](prints/aws-version.png)

### AWS Configure

![AWS Configure](prints/aws-configure.png)

### Docker PS

![Docker](prints/docker-ps.png)

### Health Check

![Health](prints/health.png)

### S3 LS

![S3LS](prints/s3ls.png)

### Bucket Criado

![Bucket](prints/bucket.png)

### EC2 Criada

![EC2](prints/ec2run.png)

### Describe Instances

![Describe](prints/describe.png)

---

# Observações

Ferramentas utilizadas:
- GitHub Codespaces
- AWS CLI
- Docker
- LocalStack
