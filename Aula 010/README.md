# TF - Aula 10 - Cloud Computing e AWS

Aluno: weslley lucas souza alves
RA: 6325226

---

# Questão 1 - Modelos de Serviço em Nuvem

## a)

O serviço AWS EC2 representa o modelo IaaS (Infrastructure as a Service).

Nesse modelo o usuário é responsável por:

- gerenciamento do sistema operacional;
- instalação de softwares;
- configuração de firewall;
- gerenciamento de aplicações.

A AWS fornece apenas a infraestrutura virtualizada.

## b)

Exemplo de PaaS:
- AWS Elastic Beanstalk

Exemplo de SaaS:
- Microsoft 365
- Google Workspace

---

# Questão 2 - IAM

## a)

Usuário IAM:
- representa uma identidade individual;
- possui login e permissões próprias.

Grupo IAM:
- é um conjunto de usuários;
- facilita aplicar permissões iguais para vários usuários.

## b)

Uma IAM Role é mais segura porque fornece credenciais temporárias.

Evita o uso de chaves permanentes do usuário Root ou Administrador, reduzindo riscos de vazamento e acesso indevido.

---

# Questão 3 - VPC

## a)

Subnet é uma divisão lógica da rede dentro da VPC.

Subnet Pública:
- possui acesso à internet através do Internet Gateway.

Subnet Privada:
- não possui acesso direto à internet.

## b)

Componente obrigatório:
- Internet Gateway (IGW)

Componente para inspeção de tráfego:
- Network ACL (NACL)

---

# Questão 4 - EC2

## a)

O nome da imagem do sistema operacional na AWS é AMI (Amazon Machine Image).

## b)

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

---

# Questão 5 - AWS CLI

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

# Questão 6 - Evidências Práticas

## Parte 1 - Configuração

### 1. AWS CLI instalada

```bash
aws --version
```

PRINT AQUI

---

### 2. Credenciais AWS

```bash
aws configure list
```

PRINT AQUI

---

### 3. LocalStack via Docker

```bash
docker run -d --name localstack -p 4566:4566 localstack/localstack
```

```bash
curl -s http://localhost:4566/_localstack/health
```

PRINTS AQUI

---

### 4. Teste LocalStack

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

PRINT AQUI

---

# Parte 2 - Criação de Recursos

## 1. Criar Bucket S3

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf010-SEU-RA
```

PRINT AQUI

---

## 2. Criar Instância EC2

```bash
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
--image-id ami-0c55b159cbfafe1f0 \
--count 1 \
--instance-type t2.micro \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=TF010-SEU-RA}]'
```

## Verificar instância criada

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

PRINTS AQUI

---

# Ferramentas Utilizadas

- AWS CLI
- Docker
- LocalStack
- WSL Ubuntu
- GitHub

---

# Observações

Foi utilizado LocalStack para simular os serviços AWS localmente sem custos.

Os comandos AWS foram executados utilizando:

```bash
--endpoint-url=http://localhost:4566
```

para direcionar as requisições ao ambiente LocalStack.