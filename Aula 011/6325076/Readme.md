# TF Aula 11 - Armazenamento e Banco de Dados na AWS

Aluno:Pablo Augusto
RA: 6325128

Questão 1 - Amazon S3

a)

O principal caso de uso do Amazon S3 é o armazenamento de objetos, como arquivos estáticos de aplicações web, backups, logs, imagens, vídeos e documentos.

b)

O Amazon S3 é um serviço regional.

A taxa de "Onze Noves" (99,999999999%) refere-se à durabilidade dos dados armazenados.

---

## Questão 2 - EBS e EFS

### a)

O Amazon EBS é um armazenamento em blocos conectado a uma instância EC2 específica.

O Amazon EFS é um sistema de arquivos compartilhado que pode ser acessado simultaneamente por várias instâncias EC2.

### b)

Para armazenar o sistema operacional e os arquivos da aplicação, o mais adequado é o **Amazon EBS**, pois oferece armazenamento persistente em blocos com baixa latência.

---

## Questão 3 - Amazon RDS

### a)

Duas responsabilidades assumidas pela AWS ao utilizar o RDS são:

* Aplicação de patches e atualizações do banco de dados.
* Realização de backups automáticos.

### b)

A principal desvantagem é a menor liberdade administrativa, pois não há acesso total ao sistema operacional do servidor de banco de dados.

---

## Questão 4 - Alta Disponibilidade no RDS

### a)

Ao habilitar o Multi-AZ, a AWS cria automaticamente uma instância de standby em outra Availability Zone e replica os dados de forma síncrona.

### b)

**Multi-AZ Standby:** utilizado para alta disponibilidade e failover automático.

**Read Replica:** utilizada para leitura e escalabilidade, sem failover automático.

---

## Questão 5 - Simulação AWS CLI

### 1. Criação do Arquivo

```bash
touch db_config.conf
```

### 2. Upload para o S3

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### 3. Verificação do Upload

```bash
aws s3 ls s3://config-app-tf11/
```

---

## Questão 6 - Evidências Práticas

### Evidência 1 - Configuração AWS

Comando utilizado:

```bash
aws configure list
```

### Evidência 2 - Teste de Conectividade RDS

```bash
aws rds describe-db-instances
```

### Evidência 3 - Cliente PostgreSQL

```bash
psql --version
```

### Evidência 4 - Variável de Ambiente

```bash
echo $RDS_ENDPOINT
```

### Evidência 5 - Criação da Instância RDS

```bash
aws rds create-db-instance \
--db-instance-identifier rds-tf011-6325128 \
--db-instance-class db.t3.micro \
--engine postgres \
--master-username admin \
--master-user-password Senha123 \
--allocated-storage 20
```

### Evidência 6 - Verificação da Instância

```bash
aws rds describe-db-instances
```

### Evidência 7 - Snapshot

```bash
aws rds create-db-snapshot \
--db-instance-identifier rds-tf011-6325128 \
--db-snapshot-identifier snapshot-tf011-6325128
```

### Observações

Foram utilizados AWS CLI, PostgreSQL e DBeaver para gerenciamento do banco de dados e execução dos comandos solicitados.

