#!/bin/bash
#############################################
# start.sh - Subir ambiente do Lab 013/014
# Curso: ADS UniFAAT - Implantação de Servidores
# Cria toda a infraestrutura EKS + ECR + Deploy
# para dar continuidade no Lab 014 (Monitoramento)
#############################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  START LAB 013/014 - EKS + ECR + DEPLOY   ${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Variáveis
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-123123123123}"
export AWS_REGION="${AWS_REGION:-us-east-2}"
export REPO_NAME="ads-unifaat-site"
export IMAGE_TAG="v1.0"
export CLUSTER_NAME="cluster-eks-ads"
export NODEGROUP_NAME="ads-app-nodes"
export STACK_NAME="eks-vpc-ads"
export NAMESPACE="ads-unifaat"
export REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

echo -e "${YELLOW}Configuração:${NC}"
echo "  Account ID:   $AWS_ACCOUNT_ID"
echo "  Region:       $AWS_REGION"
echo "  Cluster:      $CLUSTER_NAME"
echo "  Node Group:   $NODEGROUP_NAME"
echo "  ECR Repo:     $REPO_NAME"
echo "  Image Tag:    $IMAGE_TAG"
echo "  VPC Stack:    $STACK_NAME"
echo ""
echo -e "${RED}⚠️  ATENÇÃO: Este script cria recursos AWS que GERAM CUSTO!${NC}"
echo -e "${RED}   EKS (~\$0.10/h) + EC2 nodes (~\$0.08/h) + LoadBalancer${NC}"
echo ""

read -p "Confirma a criação de TODOS os recursos? (s/N): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "Cancelado."
    exit 0
fi

echo ""
START_TIME=$(date +%s)

