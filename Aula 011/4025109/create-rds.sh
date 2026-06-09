#!/bin/bash
# Script de Criação de RDS PostgreSQL
# Questão 6 - TF011
# RA: 4025109

set -e  # Parar em caso de erro

echo "=========================================="
echo "Script de Criação de RDS PostgreSQL"
echo "=========================================="

# Variáveis
DB_INSTANCE="rds-tf011-4025109"
DB_CLASS="db.t3.micro"
DB_ENGINE="postgres"
DB_ENGINE_VERSION="14.7"
DB_USER="admin"
DB_PASSWORD="TempPassword123!"
DB_STORAGE=20
DB_REGION="us-east-1"
SNAPSHOT_ID="snapshot-tf011-4025109"

# Passo 1: Verificar AWS CLI
echo ""
echo "[PASSO 1] Verificando AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não está instalado!"
    echo "Instale com: sudo apt-get install awscli"
    exit 1
fi

echo "✅ AWS CLI instalado:"
aws --version

# Passo 2: Verificar credenciais
echo ""
echo "[PASSO 2] Verificando credenciais AWS..."
aws configure list

echo "⚠️  Certifique-se de que as credenciais estão configuradas!"
echo "Configure com: aws configure"

# Passo 3: Criar instância RDS
echo ""
echo "[PASSO 3] Criando instância RDS PostgreSQL..."
echo "Instance ID: $DB_INSTANCE"
echo "Class: $DB_CLASS"
echo "Engine: $DB_ENGINE $DB_ENGINE_VERSION"

aws rds create-db-instance \
    --db-instance-identifier "$DB_INSTANCE" \
    --db-instance-class "$DB_CLASS" \
    --engine "$DB_ENGINE" \
    --engine-version "$DB_ENGINE_VERSION" \
    --master-username "$DB_USER" \
    --master-user-password "$DB_PASSWORD" \
    --allocated-storage "$DB_STORAGE" \
    --storage-type gp2 \
    --publicly-accessible \
    --backup-retention-period 7 \
    --multi-az \
    --region "$DB_REGION" \
    --output table

if [ $? -eq 0 ]; then
    echo "✅ Instância RDS criada com sucesso!"
else
    echo "⚠️  A instância pode já existir ou houve um erro."
fi

# Passo 4: Monitorar criação
echo ""
echo "[PASSO 4] Monitorando criação da instância..."
echo "Aguardando até 10 minutos para a instância ficar pronta..."
echo ""

COUNTER=0
MAX_ATTEMPTS=60

while [ $COUNTER -lt $MAX_ATTEMPTS ]; do
    STATUS=$(aws rds describe-db-instances \
        --db-instance-identifier "$DB_INSTANCE" \
        --region "$DB_REGION" \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text 2>/dev/null || echo "creating")
    
    echo "Status: $STATUS (Tentativa $((COUNTER+1))/$MAX_ATTEMPTS)"
    
    if [ "$STATUS" = "available" ]; then
        echo "✅ Instância disponível!"
        break
    fi
    
    COUNTER=$((COUNTER+1))
    sleep 10
done

if [ $COUNTER -ge $MAX_ATTEMPTS ]; then
    echo "⏳ Tempo de espera excedido. Instância ainda está sendo criada."
    echo "Continue verificando com:"
    echo "aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE --region $DB_REGION"
fi

# Passo 5: Extrair endpoint
echo ""
echo "[PASSO 5] Extraindo informações da instância..."

ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier "$DB_INSTANCE" \
    --region "$DB_REGION" \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

echo "✅ Endpoint: $ENDPOINT"

# Salvar em arquivo de configuração
cat > rds-config.env << EOF
# Configuração do RDS - RA: 4025109
export RDS_INSTANCE=$DB_INSTANCE
export RDS_ENDPOINT=$ENDPOINT
export RDS_PORT=5432
export RDS_USER=$DB_USER
export RDS_PASSWORD=$DB_PASSWORD
export RDS_DATABASE=postgres
export RDS_REGION=$DB_REGION
EOF

echo "✅ Configuração salva em rds-config.env"

# Passo 6: Instruções de conexão
echo ""
echo "=========================================="
echo "Próximos Passos:"
echo "=========================================="
echo ""
echo "1. Carregar variáveis de ambiente:"
echo "   source rds-config.env"
echo ""
echo "2. Conectar via psql:"
echo "   psql -h $ENDPOINT -U $DB_USER -d postgres"
echo "   Senha: $DB_PASSWORD"
echo ""
echo "3. Ou usar DBeaver:"
echo "   - File → New Database Connection"
echo "   - PostgreSQL"
echo "   - Server Host: $ENDPOINT"
echo "   - Port: 5432"
echo "   - Username: $DB_USER"
echo "   - Password: $DB_PASSWORD"
echo ""
echo "4. Criar tabela (após conectar):"
echo "   psql -h $ENDPOINT -U $DB_USER -d postgres -f create-table.sql"
echo ""
echo "5. Inserir dados:"
echo "   psql -h $ENDPOINT -U $DB_USER -d postgres -f insert-data.sql"
echo ""
echo "6. Criar snapshot (backup):"
echo "   aws rds create-db-snapshot \\"
echo "       --db-instance-identifier $DB_INSTANCE \\"
echo "       --db-snapshot-identifier $SNAPSHOT_ID \\"
echo "       --region $DB_REGION"
echo ""
echo "=========================================="
echo ""
