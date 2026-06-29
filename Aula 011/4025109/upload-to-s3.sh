#!/bin/bash
# Script de Upload para S3
# Questão 5 - TF011
# RA: 4025109

set -e  # Parar em caso de erro

echo "=========================================="
echo "Script de Upload de Arquivo para S3"
echo "=========================================="

# Variáveis
CONFIG_FILE="db_config.conf"
BUCKET_NAME="config-app-tf11"
REGION="us-east-1"

# Passo 1: Criar arquivo de configuração
echo ""
echo "[PASSO 1] Criando arquivo de configuração..."

cat > "$CONFIG_FILE" << EOF
# Configuração de Banco de Dados
# Data: $(date +%Y-%m-%d)

DB_HOST=rds-tf011-4025109.c9akciq32.us-east-1.rds.amazonaws.com
DB_PORT=5432
DB_USER=admin
DB_NAME=postgres
DB_PASS=TempPassword123!
DB_POOL_SIZE=10
DB_TIMEOUT=30
EOF

echo "✅ Arquivo '$CONFIG_FILE' criado com sucesso!"
echo ""
echo "Conteúdo do arquivo:"
cat "$CONFIG_FILE"

# Passo 2: Fazer upload para S3
echo ""
echo "[PASSO 2] Fazendo upload para S3..."
echo "Bucket: s3://$BUCKET_NAME"
echo "Arquivo: $CONFIG_FILE"

aws s3 cp "$CONFIG_FILE" "s3://$BUCKET_NAME/$CONFIG_FILE" \
    --region "$REGION" \
    --sse AES256 \
    --metadata "version=1.0,ra=4025109,date=$(date +%Y-%m-%d)"

if [ $? -eq 0 ]; then
    echo "✅ Upload realizado com sucesso!"
else
    echo "❌ Erro ao fazer upload!"
    exit 1
fi

# Passo 3: Verificar arquivo no bucket
echo ""
echo "[PASSO 3] Verificando arquivo no bucket..."
echo ""
echo "Listando conteúdo de s3://$BUCKET_NAME:"
aws s3 ls "s3://$BUCKET_NAME/" --region "$REGION"

echo ""
echo "Detalhes do arquivo:"
aws s3api head-object \
    --bucket "$BUCKET_NAME" \
    --key "$CONFIG_FILE" \
    --region "$REGION" \
    --query '{Size: ContentLength, LastModified: LastModified, Metadata: Metadata}'

# Passo 4: Validação final
echo ""
echo "=========================================="
echo "✅ Processo concluído com sucesso!"
echo "=========================================="
echo ""
echo "Resumo:"
echo "- Arquivo criado: $CONFIG_FILE"
echo "- Bucket: s3://$BUCKET_NAME"
echo "- Região: $REGION"
echo "- Data: $(date)"
echo ""
echo "Para baixar o arquivo:"
echo "aws s3 cp s3://$BUCKET_NAME/$CONFIG_FILE . --region $REGION"
echo ""
