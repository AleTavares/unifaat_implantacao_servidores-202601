#!/bin/bash
# lab-commands.sh - Comandos para Lab012 (RA 6325216)
# Ajuste variáveis conforme seu ambiente antes de executar.

AWS_ACCOUNT_ID=123456789012
AWS_REGION=us-east-1
REPO_NAME=web-app-repo
IMAGE_LOCAL=web-app:v1
IMAGE_TAG=v1
REPO_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}

set -e

echo "[1] Verificar configuração AWS"
aws configure list || true

echo "[2] Criar repositório (idempotente)"
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION || true
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION

echo "[3] Login Docker no ECR"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "[4] Build da imagem Docker"
docker build -t $IMAGE_LOCAL .

echo "[5] Tagging da imagem"
docker tag $IMAGE_LOCAL $REPO_URI:$IMAGE_TAG

echo "[6] Verificar imagem local marcada"
docker images | grep $REPO_NAME || docker images

echo "[7] Push para o ECR"
docker push $REPO_URI:$IMAGE_TAG

echo "[8] Verificar imagens no ECR"
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query \"imageDetails[].imageTags[0]\"

echo "[9] (BÔNUS) comandos para validar deploy no EKS"
echo "kubectl get deployments -n app-frontend"
echo "kubectl get pods -n app-frontend"
echo "kubectl get svc app-frontend-service -n app-frontend"

echo "Script finalizado. Substitua variáveis conforme necessário antes de rodar."
