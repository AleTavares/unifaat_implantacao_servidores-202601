# Instruções de Entrega - TF011 AWS

## Status: ✅ PREPARADO PARA ENTREGA

Seu trabalho foi organizado com todos os artefatos necessários para completar a Tarefa Final da Aula 011.

---

## 📁 Estrutura de Arquivos Criados

```
Aula 011/4025109/
├── README.md                    ← Respostas teóricas (Q1-Q4) + exemplos práticos
├── COMANDOS_PRATICOS.md         ← Passo-a-passo detalhado de execução
├── create-table.sql             ← Script SQL para criar tabela alunos
├── insert-data.sql              ← Script SQL para inserir dados de exemplo
├── create-rds.sh                ← Script automatizado para criar RDS
├── upload-to-s3.sh              ← Script automatizado para upload S3
└── rds-config.env               ← (Criado após executar create-rds.sh)
```

---

## 🚀 Próximas Etapas Para Completar

### 1️⃣ Instalar Dependências

```bash
# Completar instalação do AWS CLI (aguarde senha sudo):
# Digite sua senha quando solicitado

# Após AWS CLI instalado, verifique a versão:
aws --version

# Instalar cliente PostgreSQL (se não tiver):
sudo apt-get install postgresql-client

# Verificar versão:
psql --version
```

### 2️⃣ Configurar Credenciais AWS

```bash
# Configure suas credenciais da AWS
aws configure

# Será solicitado:
# AWS Access Key ID: [Insira seu Access Key]
# AWS Secret Access Key: [Insira seu Secret Key]
# Default region name: us-east-1
# Default output format: json

# Verificar configuração:
aws configure list
```

⚠️ **IMPORTANTE**: Não compartilhe suas credenciais. Mantenha-as seguras!

### 3️⃣ Executar Script de Criação do RDS

```bash
# Ir para a pasta do seu RA:
cd "/mnt/c/Users/fehhr/OneDrive/Desktop/ale/unifaat_implantacao_servidores-202601/Aula 011/4025109"

# Dar permissão de execução:
chmod +x create-rds.sh upload-to-s3.sh

# Executar script de RDS:
./create-rds.sh

# ⏳ Aguarde 5-10 minutos para a instância ficar "available"
```

### 4️⃣ Conectar ao RDS e Criar Tabela

```bash
# Carregar variáveis de ambiente:
source rds-config.env

# Criar tabela:
psql -h $RDS_ENDPOINT -U $RDS_USER -d $RDS_DATABASE -f create-table.sql

# Inserir dados:
psql -h $RDS_ENDPOINT -U $RDS_USER -d $RDS_DATABASE -f insert-data.sql

# Verificar dados:
psql -h $RDS_ENDPOINT -U $RDS_USER -d $RDS_DATABASE -c "SELECT * FROM alunos;"
```

### 5️⃣ Fazer Upload para S3

```bash
# Primeiro, crie o bucket S3:
aws s3 mb s3://config-app-tf11 --region us-east-1

# Ou execute o script:
./upload-to-s3.sh
```

### 6️⃣ Capturar Evidências (Screenshots)

Para cada comando, tire um screenshot e salve em uma pasta `prints/`:

```bash
mkdir -p prints

# Exemplos de capturas necessárias:
# 1. aws configure list
# 2. aws rds describe-db-instances
# 3. psql --version
# 4. Output de create-table.sql
# 5. Output de insert-data.sql (SELECT * FROM alunos)
# 6. DBeaver connection window
# 7. aws rds create-db-snapshot
```

### 7️⃣ Documenta Evidências no README

Após capturar as screenshots, atualize o `README.md` com:
- Descrição de cada evidência
- Data e hora de execução
- Observações sobre problemas ou ajustes realizados

### 8️⃣ Atualizar Repositório Git e Fazer Pull Request

```bash
# Ir para a raiz do repositório
cd ~/caminho/do/repositorio

# Atualizar fork (se necessário)
git fetch upstream
git rebase upstream/main

# Adicionar alterações
git add "Aula 011/4025109/"

# Fazer commit
git commit -m "4025109 - [Seu Nome]"

# Fazer push
git push origin main

# Criar Pull Request no GitHub
# Título: "4025109 - [Seu Nome]"
# Descrição: [Resumo das atividades realizadas]
```

---

## ✅ Checklist de Entrega

Antes de fazer a Pull Request, certifique-se de:

- [ ] Pasta `Aula 011/4025109/` criada ✅ (JÁ FEITO)
- [ ] `README.md` com respostas teóricas ✅ (JÁ FEITO)
- [ ] `COMANDOS_PRATICOS.md` com instruções ✅ (JÁ FEITO)
- [ ] Scripts SQL (`create-table.sql`, `insert-data.sql`) ✅ (JÁ FEITO)
- [ ] Scripts shell (`create-rds.sh`, `upload-to-s3.sh`) ✅ (JÁ FEITO)
- [ ] Pasta `prints/` com screenshots das evidências
- [ ] README atualizado com descrição de cada evidência
- [ ] Pull Request criado com título: `4025109 - [Seu Nome]`
- [ ] PR aberto até 22:30 (conforme descrito na tarefa)

