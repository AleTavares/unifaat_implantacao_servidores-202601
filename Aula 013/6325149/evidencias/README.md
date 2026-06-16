# Evidencias - TF013 Lab Execution

Coloque os prints/capturas de terminal coletados durante a execucao do Lab013.md nesta pasta.

## Convencao de Nomeacao

- `print01-docker-build.txt` - Saida do docker build
- `print02-curl-localhost.txt` - Teste local do container
- `print03-docker-images.txt` - Listagem de imagem local
- `print04-ecr-login.txt` - Login no ECR (esperado: "Login Succeeded")
- `print05-docker-push.txt` - Push da imagem para ECR
- `print06-ecr-verify.txt` - Verificacao de imagem no ECR
- `print07-cluster-active.txt` - Status do cluster EKS
- `print08-kubectl-nodes.txt` - Nodes do cluster
- `print09-kubectl-deployment.txt` - Deployment status
- `print10-kubectl-pods.txt` - Pods rodando
- `print11-kubectl-svc.txt` - Service com EXTERNAL-IP
- `print12-curl-endpoint.txt` - Acesso via curl ao LoadBalancer
- `print13-browser-screenshot.png` - Screenshot da pagina no navegador
- `print14-resilience-test.txt` - Teste de resiliencia (pod deletado e recriado)
- `print15-cleanup-verify.txt` - Verificacao de limpeza completa

## Como Capturar

### Para comandos de terminal (.txt):
```bash
# Rodar comando e capturar saida
command_aqui 2>&1 | tee print01-docker-build.txt
```

### Para screenshots (.png):
- Use Print Screen ou ferramenta nativa do SO
- Salve como PNG nesta pasta

---

**Status:** Aguardando coleta de evidencias durante execucao de Lab013.md
