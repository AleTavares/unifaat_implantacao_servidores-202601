# TF Aula 010 — Cloud Computing e AWS

## Questão 1: Modelos de Serviço em Nuvem

### a)
O serviço EC2 (Elastic Compute Cloud) da AWS representa o modelo **IaaS (Infrastructure as a Service)**.

Nesse modelo, a AWS fornece a infraestrutura (servidores, armazenamento, rede e virtualização), enquanto o usuário é responsável por:

- Gerenciar o sistema operacional;
- Instalar aplicações;
- Configurar segurança;
- Administrar atualizações e serviços.

---

### b)
Exemplo de PaaS:

- AWS Elastic Beanstalk

Exemplo de SaaS:

- Salesforce

---

# Questão 2: Identidade e Acesso (IAM)

### a)
A diferença entre Usuário IAM e Grupo IAM é:

- Usuário IAM representa uma pessoa ou aplicação com credenciais próprias;
- Grupo IAM é um conjunto de usuários que compartilham permissões.

---

### b)
É mais seguro utilizar uma Role IAM porque:

- Evita uso de chaves permanentes;
- Fornece credenciais temporárias;
- Reduz risco de vazamento de acesso;
- Permite acesso seguro da EC2 a serviços como S3.

---

# Questão 3: Rede Virtual na AWS (VPC)

### a)
Subnet é uma subdivisão da VPC utilizada para separar recursos da rede.

Diferenças:

- Subnet Pública possui acesso à Internet;
- Subnet Privada não possui acesso direto à Internet.

---

### b)
Componentes:

- Internet Gateway (IGW): conecta a VPC à Internet;
- Network ACL (NACL): controla tráfego em nível de subnet.

---

# Questão 4: Instâncias EC2

### a)
O nome da imagem do sistema operacional utilizada no EC2 é:

**AMI (Amazon Machine Image)**

---

### b)
Comando SSH:

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67

# Evidências

## AWS CLI
![AWS CLI](aws-version.png)

## AWS Configure
![AWS Configure](aws-configure-list.png)

## LocalStack
![LocalStack](docker-localstack.png)

## Health Check
![Health](localstack-health.png)

## Bucket S3
![Bucket](bucket-criado.png)

## EC2
![EC2](ec2-criada.png)