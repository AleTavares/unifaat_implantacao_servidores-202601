#!/bin/bash
#############################################
# cleanup.sh - Limpeza completa do Lab 014
# Curso: ADS UniFAAT - Implantação de Servidores
# Remove recursos de monitoramento criados no lab
#############################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  CLEANUP LAB 014 - MONITORAMENTO EKS      ${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""

# Variáveis (mesmas do lab)
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-123123123123}"
AWS_REGION="${AWS_REGION:-us-east-2}"
CLUSTER_NAME="${CLUSTER_NAME:-cluster-eks-ads}"
NAMESPACE="ads-unifaat"
LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"

echo -e "${YELLOW}Configuração:${NC}"
echo "  Account ID:  $AWS_ACCOUNT_ID"
echo "  Region:      $AWS_REGION"
echo "  Cluster:     $CLUSTER_NAME"
echo "  Log Group:   $LOG_GROUP"
echo ""

read -p "Confirma a limpeza dos recursos de MONITORAMENTO? (s/N): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "Cancelado."
    exit 0
fi

echo ""

# Função helper
step() { echo -e "${GREEN}[STEP]${NC} $1"; }
skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

#############################################
# 1. CLOUDWATCH ALARMS
#############################################
step "Removendo alarmes CloudWatch..."

aws cloudwatch delete-alarms \
  --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods" \
  --region $AWS_REGION 2>/dev/null && echo "  Alarmes removidos" || skip "Alarmes não encontrados"

#############################################
# 2. CLOUDWATCH DASHBOARD
#############################################
step "Removendo dashboard..."

aws cloudwatch delete-dashboards \
  --dashboard-names "EKS-ADS-Dashboard" \
  --region $AWS_REGION 2>/dev/null && echo "  Dashboard removido" || skip "Dashboard não encontrado"

#############################################
# 3. CLOUDWATCH LOG GROUPS
#############################################
step "Removendo Log Groups..."

aws logs delete-log-group \
  --log-group-name "$LOG_GROUP" \
  --region $AWS_REGION 2>/dev/null && echo "  $LOG_GROUP removido" || skip "$LOG_GROUP não encontrado"

aws logs delete-log-group \
  --log-group-name "/aws/eks/$CLUSTER_NAME/cluster" \
  --region $AWS_REGION 2>/dev/null && echo "  /aws/eks/$CLUSTER_NAME/cluster removido" || true

#############################################
# 4. KUBERNETES - NAMESPACE DE MONITORAMENTO
#############################################
step "Removendo namespace amazon-cloudwatch (Fluent Bit + Agent)..."

if kubectl get namespace amazon-cloudwatch &>/dev/null; then
    kubectl delete namespace amazon-cloudwatch
    echo "  Namespace amazon-cloudwatch removido"
else
    skip "Namespace amazon-cloudwatch não encontrado"
fi

#############################################
# 5. IAM - POLÍTICA INLINE
#############################################
step "Removendo política IAM inline (CloudWatchLogsAccess)..."

aws iam delete-role-policy \
  --role-name EKSNodeRole-ADS \
  --policy-name CloudWatchLogsAccess 2>/dev/null && echo "  Política removida" || skip "Política não encontrada"

#############################################
# 6. ARQUIVOS LOCAIS
#############################################
step "Removendo arquivos locais do lab..."

rm -f cloudwatch-policy.json query-recent.txt query-errors.txt query-requests.txt load-test.sh 2>/dev/null
echo "  Arquivos removidos"

#############################################
# VERIFICAÇÃO FINAL
#############################################
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}         VERIFICAÇÃO FINAL                  ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

echo "Alarmes restantes (prefixo EKS-ADS):"
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-ADS" \
  --query 'MetricAlarms[].AlarmName' \
  --output text --region $AWS_REGION 2>/dev/null || echo "  Nenhum"

echo ""
echo "Log Groups do cluster:"
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/eks/$CLUSTER_NAME" \
  --query 'logGroups[].logGroupName' \
  --output text --region $AWS_REGION 2>/dev/null || echo "  Nenhum"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ LIMPEZA DO LAB 014 CONCLUÍDA!          ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  NOTA: O cluster EKS ainda está rodando.${NC}"
echo -e "${YELLOW}   Para limpar o cluster completo, use:${NC}"
echo -e "${YELLOW}   ../Aula 013/cleanup.sh${NC}"
echo ""

read -p "Deseja também remover o cluster EKS e toda a infraestrutura criada pelo start.sh? (s/N): " CONFIRM_FULL
if [[ "$CONFIRM_FULL" != "s" && "$CONFIRM_FULL" != "S" ]]; then
    echo "Apenas monitoramento foi limpo. Cluster EKS continua rodando."
    exit 0
fi

