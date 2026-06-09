# Comandos AWS - TF011

Aluno: Andreyh Rodrigues de Souza  
RA: 6325231

## Configuracao e validacao inicial

```bash
aws configure list
```

```bash
aws rds describe-db-instances --region us-east-2
```

```bash
psql --version
```

## S3

```bash
touch db_config.conf
echo "DB_ENGINE=postgres" > db_config.conf
```

```bash
aws s3 mb s3://config-app-tf11 --region us-east-2
```

```bash
aws s3 cp db_config.conf s3://config-app-tf11/db_config.conf
```

```bash
aws s3 ls s3://config-app-tf11/
```

## RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325231 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --allocated-storage 20 \
  --storage-type gp2 \
  --master-username postgres \
  --master-user-password "<senha-forte>" \
  --db-name tf011db \
  --backup-retention-period 7 \
  --publicly-accessible \
  --no-multi-az \
  --region us-east-2
```

```bash
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325231 \
  --query "DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,Endpoint.Port]" \
  --output table \
  --region us-east-2
```

```bash
aws rds wait db-instance-available \
  --db-instance-identifier rds-tf011-6325231 \
  --region us-east-2
```

```bash
export RDS_ENDPOINT="<endpoint-rds>"
echo $RDS_ENDPOINT
```

## Snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325231 \
  --db-snapshot-identifier snapshot-tf011-6325231 \
  --region us-east-2
```

## Limpeza apos a entrega

```bash
aws rds delete-db-snapshot \
  --db-snapshot-identifier snapshot-tf011-6325231 \
  --region us-east-2
```

```bash
aws rds delete-db-instance \
  --db-instance-identifier rds-tf011-6325231 \
  --skip-final-snapshot \
  --delete-automated-backups \
  --region us-east-2
```

```bash
aws s3 rm s3://config-app-tf11/db_config.conf
aws s3 rb s3://config-app-tf11
```
