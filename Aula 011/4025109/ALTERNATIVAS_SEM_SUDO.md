# Alternativa: Completar TF011 Sem Instalar AWS CLI Localmente

Se a instalação do AWS CLI tiver problemas, você pode usar estas alternativas:

---

## ✅ Opção 1: Usar CloudShell (Console AWS na Web)

A forma mais simples é usar AWS CloudShell diretamente no console AWS:

### Passos:
1. Acesse: https://console.aws.amazon.com
2. Faça login com suas credenciais AWS
3. No topo da página, procure por "CloudShell" (ícone de terminal)
4. Clique em "CloudShell" → Um terminal web abrirá
5. No CloudShell, execute todos os comandos AWS CLI:

```bash
# Neste terminal web, execute:

# Criar bucket S3
aws s3 mb s3://config-app-tf11

# Criar RDS
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-4025109 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.7 \
  --master-username admin \
  --master-user-password TempPassword123! \
  --allocated-storage 20 \
  --publicly-accessible

# Monitorar status
aws rds describe-db-instances --db-instance-identifier rds-tf011-4025109
```

**Vantagens:**
- ✅ Não precisa instalar nada
- ✅ Já tem credenciais AWS configuradas automaticamente
- ✅ Acesso direto aos recursos AWS
- ✅ Pode tirar screenshots do console

---

## ✅ Opção 2: Usar AWS Console (GUI)

Crie tudo pelo console web (mais visual):

### Criar RDS via Console:
1. Acesse: https://console.aws.amazon.com/rds
2. Clique em "Create Database"
3. Escolha "PostgreSQL"
4. Preencha:
   - **DB Instance Identifier**: `rds-tf011-4025109`
   - **Master Username**: `admin`
   - **Master Password**: `TempPassword123!`
   - **Instance Class**: `db.t3.micro`
   - **Storage**: `20 GB`
   - **Multi-AZ**: ✅ (marcar)
5. Clique em "Create Database"
6. Aguarde até aparecer "Available"
7. Copie o Endpoint

### Criar S3 via Console:
1. Acesse: https://console.aws.amazon.com/s3
2. Clique em "Create Bucket"
3. Nome: `config-app-tf11`
4. Região: `us-east-1`
5. Crie o arquivo `db_config.conf` localmente:
   ```bash
   cat > db_config.conf << EOF
   DB_HOST=rds-tf011-4025109.xxxxx.rds.amazonaws.com
   DB_PORT=5432
   DB_USER=admin
   DB_PASSWORD=TempPassword123!
   DB_NAME=postgres
   EOF
   ```
6. No console S3, clique "Upload" e selecione `db_config.conf`

**Vantagens:**
- ✅ Interface visual
- ✅ Fácil de entender
- ✅ Screenshots automáticas
- ✅ Não precisa de linha de comando

---

## ✅ Opção 3: Usar DBeaver Diretamente

DBeaver pode fazer tudo visualmente:

### Conectar ao RDS existente:
1. Abra DBeaver
2. Database → New Database Connection → PostgreSQL
3. Preencha com o endpoint do RDS
4. Test Connection → Finish
5. Na conexão, crie a tabela:
   ```sql
   CREATE TABLE alunos (
       id SERIAL PRIMARY KEY,
       ra VARCHAR(10) UNIQUE NOT NULL,
       nome VARCHAR(100) NOT NULL,
       email VARCHAR(100) UNIQUE NOT NULL,
       data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo'))
   );
   
   INSERT INTO alunos (ra, nome, email) VALUES
   ('6325128', 'João Silva', 'joao@email.com'),
   ('6325129', 'Maria Santos', 'maria@email.com'),
   ('6325130', 'Pedro Oliveira', 'pedro@email.com'),
   ('4025109', 'Seu Nome', 'seu.email@email.com');
   
   SELECT * FROM alunos;
   ```

**Vantagens:**
- ✅ Totalmente visual
- ✅ Não precisa de terminal
- ✅ Gerencia tudo graficamente
- ✅ Screenshots fáceis

---

## ✅ Opção 4: Usar LocalStack (Simulador AWS Local)

Se não quer usar AWS real (e evitar custos):

```bash
# 1. Instalar Docker
# (Se não tiver, ignore - pode usar AWS CloudShell)

# 2. Iniciar LocalStack
docker run -it -p 4566:4566 localstack/localstack

# 3. Em outro terminal, configurar AWS CLI
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# 4. Criar recursos (mesmo comando, mas com endpoint local)
aws s3 mb s3://config-app-tf11 --endpoint-url=http://localhost:4566

aws rds create-db-instance \
  --db-instance-identifier rds-tf011-4025109 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password TempPassword123! \
  --endpoint-url=http://localhost:4566
```

**Vantagens:**
- ✅ Simula AWS localmente
- ✅ Não gasta dinheiro
- ✅ Prático para testes
- ✅ Rápido

---

## 🎯 RECOMENDAÇÃO FINAL

### Para você (sem sudo disponível):

**Use CloudShell (Opção 1) - Melhor escolha:**
1. Abra console AWS (https://console.aws.amazon.com)
2. Clique em CloudShell (terminal web)
3. Execute os comandos AWS CLI
4. Tire screenshots das saídas
5. Use DBeaver para gerenciar tabelas

**Por quê?**
- ✅ Não precisa instalar nada
- ✅ Credenciais já configuradas
- ✅ Terminal pronto para usar
- ✅ Mais rápido

---

## 📋 Checklist com CloudShell

- [ ] Acessar AWS Console
- [ ] Abrir CloudShell
- [ ] Criar bucket S3
- [ ] Fazer upload de arquivo
- [ ] Criar RDS PostgreSQL
- [ ] Aguardar até "available"
- [ ] Anotar endpoint RDS
- [ ] Instalar DBeaver
- [ ] Conectar ao RDS no DBeaver
- [ ] Criar tabela alunos
- [ ] Inserir dados
- [ ] Tirar screenshots
- [ ] Documentar no README

---

## 💻 Próximos Passos Imediatos

```bash
# 1. Criar arquivo para entrega
mkdir -p "Aula 011/4025109/prints"

# 2. Abrir console AWS
# https://console.aws.amazon.com

# 3. Abrir CloudShell e executar os comandos
# (veja COMANDOS_PRATICOS.md para os comandos exatos)

# 4. Capturar screenshots do console
# (Print Screen ou Snipping Tool)

# 5. Salvar em prints/

# 6. Documentar no README
```

---

Quer que eu ajude você com alguma dessas opções?