# Funções helper
step() { echo -e "\n${GREEN}[STEP $(date +%H:%M:%S)]${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
ok()   { echo -e "  ${GREEN}✅${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠️${NC} $1"; }

#############################################
# 1. PREPARAÇÃO LOCAL
#############################################
step "Preparando diretório e aplicação..."

mkdir -p ~/aulas_lab/aula013/app
cd ~/aulas_lab/aula013/app

# Criar Dockerfile
cat > Dockerfile << 'DOCKERFILE'
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

# Criar index.html (versão mínima funcional)
cat > index.html << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADS - UniFAAT</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header class="hero">
        <div class="hero-content">
            <h1>Análise e Desenvolvimento de Sistemas</h1>
            <p class="hero-subtitle">UniFAAT - Formando profissionais para o mercado de tecnologia</p>
            <p>Do código ao deploy em nuvem. Do front-end à inteligência artificial.</p>
        </div>
    </header>
    <section class="section">
        <div class="container">
            <h2>Pilares do Curso</h2>
            <p>Desenvolvimento Web | Governança de TI | IA e Big Data | Cloud e DevOps</p>
        </div>
    </section>
    <footer class="footer">
        <p>&copy; 2026 UniFAAT - ADS | Deploy via Docker + AWS EKS</p>
    </footer>
</body>
</html>
HTML

# Criar styles.css (versão mínima)
cat > styles.css << 'CSS'
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Segoe UI', sans-serif; color: #333; }
.hero { background: linear-gradient(135deg, #0a192f, #1a365d); min-height: 60vh; display: flex; align-items: center; justify-content: center; text-align: center; padding: 2rem; }
.hero-content { max-width: 800px; }
.hero h1 { font-size: 2.5rem; color: #ccd6f6; margin-bottom: 1rem; }
.hero-subtitle { font-size: 1.2rem; color: #64ffda; margin-bottom: 1rem; }
.hero p { color: #8892b0; font-size: 1rem; }
.section { padding: 3rem 2rem; text-align: center; }
.section h2 { color: #0a192f; margin-bottom: 1rem; }
.footer { background: #0a192f; color: #8892b0; text-align: center; padding: 1.5rem; }
CSS

ok "Arquivos da aplicação criados"

#############################################
# 2. BUILD E PUSH PARA ECR
#############################################
step "Construindo imagem Docker..."

docker build --no-cache -t $REPO_NAME:$IMAGE_TAG . -q
ok "Imagem construída: $REPO_NAME:$IMAGE_TAG"

step "Criando repositório ECR..."

aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION 2>/dev/null && ok "Repositório criado" || warn "Repositório já existe"

step "Autenticando Docker com ECR..."

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com 2>/dev/null
ok "Login ECR realizado"

step "Enviando imagem para ECR..."

docker tag $REPO_NAME:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
docker push $REPO_URI:$IMAGE_TAG -q
ok "Imagem enviada: $REPO_URI:$IMAGE_TAG"

#############################################
# 3. IAM ROLES
#############################################
step "Criando IAM Roles..."

# Cluster Role
aws iam create-role \
  --role-name EKSClusterRole-ADS \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow","Principal": {"Service": "eks.amazonaws.com"},"Action": "sts:AssumeRole"}]
  }' 2>/dev/null && info "EKSClusterRole-ADS criada" || info "EKSClusterRole-ADS já existe"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name EKSClusterRole-ADS 2>/dev/null || true

# Node Role
aws iam create-role \
  --role-name EKSNodeRole-ADS \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow","Principal": {"Service": "ec2.amazonaws.com"},"Action": "sts:AssumeRole"}]
  }' 2>/dev/null && info "EKSNodeRole-ADS criada" || info "EKSNodeRole-ADS já existe"

aws iam attach-role-policy --role-name EKSNodeRole-ADS \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy 2>/dev/null || true
aws iam attach-role-policy --role-name EKSNodeRole-ADS \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy 2>/dev/null || true
aws iam attach-role-policy --role-name EKSNodeRole-ADS \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly 2>/dev/null || true

ok "IAM Roles configuradas"

#############################################
# 4. VPC (CLOUDFORMATION)
#############################################
step "Criando VPC via CloudFormation..."

if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION &>/dev/null; then
  warn "Stack $STACK_NAME já existe"
else
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml \
    --region $AWS_REGION

  info "Aguardando VPC (~2-3 min)..."
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $AWS_REGION
  ok "VPC criada"
fi

# Obter Subnets
SUBNET_IDS=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' \
  --output text --region $AWS_REGION)

info "Subnets: $SUBNET_IDS"

#############################################
# 5. CLUSTER EKS
#############################################
step "Criando Cluster EKS..."

if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION &>/dev/null; then
  warn "Cluster $CLUSTER_NAME já existe"
else
  CLUSTER_ROLE_ARN=$(aws iam get-role --role-name EKSClusterRole-ADS --query 'Role.Arn' --output text)

  aws eks create-cluster \
    --name $CLUSTER_NAME \
    --role-arn $CLUSTER_ROLE_ARN \
    --resources-vpc-config subnetIds=$SUBNET_IDS \
    --kubernetes-version 1.32 \
    --region $AWS_REGION

  info "Aguardando cluster ficar ativo (~10-15 min)..."
  info "Isso é normal. Vá tomar um café ☕"
  aws eks wait cluster-active --name $CLUSTER_NAME --region $AWS_REGION
  ok "Cluster ATIVO!"
fi

#############################################
# 6. NODE GROUP
#############################################
step "Criando Node Group..."

if aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $AWS_REGION &>/dev/null; then
  warn "Node Group $NODEGROUP_NAME já existe"
else
  NODE_ROLE_ARN=$(aws iam get-role --role-name EKSNodeRole-ADS --query 'Role.Arn' --output text)

  aws eks create-nodegroup \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name $NODEGROUP_NAME \
    --node-role $NODE_ROLE_ARN \
    --subnets $(echo $SUBNET_IDS | tr ',' ' ') \
    --instance-types t3.medium \
    --scaling-config minSize=2,maxSize=3,desiredSize=2 \
    --region $AWS_REGION

  info "Aguardando Node Group (~5 min)..."
  aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $AWS_REGION
  ok "Node Group ATIVO!"
fi

#############################################
# 7. CONFIGURAR KUBECTL
#############################################
step "Configurando kubectl..."

aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
ok "kubeconfig atualizado"

info "Nodes:"
kubectl get nodes

#############################################
# 8. DEPLOY DA APLICAÇÃO
#############################################
step "Deployando aplicação no EKS..."

cd ~/aulas_lab/aula013

# Criar namespace
kubectl create namespace $NAMESPACE 2>/dev/null || warn "Namespace já existe"

# Criar deployment
cat > deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ads-site
  namespace: $NAMESPACE
  labels:
    app: ads-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ads-site
  template:
    metadata:
      labels:
        app: ads-site
    spec:
      containers:
      - name: ads-site
        image: ${REPO_URI}:${IMAGE_TAG}
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
EOF

# Criar service
cat > service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: ads-site-service
  namespace: $NAMESPACE
  labels:
    app: ads-site
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: ads-site
EOF

# Aplicar manifestos
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

ok "Manifestos aplicados"

# Aguardar pods ficarem prontos
info "Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=ads-site -n $NAMESPACE --timeout=120s
ok "Pods rodando!"

#############################################
# 9. OBTER ENDPOINT
#############################################
step "Obtendo endpoint do LoadBalancer..."

info "Aguardando LoadBalancer ser provisionado (~2-3 min)..."
for i in $(seq 1 30); do
  ENDPOINT=$(kubectl get svc ads-site-service -n $NAMESPACE \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [ -n "$ENDPOINT" ] && [ "$ENDPOINT" != "" ]; then
    break
  fi
  sleep 10
done

#############################################
# RESUMO FINAL
#############################################
END_TIME=$(date +%s)
DURATION=$(( (END_TIME - START_TIME) / 60 ))

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ AMBIENTE PRONTO!                       ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  Cluster:     ${CYAN}$CLUSTER_NAME${NC} (ACTIVE)"
echo -e "  Nodes:       ${CYAN}2x t3.medium${NC} (Ready)"
echo -e "  Namespace:   ${CYAN}$NAMESPACE${NC}"
echo -e "  Pods:        ${CYAN}2 réplicas${NC} (Running)"
echo -e "  ECR Image:   ${CYAN}$REPO_URI:$IMAGE_TAG${NC}"
echo ""

if [ -n "$ENDPOINT" ]; then
  echo -e "  🌐 URL:       ${GREEN}http://$ENDPOINT${NC}"
else
  echo -e "  🌐 URL:       ${YELLOW}Aguardando DNS (verifique em 1-2 min)${NC}"
  echo -e "               kubectl get svc ads-site-service -n $NAMESPACE"
fi

echo ""
echo -e "  ⏱️  Tempo total: ${CYAN}~${DURATION} minutos${NC}"
echo ""
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Verificar: kubectl get all -n $NAMESPACE"
echo "  2. Testar:    curl http://$ENDPOINT"
echo "  3. Continuar: Lab014 - Monitoramento"
echo ""
echo -e "${YELLOW}⚠️  Lembre-se: execute cleanup.sh ao terminar!${NC}"
