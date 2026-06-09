# Guia de Troubleshooting - Curso Docker/AWS

## Problemas Comuns WSL

### Docker Desktop não conecta ao WSL
**Sintomas:** Docker commands retornam erro de conexão
```bash
# Soluções
wsl --shutdown
# Reiniciar Docker Desktop
# Verificar integração WSL nas configurações do Docker Desktop
```

### Permissões de arquivo entre Windows/Linux
**Sintomas:** Permission denied ao executar scripts
```bash
# Soluções
chmod +x script.sh
sudo chown $USER:$USER arquivo
# Evitar editar arquivos WSL no Windows Explorer
```

### Performance de I/O em bind mounts
**Sintomas:** Build ou execução muito lenta
```bash
# Soluções
# Usar named volumes em vez de bind mounts quando possível
docker volume create meu-volume
# Manter arquivos no sistema de arquivos Linux (/home/user)
```

### WSL não inicia ou trava
```bash
# Diagnóstico
wsl --list --verbose
wsl --status

# Soluções
wsl --shutdown
wsl --unregister Ubuntu  # CUIDADO: Remove a distribuição
wsl --install -d Ubuntu
```

## Problemas Comuns Docker

### Cache de build não funcionando
**Sintomas:** Build sempre executa todas as etapas
```bash
# Soluções
# Verificar ordem das instruções no Dockerfile
# Instruções que mudam menos devem vir primeiro
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .  # Código que muda mais vem por último
```

### Conflitos de porta
**Sintomas:** "Port already in use" ou "bind: address already in use"
```bash
# Diagnóstico
docker ps  # Ver portas em uso
netstat -tulpn | grep :8080  # Linux
netstat -ano | findstr :8080  # Windows

# Soluções
docker stop $(docker ps -q)  # Parar todos os contêineres
# Usar porta diferente: -p 8081:80
```

### Problemas de rede entre contêineres
**Sintomas:** Contêineres não se comunicam
```bash
# Diagnóstico
docker network ls
docker network inspect bridge

# Soluções
# Criar rede customizada
docker network create minha-rede
docker run --network minha-rede --name app1 nginx
docker run --network minha-rede --name app2 alpine ping app1
```

### Imagens muito grandes
```bash
# Diagnóstico
docker images
docker history imagem:tag

# Soluções
# Multi-stage builds
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
```

### Contêineres não param
```bash
# Diagnóstico
docker ps
docker logs container-id

# Soluções
docker stop container-id
docker kill container-id  # Força parada
docker rm -f container-id  # Remove forçadamente
```

## Problemas Comuns AWS

### Credenciais não configuradas
**Sintomas:** "Unable to locate credentials"
```bash
# Diagnóstico
aws sts get-caller-identity
aws configure list

# Soluções
aws configure
# Ou definir variáveis de ambiente
export AWS_ACCESS_KEY_ID=sua-chave
export AWS_SECRET_ACCESS_KEY=sua-chave-secreta
export AWS_DEFAULT_REGION=us-east-1
```

### Limites de Free Tier
**Sintomas:** Cobrança inesperada ou serviços bloqueados
```bash
# Prevenção
# Sempre usar instâncias t2.micro ou t3.micro
# Configurar alertas de billing
# Parar instâncias quando não usar
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

### Regiões incorretas
**Sintomas:** Recursos não encontrados
```bash
# Diagnóstico
aws configure get region
aws ec2 describe-regions

# Soluções
aws configure set region us-east-1
# Ou usar --region em cada comando
aws ec2 describe-instances --region us-west-2
```

### ECR Push/Pull falha
**Sintomas:** "no basic auth credentials" ou "denied"
```bash
# Diagnóstico
aws ecr describe-repositories
aws sts get-caller-identity

# Soluções
# Login no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com

# Verificar permissões IAM
aws iam list-attached-user-policies --user-name seu-usuario
```

## Problemas de CI/CD

### Pipeline falha no build
```bash
# Diagnóstico
docker build --no-cache -t app:latest .
docker logs build-container

# Soluções
# Verificar Dockerfile
# Testar build localmente primeiro
# Usar .dockerignore para excluir arquivos desnecessários
```

### Deploy falha
```bash
# Diagnóstico
docker service ps service-name
docker service logs service-name

# Soluções
# Verificar se imagem existe no registry
# Confirmar recursos disponíveis
# Testar deploy local primeiro
```

## Comandos de Diagnóstico Úteis

### Docker
```bash
# Status geral
docker system df
docker system info
docker version

# Logs e debugging
docker logs container-name
docker exec -it container-name /bin/bash
docker inspect container-name

# Limpeza
docker system prune -a
docker volume prune
docker network prune
```

### WSL
```bash
# Status WSL
wsl --list --verbose
wsl --status
wsl --version

# Recursos
wsl --list --online
wsl --update
```

### AWS
```bash
# Identidade e região
aws sts get-caller-identity
aws configure list
aws ec2 describe-regions

# Recursos
aws ec2 describe-instances
aws ecr describe-repositories
aws s3 ls
```

## Recursos Adicionais

### Documentação Oficial
- [Docker Troubleshooting](https://docs.docker.com/config/troubleshooting/)
- [WSL Troubleshooting](https://docs.microsoft.com/en-us/windows/wsl/troubleshooting)
- [AWS CLI Troubleshooting](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html)

### Ferramentas de Debug
- `docker system events` - Monitor eventos em tempo real
- `docker stats` - Uso de recursos dos contêineres
- `aws logs` - Logs do CloudWatch
- `htop` - Monitor de sistema Linux