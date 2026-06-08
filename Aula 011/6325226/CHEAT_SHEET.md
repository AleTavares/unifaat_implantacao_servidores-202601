# Cheat Sheet - Lab 011 e TF 011
**RA:** 6325226  
**Referência Rápida de Comandos**

---

## AWS CLI - Configuração Inicial

```bash
# Configurar credenciais
aws configure

# Verificar configuração
aws configure list

# Definir região específica
export AWS_REGION=us-east-2
```

---

## S3 - Gerenciamento de Buckets

### Criar Bucket
```bash
# Criar bucket
BUCKET_NAME="lab-devops-12-unifaat-6325226"
aws s3 mb s3://$BUCKET_NAME --region us-east-2

# Com versionamento habilitado
aws s3 mb s3://$BUCKET_NAME && \
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

### Listar Buckets
```bash
# Listar todos os buckets
aws s3 ls

# Listar com detalhes (data/hora)
aws s3api list-buckets --query 'Buckets[*].[Name,CreationDate]' --output table
```

### Gerenciar Objetos
```bash
# Upload de arquivo
aws s3 cp config_app_v1.txt s3://$BUCKET_NAME/config/

# Upload recursivo (diretório)
aws s3 cp ./local_folder s3://$BUCKET_NAME/remote_folder --recursive

# Download de arquivo
aws s3 cp s3://$BUCKET_NAME/config/config_app_v1.txt ./

# Sincronizar diretórios
aws s3 sync ./local_folder s3://$BUCKET_NAME/remote_folder
```

### Listar Conteúdo
```bash
# Listar bucket raiz
aws s3 ls s3://$BUCKET_NAME

# Listar subdiretório
aws s3 ls s3://$BUCKET_NAME/config/

# Listar recursivo com tamanho
aws s3 ls s3://$BUCKET_NAME --recursive --human-readable --summarize
```

### Remover Objetos
```bash
# Remover arquivo
aws s3 rm s3://$BUCKET_NAME/config/config_app_v1.txt

# Remover recursivo (diretório)
aws s3 rm s3://$BUCKET_NAME/config/ --recursive

# Remover bucket vazio
aws s3 rb s3://$BUCKET_NAME

# Remover bucket com conteúdo
aws s3 rb s3://$BUCKET_NAME --force
```

---

## EC2 - Redes e Segurança

### VPC e Subnets
```bash
# Obter VPC padrão
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)
echo "VPC ID: $VPC_ID"

# Listar todas as VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]' --output table

# Listar subnets de uma VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]' --output table
```

### Security Groups
```bash
# Obter security group padrão
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" \
  --query "SecurityGroups[0].GroupId" --output text)
echo "Security Group: $SG_ID"

# Listar security groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName]' --output table

# Ver regras do security group
aws ec2 describe-security-groups --group-ids $SG_ID \
  --query 'SecurityGroups[0].[IpPermissions,IpPermissionsEgress]' --output table

# Adicionar regra de entrada (PostgreSQL)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 5432 \
  --cidr 0.0.0.0/0
```

---

## RDS - Gerenciamento de Banco de Dados

### Criar Instância RDS

#### PostgreSQL Simples
```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password UniFAAT2026! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --backup-retention-period 7 \
  --region us-east-2
```

#### PostgreSQL com Multi-AZ
```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password UniFAAT2026! \
  --allocated-storage 20 \
  --multi-az \
  --backup-retention-period 7 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --region us-east-2
```

#### Aurora PostgreSQL
```bash
# Criar cluster
aws rds create-db-cluster \
  --db-cluster-identifier devopsdb-cluster \
  --engine aurora-postgresql \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password UniFAAT2026! \
  --backup-retention-period 7 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --region us-east-2

# Criar instância no cluster
aws rds create-db-instance \
  --db-instance-identifier devopsdb-instance-1 \
  --db-instance-class db.t3.small \
  --engine aurora-postgresql \
  --db-cluster-identifier devopsdb-cluster \
  --region us-east-2
```

### Listar Instâncias RDS

```bash
# Listar todas as instâncias
aws rds describe-db-instances --output table

# Listar instância específica
aws rds describe-db-instances --db-instance-identifier rds-tf011-6325226

# Formato compacto
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass]' \
  --output table
```

### Obter Endpoint

```bash
# Obter endpoint completo
RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325226 \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)
echo "Endpoint: $RDS_ENDPOINT"

# Obter endpoint e porta
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325226 \
  --query 'DBInstances[0].[Endpoint.Address,Endpoint.Port]' \
  --output text
```

### Modificar Instância

```bash
# Aumentar espaço de armazenamento
aws rds modify-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --allocated-storage 100 \
  --apply-immediately

# Mudar classe de instância
aws rds modify-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --db-instance-class db.t3.small \
  --apply-immediately

# Ativar Multi-AZ
aws rds modify-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --multi-az \
  --apply-immediately
```

### Backups e Snapshots

```bash
# Criar snapshot manual
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325226 \
  --db-snapshot-identifier snapshot-tf011-6325226

# Listar snapshots
aws rds describe-db-snapshots \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,SnapshotCreateTime,SnapshotStatus]' \
  --output table

# Descrever snapshot específico
aws rds describe-db-snapshots \
  --db-snapshot-identifier snapshot-tf011-6325226