echo ""
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  LIMPEZA COMPLETA - INFRAESTRUTURA EKS     ${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""

#############################################
# 7. KUBERNETES RESOURCES
#############################################
step "Removendo recursos Kubernetes (namespace da aplicação)..."

if kubectl get namespace $NAMESPACE &>/dev/null; then
    kubectl delete svc ads-site-service -n $NAMESPACE 2>/dev/null || true
    kubectl delete deployment ads-site -n $NAMESPACE 2>/dev/null || true
    kubectl delete namespace $NAMESPACE 2>/dev/null || true
    echo "  Namespace $NAMESPACE removido"
else
    skip "Namespace $NAMESPACE não encontrado"
fi

#############################################
# 8. EKS NODE GROUP
#############################################
step "Removendo Node Group..."

NODEGROUP_NAME="ads-app-nodes"

if aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $AWS_REGION &>/dev/null; then
    aws eks delete-nodegroup \
        --cluster-name $CLUSTER_NAME \
        --nodegroup-name $NODEGROUP_NAME \
        --region $AWS_REGION

    echo "  Aguardando exclusão do Node Group (~5 min)..."
    aws eks wait nodegroup-deleted \
        --cluster-name $CLUSTER_NAME \
        --nodegroup-name $NODEGROUP_NAME \
        --region $AWS_REGION 2>/dev/null || true
    echo "  Node Group deletado"
else
    skip "Node Group $NODEGROUP_NAME não encontrado"
fi

#############################################
# 9. EKS CLUSTER
#############################################
step "Removendo Cluster EKS..."

if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION &>/dev/null; then
    aws eks delete-cluster --name $CLUSTER_NAME --region $AWS_REGION

    echo "  Aguardando exclusão do Cluster (~5 min)..."
    aws eks wait cluster-deleted --name $CLUSTER_NAME --region $AWS_REGION 2>/dev/null || true
    echo "  Cluster deletado"
else
    skip "Cluster $CLUSTER_NAME não encontrado"
fi

#############################################
# 10. CLOUDFORMATION (VPC)
#############################################
step "Removendo VPC (CloudFormation stack)..."

STACK_NAME="eks-vpc-ads"

if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION &>/dev/null; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION

    echo "  Aguardando exclusão da VPC..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $AWS_REGION 2>/dev/null || true
    echo "  VPC removida"
else
    skip "Stack $STACK_NAME não encontrada"
fi

#############################################
# 11. IAM ROLES
#############################################
step "Removendo IAM Roles..."

# EKSClusterRole-ADS
if aws iam get-role --role-name EKSClusterRole-ADS &>/dev/null; then
    aws iam detach-role-policy \
        --role-name EKSClusterRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy 2>/dev/null || true
    aws iam delete-role --role-name EKSClusterRole-ADS 2>/dev/null || true
    echo "  EKSClusterRole-ADS removida"
else
    skip "EKSClusterRole-ADS não encontrada"
fi

# EKSNodeRole-ADS
if aws iam get-role --role-name EKSNodeRole-ADS &>/dev/null; then
    aws iam detach-role-policy --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy 2>/dev/null || true
    aws iam detach-role-policy --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy 2>/dev/null || true
    aws iam detach-role-policy --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly 2>/dev/null || true
    aws iam delete-role --role-name EKSNodeRole-ADS 2>/dev/null || true
    echo "  EKSNodeRole-ADS removida"
else
    skip "EKSNodeRole-ADS não encontrada"
fi

#############################################
# 12. ECR REPOSITORY
#############################################
step "Removendo repositório ECR..."

REPO_NAME="ads-unifaat-site"

if aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION &>/dev/null; then
    aws ecr delete-repository \
        --repository-name $REPO_NAME \
        --region $AWS_REGION \
        --force
    echo "  Repositório $REPO_NAME removido"
else
    skip "Repositório $REPO_NAME não encontrado"
fi

#############################################
# 13. DOCKER LOCAL
#############################################
step "Limpando imagens Docker locais..."

IMAGE_TAG="v1.0"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

docker rmi $REPO_NAME:$IMAGE_TAG 2>/dev/null && echo "  Removida $REPO_NAME:$IMAGE_TAG" || true
docker rmi $REPO_URI:$IMAGE_TAG 2>/dev/null && echo "  Removida $REPO_URI:$IMAGE_TAG" || true

#############################################
# 14. ARQUIVOS LOCAIS DO LAB 013
#############################################
step "Removendo diretório do lab..."

if [ -d ~/aulas_lab/aula013 ]; then
    rm -rf ~/aulas_lab/aula013
    echo "  ~/aulas_lab/aula013 removido"
else
    skip "Diretório ~/aulas_lab/aula013 não encontrado"
fi

#############################################
# VERIFICAÇÃO FINAL COMPLETA
#############################################
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}     VERIFICAÇÃO FINAL (COMPLETA)           ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

echo "Clusters EKS:"
aws eks list-clusters --region $AWS_REGION --query 'clusters' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo "Repositórios ECR:"
aws ecr describe-repositories --region $AWS_REGION --query 'repositories[].repositoryName' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo "Stacks CloudFormation:"
aws cloudformation list-stacks --region $AWS_REGION \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --query 'StackSummaries[].StackName' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ LIMPEZA TOTAL CONCLUÍDA!               ${NC}"
echo -e "${GREEN}============================================${NC}"
