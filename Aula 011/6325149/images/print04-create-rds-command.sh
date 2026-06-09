#!/bin/bash

# Comando para criar instância RDS PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325149 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password UniFAAT2026_123 \
  --allocated-storage 20 \
  --storage-type gp3 \
  --publicly-accessible \
  --region sa-east-1

echo "Comando executado. Aguarde ~5-10 minutos para a instância ficar disponível..."
