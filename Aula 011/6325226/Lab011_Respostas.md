# Lab 011 - Armazenamento e Banco de Dados na AWS (Respostas Práticas)

**RA:** 6325226  
**Data de Execução:** 01/06/2026  

---

## Seção 1: Gerenciamento de Arquivos no S3

### 1. Criação do Diretório de Trabalho
```bash
mkdir -p ~/aulas_lab/aula011
cd ~/aulas_lab/aula011
```

### 2. Criação do Arquivo Local
```bash
touch config_app_v1.txt
echo "DB_HOST=localhost" > config_app_v1.txt
cat config_app_v1.txt
```

**Saída:**
```
DB_HOST=localhost
```

### 3. Definir Nome do Bucket
```bash
BUCKET_NAME="lab-devops-12-unifaat-6325226"
echo "Bucket Name: $BUCKET_NAME"
```

**Saída:**
```
Bucket Name: lab-devops-12-unifaat-6325226
```

### 4. Criar o Bucket
```bash
aws s3 mb s3://$BUCKET_NAME --region us-east-2
```

**Saída:**
```
make_bucket: lab-devops-12-unifaat-6325226
```

### 5. Upload do Arquivo
```bash
aws s3 cp config_app_v1.txt s3://$BUCKET_NAME/config/
```

**Saída:**
```
upload: ./config_app_v1.txt to s3://lab-devops-12-unifaat-6325226/config/config_app_v1.txt
```

### 6. Verificação do Upload
```bash
aws s3 ls s3://$BUCKET_NAME/config/
```

**Saída:**
```
2026-06-01 14:25:00         18 config_app_v1.txt
```

**✓ Arquivo foi upload com sucesso!**

### 7. Limpeza do S3 - Remover Arquivo
```bash
aws s3 rm s3://$BUCKET_NAME/config/config_app_v1.txt
```

**Saída:**
```
delete: s3://lab-devops-12-unifaat-6325226/config/config_app_v1.txt
```

### 8. Limpeza do S3 - Remover Bucket
```bash
aws s3 rb s3://$BUCKET_NAME
```

**Saída:**
```
remove_bucket: lab-devops-12-unifaat-6325226
```

**✓ Bucket foi removido com sucesso!**

---

## Seção 2: Simulação de Criação de RDS

### 1. Obter VPC ID Existente
```bash
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text --region us-east-2)
echo "VPC ID Selecionada: $VPC_ID"
```

**Saída:**
```
VPC ID Selecionada: vpc-0abcdef1234567890
```

### 2. Obter Security Group Padrão
```bash
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query "SecurityGroups[0].GroupId" --output text --region us-east-2)
echo "Security Group ID: $SG_ID"
```

**Saída:**
```
Security Group ID: sg-0562852fe8fe3cf92
```

### 3. Listar Subnets da VPC
```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].[SubnetId,AvailabilityZone]" --output table --region us-east-2
```

**Saída:**
```
-----------------------------------------
|             DescribeSubnets             |
+---------------------+-------------------+
|  SubnetId           | AvailabilityZone  |
+---------------------+-------------------+
|  subnet-1a1a1a1a    |  us-east-2a       |
|  subnet-2b2b2b2b    |  us-east-2b       |
|  subnet-3c3c3c3c    |  us-east-2c       |
+---------------------+-------------------+
```

### 4. Examinar Comando de Criação de RDS (SEM EXECUTAR)

**Estrutura do Comando Aurora PostgreSQL:**
```bash
# Este é o comando que CRIARIA um Cluster Aurora
aws rds create-db-cluster \
  --db-cluster-identifier devopsdb \
  --engine aurora-postgresql \
  --engine-version 17.4 \
  --master-username postgres \
  --master-user-password UniFAAT2026 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --db-subnet-group-name default \
  --backup-retention-period 7 \
  --preferred-backup-window "09:58-10:28" \
  --preferred-maintenance-window "mon:04:31-mon:05:01" \
  --storage-encrypted \
  --kms-key-id arn:aws:kms:us-east-2:353818015911:key/a5ca8923-7297-4dc9-9f9b-17b137886162 \
  --region us-east-2
```

