# TF - Aula 10  
## Disciplina: Implementação de Servidor e Nuvem (Cloud)

**Aluno:** Matheus Gabriel Correa Braga Viana  
**RA:** 6325053  

---

# Questão 1: Modelos de Serviço em Nuvem

## a) AWS EC2 representa qual modelo?

A AWS EC2 representa o modelo **IaaS (Infrastructure as a Service)**.

Nesse modelo, a AWS fornece a infraestrutura necessária, como:

- servidores  
- armazenamento  
- rede  
- virtualização  

A principal responsabilidade do usuário é:

- gerenciar o sistema operacional  
- instalar softwares  
- configurar aplicações  
- realizar atualizações  
- cuidar da segurança da aplicação  

Ou seja, o usuário gerencia a máquina virtual.

---

## b) Exemplo de SaaS ou PaaS

### Exemplo de PaaS:
- AWS Elastic Beanstalk  
- AWS RDS  

### Exemplo de SaaS:
- Amazon WorkDocs  

---

# Questão 2: IAM (Identity and Access Management)

## a) Diferença entre Usuário IAM e Grupo IAM

### Usuário IAM
É uma identidade individual criada para uma pessoa ou aplicação específica.

Cada usuário possui:

- login próprio  
- senha própria  
- permissões específicas  

---

### Grupo IAM
É um conjunto de usuários IAM.

Os grupos servem para:

- organizar usuários  
- aplicar permissões para vários usuários ao mesmo tempo  

Exemplo:

- Grupo Administradores  
- Grupo Desenvolvedores  

---

## b) Por que usar Role IAM?

É mais seguro usar uma **Role IAM** porque:

- utiliza credenciais temporárias  
- evita expor chaves permanentes  
- reduz riscos de vazamento  
- segue o princípio do menor privilégio  

Usar credenciais root ou administrador diretamente é perigoso e não recomendado.

---

# Questão 3: VPC

## a) O que é Subnet?

Subnet é uma subdivisão da rede dentro de uma VPC.

Ela organiza os recursos em diferentes partes da rede.

### Subnet Pública
Possui acesso direto à internet através de um Internet Gateway.

Exemplo:

- servidores web  

---

### Subnet Privada
Não possui acesso direto à internet.

Exemplo:

- banco de dados  
- servidores internos  

---

## b) Componentes de rede

### Para acessar a internet:
**Internet Gateway**

### Para inspecionar tráfego em nível de subnet:
**Network ACL (NACL)**

---

# Questão 4: EC2

## a) Nome da imagem do sistema operacional

O nome utilizado pela AWS é:

**AMI (Amazon Machine Image)**

Ela contém:

- sistema operacional  
- configurações básicas  
- softwares pré-instalados  

Exemplo:

- Ubuntu  
- Amazon Linux  
- Windows Server  

---

## b) Comando para conectar via SSH

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

Se for Ubuntu:

```bash
ssh -i minha_chave.pem ubuntu@54.123.45.67
```

---

# Questão 5: AWS CLI

## 1. Configurar credenciais

```bash
aws configure
```

---

## 2. Listar instâncias EC2

```bash
aws ec2 describe-instances
```

---

## 3. Criar bucket S3

```bash
aws s3 mb s3://meu-bucket-tf10 --region sa-east-1
```

---

## 4. Descrever VPCs

```bash
aws ec2 describe-vpcs
```

---

# Questão 6: Evidências Práticas

Foram executados os seguintes comandos práticos utilizando AWS CLI, Docker e LocalStack:

```bash
aws --version
```

```bash
aws configure list
```

```bash
docker run --rm -it -p 4566:4566 localstack/localstack:3.0
```

```bash
curl http://localhost:4566/_localstack/health
```

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf010-6325053
```

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

```bash
aws --endpoint-url=http://localhost:4566 ec2 run-instances --image-id ami-12345678 --instance-type t2.micro --count 1 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=TF010-6325053}]"
```

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

Todos os prints das execuções foram adicionados nesta pasta conforme solicitado no enunciado.

---

# Observações finais

Ferramentas utilizadas durante o laboratório:

- AWS CLI  
- Docker  
- LocalStack  
- AWS IAM  
- AWS S3  
- AWS EC2  
- AWS VPC  

A atividade demonstrou na prática o uso de infraestrutura em nuvem através de comandos em linha de comando.