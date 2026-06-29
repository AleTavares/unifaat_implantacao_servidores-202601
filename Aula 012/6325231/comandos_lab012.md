# Comandos executados/simulados - Lab012

Aluno: Andreyh Rodrigues de Souza  
RA: 6325231

## Variaveis do laboratorio

```bash
export IMAGE_TAG="V1.0"
export AWS_ACCOUNT_ID="<id-da-conta-aws>"
export AWS_REGION="us-east-2"
export REPO_NAME="app-frontend"
export REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
```

## Preparacao local

```bash
aws configure list
docker build -t web-app-v1:$IMAGE_TAG .
docker images | grep web-app-v1
```

## ECR

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker images | grep $REPO_URI
docker push $REPO_URI:$IMAGE_TAG
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].imageTags[0]'
```

## Bonus EKS

```bash
kubectl create namespace app-frontend
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployments -n app-frontend
kubectl get pods -n app-frontend
kubectl get svc app-frontend-service -n app-frontend
ENDPOINT=$(kubectl get svc app-frontend-service -n app-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ENDPOINT
```

## Limpeza

```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete namespace app-frontend
aws ecr batch-delete-image --repository-name $REPO_NAME --region $AWS_REGION --image-ids imageTag=$IMAGE_TAG
aws ecr delete-repository --repository-name $REPO_NAME --region $AWS_REGION --force
docker rmi $REPO_URI:$IMAGE_TAG
docker rmi web-app-v1:$IMAGE_TAG
```
