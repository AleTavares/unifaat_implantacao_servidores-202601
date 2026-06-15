#!/bin/bash
#############################################
# cleanup.sh - Limpeza completa do Lab 013
# Curso: ADS UniFAAT - Implantação de Servidores
# Remove todos os recursos AWS criados no lab
#############################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  CLEANUP LAB 013 - EKS + ECR + VPC + IAM  ${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""

# Variáveis (mesmas do lab)
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-123123123123}"
AWS_REGION="${AWS_REGION:-us-east-2}"
REPO_NAME="ads-unifaat-site"
IMAGE_TAG="v1.0"
CLUSTER_NAME="cluster-eks-ads"
NODEGROUP_NAME="ads-app-nodes"
STACK_NAME="eks-vpc-ads"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

echo -e "${YELLOW}Configuração:${NC}"
echo "  Account ID:  $AWS_ACCOUNT_ID"
echo "  Region:      $AWS_REGION"
echo "  Cluster:     $CLUSTER_NAME"
echo "  Node Group:  $NODEGROUP_NAME"
echo "  ECR Repo:    $REPO_NAME"
echo "  VPC Stack:   $STACK_NAME"
echo ""

read -p "Confirma a limpeza de TODOS esses recursos? (s/N): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "Cancelado."
    exit 0
fi

echo ""

# Função helper
step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

fail() {
    echo -e "${RED}[ERRO]${NC} $1 (continuando...)"
}

#############################################
# 1. KUBERNETES RESOURCES
#############################################
step "Removendo recursos Kubernetes..."

if kubectl get namespace ads-unifaat &>/dev/null; then
    kubectl delete svc ads-site-service -n ads-unifaat 2>/dev/null || true
    kubectl delete deployment ads-site -n ads-unifaat 2>/dev/null || true
    kubectl delete namespace ads-unifaat 2>/dev/null || true
    echo "  Namespace ads-unifaat removido"
else
    skip "Namespace ads-unifaat não encontrado"
fi

#############################################
# 2. EKS NODE GROUP
#############################################
step "Removendo Node Group..."

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
# 3. EKS CLUSTER
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
# 4. CLOUDFORMATION (VPC)
#############################################
step "Removendo VPC (CloudFormation stack)..."

if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION &>/dev/null; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION

    echo "  Aguardando exclusão da VPC..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $AWS_REGION 2>/dev/null || true
    echo "  VPC removida"
else
    skip "Stack $STACK_NAME não encontrada"
fi

#############################################
# 5. IAM ROLES
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
    aws iam detach-role-policy \
        --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy 2>/dev/null || true
    aws iam detach-role-policy \
        --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy 2>/dev/null || true
    aws iam detach-role-policy \
        --role-name EKSNodeRole-ADS \
        --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly 2>/dev/null || true
    aws iam delete-role --role-name EKSNodeRole-ADS 2>/dev/null || true
    echo "  EKSNodeRole-ADS removida"
else
    skip "EKSNodeRole-ADS não encontrada"
fi

#############################################
# 6. ECR REPOSITORY
#############################################
step "Removendo repositório ECR..."

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
# 7. DOCKER LOCAL
#############################################
step "Limpando imagens Docker locais..."

docker rmi ads-unifaat-site:$IMAGE_TAG 2>/dev/null && echo "  Removida ads-unifaat-site:$IMAGE_TAG" || true
docker rmi $REPO_URI:$IMAGE_TAG 2>/dev/null && echo "  Removida $REPO_URI:$IMAGE_TAG" || true
docker stop teste-ads 2>/dev/null && docker rm teste-ads 2>/dev/null && echo "  Container teste-ads removido" || true

#############################################
# 8. ARQUIVOS LOCAIS
#############################################
step "Removendo arquivos do lab..."

if [ -d ~/aulas_lab/aula013 ]; then
    rm -rf ~/aulas_lab/aula013
    echo "  ~/aulas_lab/aula013 removido"
else
    skip "Diretório ~/aulas_lab/aula013 não encontrado"
fi

#############################################
# 9. VERIFICAÇÃO FINAL
#############################################
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}         VERIFICAÇÃO FINAL                  ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

echo "Clusters EKS:"
aws eks list-clusters --region $AWS_REGION --query 'clusters' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo "Repositórios ECR:"
aws ecr describe-repositories --region $AWS_REGION --query 'repositories[].repositoryName' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo "Stacks CloudFormation ativos:"
aws cloudformation list-stacks --region $AWS_REGION \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --query 'StackSummaries[].StackName' --output text 2>/dev/null || echo "  Nenhum"

echo ""
echo "Containers Docker rodando:"
docker ps --format "  {{.Names}} ({{.Image}})" 2>/dev/null || echo "  Nenhum"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ LIMPEZA CONCLUÍDA COM SUCESSO!         ${NC}"
echo -e "${GREEN}============================================${NC}"