---

## 📋 Conteúdo do README.md (JÁ COMPLETO)

O arquivo README.md contém:

✅ **Questão 1**: Armazenamento S3
- Casos de uso (hospedagem estática, backups, data lakes, etc.)
- S3 global vs regional
- Explicação dos "Onze Noves" (durabilidade vs disponibilidade)

✅ **Questão 2**: EBS vs EFS
- Tabela comparativa detalhada
- Diferenças de conexão (dedicada vs rede)
- Adequabilidade para SO e executáveis (EBS é melhor)

✅ **Questão 3**: RDS Gerenciado
- 2+ responsabilidades assumidas pela AWS
- Desvantagens comparadas a EC2

✅ **Questão 4**: Multi-AZ e Read Replicas
- Descrição do processo de replicação síncrona
- Failover automático
- Tabela comparativa Standby vs Read Replica

✅ **Questão 5**: Workflow S3
- 3 etapas: criação de arquivo, upload CLI, verificação
- Comandos específicos de exemplo
- Saídas esperadas

✅ **Questão 6**: Prática RDS
- Comandos AWS CLI para criar RDS
- Instruções DBeaver para conexão
- Scripts SQL para criar tabela e inserir dados
- Exemplos de saídas esperadas

---

## 🔧 Troubleshooting Comum

### "aws: command not found"
```bash
# Instalar AWS CLI:
sudo apt-get install awscli
# Ou:
sudo snap install aws-cli
```

### "Unable to connect to RDS"
```bash
# Verificar que RDS está "available":
aws rds describe-db-instances --db-instance-identifier rds-tf011-4025109

# Verificar security group (permitir acesso)
# Verificar credenciais RDS
```

### "Credenciais AWS inválidas"
```bash
# Reconfigurar:
aws configure

# Verificar arquivo ~/.aws/credentials
cat ~/.aws/credentials
```

### "LocalStack como alternativa"
Se quiser evitar custos da AWS real, use LocalStack:
```bash
docker run -it -p 4566:4566 localstack/localstack
# E adicione --endpoint-url=http://localhost:4566 aos comandos AWS
```

---

## 💡 Dicas Importantes

1. **Cuidado com Custos**
   - RDS db.t3.micro custa ~$0.016/hora (pode somar!)
   - Não esqueça de **deletar** a instância após terminar
   - Use LocalStack se quiser economizar

2. **Timing**
   - RDS leva ~5-10 minutos para ficar "available"
   - Não apresse, aguarde o status correto

3. **Segurança**
   - Nunca comite senhas em repositórios
   - Use variáveis de ambiente para credenciais
   - Multi-AZ aumenta segurança (mas custo também)

4. **Documentação**
   - Capture prints de TODOS os comandos
   - Descreva cada evidência no README
   - Cite problemas e como foram resolvidos

5. **Git/GitHub**
   - Faça fork do repositório original
   - Crie branch para suas alterações (opcional)
   - PR deve ter título: `RA - Nome`
   - Envie até 22:30

---

## 📞 Resumo de Comandos Principais

```bash
# Setup
aws configure                           # Configurar credenciais
aws configure list                      # Verificar configuração

# RDS
aws rds create-db-instance ...          # Criar instância
aws rds describe-db-instances           # Ver status
aws rds delete-db-instance ...          # Deletar (CUIDADO!)
aws rds create-db-snapshot ...          # Fazer backup

# S3
aws s3 mb s3://bucket-name              # Criar bucket
aws s3 cp file.txt s3://bucket/         # Upload
aws s3 ls s3://bucket                   # Listar
aws s3 rm s3://bucket/file --recursive  # Deletar

# PostgreSQL
psql -h endpoint -U user -d database    # Conectar
psql -f script.sql                      # Executar script
```

---

## 🎯 Objetivo Final

Ao completar estes passos, você terá:

1. ✅ Respondido todas as questões teóricas (Q1-Q4)
2. ✅ Descrito workflow prático de S3 (Q5)
3. ✅ Criado uma instância RDS PostgreSQL (Q6)
4. ✅ Criado tabela de alunos com dados (Q6)
5. ✅ Feito backup via snapshot (Q6)
6. ✅ Documentado todas as evidências em screenshots (Q6)
7. ✅ Preparado Pull Request para submissão

**Boa sorte! 🚀**

---

**Data de Criação**: 01/06/2024
**RA**: 4025109
**Status**: ✅ Estrutura Completa - Aguardando Execução Prática