# Restaurar a partir de snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier rds-tf011-restored \
  --db-snapshot-identifier snapshot-tf011-6325226

# Listar backups automáticos
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325226 \
  --query 'DBInstances[0].[BackupRetentionPeriod,LatestRestorableTime]'
```

### Read Replicas

```bash
# Criar read replica (mesma região)
aws rds create-db-instance-read-replica \
  --db-instance-identifier rds-tf011-6325226-replica \
  --source-db-instance-identifier rds-tf011-6325226

# Criar read replica (outra região)
aws rds create-db-instance-read-replica \
  --db-instance-identifier rds-tf011-6325226-replica-us-west-2 \
  --source-db-instance-identifier arn:aws:rds:us-east-2:ACCOUNT:db:rds-tf011-6325226 \
  --region us-west-2

# Promover read replica para instância autônoma
aws rds promote-read-replica \
  --db-instance-identifier rds-tf011-6325226-replica
```

### Deletar Instância

```bash
# Deletar com snapshot final
aws rds delete-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --final-db-snapshot-identifier final-snapshot-tf011-6325226

# Deletar sem snapshot
aws rds delete-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --skip-final-snapshot

# Deletar snapshot
aws rds delete-db-snapshot \
  --db-snapshot-identifier snapshot-tf011-6325226
```

### Monitoramento

```bash
# Listar eventos RDS
aws rds describe-events \
  --query 'Events[*].[SourceIdentifier,EventCategories,Message,Date]' \
  --output table

# Eventos de uma instância específica
aws rds describe-events \
  --source-identifier rds-tf011-6325226 \
  --query 'Events[*].[Message,Date]' \
  --output table

# Métricas do CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=rds-tf011-6325226 \
  --start-time 2026-06-01T00:00:00Z \
  --end-time 2026-06-02T00:00:00Z \
  --period 3600 \
  --statistics Average,Maximum
```

---

## PostgreSQL - Conectividade e Operações

### Conectar via psql

```bash
# Conexão básica
psql -h $RDS_ENDPOINT -U postgres -d postgres

# Com variáveis
PGHOST=$RDS_ENDPOINT
PGUSER=postgres
PGPASSWORD=UniFAAT2026!
PGDATABASE=postgres
export PGHOST PGUSER PGPASSWORD PGDATABASE
psql

# Tudo em um comando
psql -h rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com \
     -U postgres \
     -d postgres \
     -c "SELECT version();"
```

### Operações Básicas no PostgreSQL

```sql
-- Conectar a um banco de dados específico
\c unifaat_db

-- Listar bancos de dados
\l

-- Listar tabelas
\dt

-- Descrever tabela
\d alunos

-- Criar banco de dados
CREATE DATABASE unifaat_db;

-- Criar tabela
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    ra VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo'))
);

-- Inserir dados
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');

-- Consultar dados
SELECT * FROM alunos;

-- Atualizar dados
UPDATE alunos SET status = 'inativo' WHERE ra = '6325128';

-- Deletar dados
DELETE FROM alunos WHERE ra = '6325130';

-- Sair do psql
\q
```

---

## DBeaver - Operações Frequentes

### Criar Conexão
```
File → New Database Connection → PostgreSQL
  Server Host: [endpoint RDS]
  Port: 5432
  Database: postgres
  Username: postgres
  Password: [senha]
  Test Connection → Finish
```

### Executar SQL
```
Ctrl+Enter (ou clique em ▶) para executar a query
```

### Criar Tabela via UI
```
Conectar → Databases → postgres → Schemas → public → Tables (direito) → New Table
```

### Exportar Dados
```
Resultado → direito → Export → Escolher formato (SQL, CSV, JSON, etc)
```

### Criar Backup
```
Database → Backup → Escolher tabelas/BD → Execute
```

---

## Dicas Importantes

### Segurança
- ✓ Nunca commitar credenciais em Git
- ✓ Usar credenciais IAM ao invés de user/password
- ✓ Habilitar SSL/TLS para conexões RDS
- ✓ Configurar security groups restritivos
- ✓ Usar parameter store/secrets manager

### Performance
- ✓ Usar read replicas para distribuir carga de leitura
- ✓ Habilitar Multi-AZ para alta disponibilidade
- ✓ Monitorar métricas no CloudWatch
- ✓ Usar indexes apropriados
- ✓ Fazer backups regularmente

### Custo
- ✓ Usar db.t3.micro para desenvolvimento (free tier eligible)
- ✓ Deletar instâncias não utilizadas
- ✓ Usar snapshots ao invés de manter instâncias de backup
- ✓ Configurar retenção de backups apropriada

---

## Variáveis de Ambiente Úteis

```bash
# Adicionar ao ~/.bashrc ou ~/.bash_profile
export AWS_REGION="us-east-2"
export RDS_ENDPOINT="rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com"
export RDS_PORT="5432"
export RDS_USER="postgres"
export RDS_DBNAME="postgres"
# NÃO EXPOR SENHA EM VARIÁVEIS DE AMBIENTE

# Alias úteis
alias aws-status='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]" --output table'
alias rds-endpoint='aws rds describe-db-instances --db-instance-identifier rds-tf011-6325226 --query "DBInstances[0].Endpoint.Address" --output text'
```

---

**Atualizado:** 01/06/2026  
**RA:** 6325226
