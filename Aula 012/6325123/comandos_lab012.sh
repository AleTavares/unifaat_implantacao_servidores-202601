#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="V1.0"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-123456789012}"
AWS_REGION="${AWS_REGION:-us-east-1}"
REPO_NAME="${REPO_NAME:-web-app-repo}"
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

aws configure list

docker build -t "web-app-v1:$IMAGE_TAG" .
docker images | grep web-app-v1

aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --region "$AWS_REGION" || true

aws ecr describe-repositories \
  --repository-names "$REPO_NAME" \
  --region "$AWS_REGION"

aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker tag "web-app-v1:$IMAGE_TAG" "$REPO_URI:$IMAGE_TAG"
docker images | grep "$REPO_URI"

docker push "$REPO_URI:$IMAGE_TAG"

aws ecr describe-images \
  --repository-name "$REPO_NAME" \
  --region "$AWS_REGION" \
  --query 'imageDetails[].imageTags[0]'