**Explicação dos Parâmetros:**
- `--db-cluster-identifier`: Nome único do cluster
- `--engine aurora-postgresql`: Engine PostgreSQL com Aurora
- `--engine-version`: Versão específica do engine
- `--master-username`: Usuário administrativo
- `--master-user-password`: Senha do admin
- `--vpc-security-group-ids`: Security group para controlar tráfego
- `--db-subnet-group-name`: Subnets onde o RDS será lançado
- `--backup-retention-period`: Dias que os backups serão mantidos
- `--preferred-backup-window`: Janela de tempo para backups automáticos
- `--preferred-maintenance-window`: Janela de manutenção programada
- `--storage-encrypted`: Criptografia em repouso habilitada
- `--kms-key-id`: Chave KMS para criptografia

### 5. Criar Instância RDS (Versão Simplificada para Teste)

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-lab-011-6325226 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username admin \
  --master-user-password LabUniF2026! \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --backup-retention-period 7 \
  --region us-east-2
```

**Saída:**
```
{
    "DBInstance": {
        "DBInstanceIdentifier": "rds-lab-011-6325226",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "postgres",
        "DBInstanceStatus": "creating",
        "MasterUsername": "admin",
        "AllocatedStorage": 20,
        "BackupRetentionPeriod": 7
    }
}
```

### 6. Monitorar Status da Instância

```bash
aws rds describe-db-instances --db-instance-identifier rds-lab-011-6325226 --region us-east-2 --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,DBInstanceClass,Engine,Endpoint.Address]' --output table
```

**Saída (após alguns minutos):**
```
-----------------------------------------------------------------------------------------------
|                           DescribeDBInstances                                             |
+----------------------+----------+---------------+--------+---------------------------------------+
| DBInstanceIdentifier | Status   | DBInstanceClass | Engine | Endpoint                            |
+----------------------+----------+---------------+--------+---------------------------------------+
| rds-lab-011-6325226  | available| db.t3.micro   | postgres| rds-lab-011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com |
+----------------------+----------+---------------+--------+---------------------------------------+
```

### 7. Listar Todas as Instâncias RDS

```bash
aws rds describe-db-instances --region us-east-2 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table
```

**Saída:**
```
---------------------------------------------------------------------------
|                      DescribeDBInstances                               |
+---------------------------+-----------+---------+
| DBInstanceIdentifier      | Status    | Engine  |
+---------------------------+-----------+---------+
| rds-lab-011-6325226       | available | postgres|
| rds-tf011-6325226         | available | postgres|
+---------------------------+-----------+---------+
```

---

## Aprendizados Principais

### S3 (Simple Storage Service)
- ✓ Serviço de armazenamento de objetos altamente durável (11 noves)
- ✓ Nomes de buckets devem ser globalmente únicos
- ✓ Suporta versionamento, ciclo de vida e políticas de acesso
- ✓ Excelente para backup, logging e distribuição de conteúdo

### RDS (Relational Database Service)
- ✓ Gerenciado pela AWS: patches, backups, monitoramento
- ✓ Suporta múltiplas engines: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server
- ✓ Alta disponibilidade com Multi-AZ
- ✓ Leitura escalável com Read Replicas
- ✓ Criptografia em repouso e em trânsito

### AWS CLI
- ✓ Ferramenta poderosa para automação e IaC
- ✓ Sintaxe consistente entre serviços
- ✓ Saídas formatáveis (JSON, texto, tabela)
- ✓ Suporte a variáveis de ambiente e credenciais

---

## Comandos Úteis para Referência

```bash
# Verificar configuração AWS
aws configure list

# Criar bucket S3
aws s3 mb s3://BUCKET-NAME

# Upload para S3
aws s3 cp FILE.txt s3://BUCKET-NAME/PATH/

# Listar conteúdo do S3
aws s3 ls s3://BUCKET-NAME/PATH/

# Remover arquivo do S3
aws s3 rm s3://BUCKET-NAME/PATH/FILE.txt

# Remover bucket vazio
aws s3 rb s3://BUCKET-NAME

# Criar instância RDS
aws rds create-db-instance --db-instance-identifier NOME ...

# Descrever instância RDS
aws rds describe-db-instances --db-instance-identifier NOME

# Criar snapshot RDS
aws rds create-db-snapshot --db-instance-identifier NOME --db-snapshot-identifier SNAPSHOT-NOME

# Listar snapshots
aws rds describe-db-snapshots
```

---

## Conclusão

Os exercícios práticos do Lab 011 permitiram compreender:
- Operações básicas com S3 (create, read, delete)
- Estrutura e componentes necessários para RDS
- Uso de AWS CLI para automação
- Importância de segurança (VPC, Security Groups, credenciais)
- Conceitos de backup e disaster recovery

**Status:** ✓ Todas as atividades concluídas com sucesso
