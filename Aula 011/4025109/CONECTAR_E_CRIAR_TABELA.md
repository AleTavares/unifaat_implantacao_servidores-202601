# 🔌 Conectar ao database-1 com DBeaver

## Suas Credenciais

```
Endpoint: database-1.cl4isc6gy0kk.us-east-2.rds.amazonaws.com
Porta: 5432
Username: postgres
Password: postgres
Database: postgres
Região: us-east-2
```

---

## ✅ PASSO 1: Abrir DBeaver e Criar Conexão

### 1.1 Abrir DBeaver
- Clique no ícone do DBeaver

### 1.2 Criar Nova Conexão
- Menu: **Database** → **New Database Connection**

### 1.3 Selecionar PostgreSQL
- Procure por **PostgreSQL** na lista
- Clique nele
- Clique em **"Next"** ou **"Finish"**

---

## 📝 PASSO 2: Preencher Credenciais

Na aba **"Main"**, preencha EXATAMENTE:

```
├─ Server Host: database-1.cl4isc6gy0kk.us-east-2.rds.amazonaws.com
├─ Port: 5432
├─ Database: postgres
├─ Username: postgres
├─ Password: postgres
└─ ☑️ Save password locally: MARCAR
```

---

## 🧪 PASSO 3: Testar Conexão

Clique em **"Test Connection"**

**Esperado:**
```
✅ Connected - PostgreSQL 14.7 (ou similar)
```

Se aparecer ✅ verde, clique em **"Finish"**

---

## 📊 PASSO 4: Criar Tabela de Alunos

### 4.1 Abrir Editor SQL
- Menu: **File** → **New SQL Script**
- Um editor em branco abrirá

### 4.2 Copiar Script Abaixo

```sql
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    ra VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo'))
);
```

### 4.3 Colar no DBeaver
- Clique no editor
- **Ctrl + V** (colar)
- O script aparecerá

### 4.4 Executar
- Pressione: **Ctrl + Enter**
- Ou clique no botão ▶️ (Run)

**Esperado na saída abaixo:**
```
✅ [SQL] CREATE TABLE alunos...
Successfully executed in X ms
```

---

## 📝 PASSO 5: Inserir Dados

### 5.1 Novo Script SQL
- **File** → **New SQL Script** (nova aba)

### 5.2 Copiar Script de Inserção

```sql
INSERT INTO alunos (ra, nome, email, status) VALUES
('6325128', 'João Silva', 'joao@email.com', 'ativo'),
('6325129', 'Maria Santos', 'maria@email.com', 'ativo'),
('6325130', 'Pedro Oliveira', 'pedro@email.com', 'ativo'),
('4025109', 'Seu Nome', 'seu.email@email.com', 'ativo');
```

### 5.3 Colar e Executar
- **Ctrl + V** (colar)
- **Ctrl + Enter** (executar)

**Esperado:**
```
✅ [SQL] INSERT INTO alunos...
Rows affected: 4
```

---

## 🔍 PASSO 6: Verificar Dados

### 6.1 Ver Graficamente (Recomendado)
1. No painel **esquerdo** do DBeaver, expanda:
   ```
   PostgreSQL
   └─ database-1
      └─ Databases
         └─ postgres
            └─ Schemas
               └─ public
                  └─ Tables
                     └─ alunos ← CLIQUE AQUI
   ```

2. Clique com **botão direito** em **alunos**

3. Escolha **"Select Rows"** ou **"View Data"**

4. Seus dados aparecerão:
   ```
   ┌────┬──────────┬────────────────────┬──────────────────────┬──────────────────────┬────────┐
   │ id │ ra       │ nome               │ email                │ data_inscricao       │ status │
   ├────┼──────────┼────────────────────┼──────────────────────┼──────────────────────┼────────┤
   │  1 │ 6325128  │ João Silva         │ joao@email.com       │ 2024-06-01 10:30:00  │ ativo  │
   │  2 │ 6325129  │ Maria Santos       │ maria@email.com      │ 2024-06-01 10:31:00  │ ativo  │
   │  3 │ 6325130  │ Pedro Oliveira     │ pedro@email.com      │ 2024-06-01 10:32:00  │ ativo  │
   │  4 │ 4025109  │ Seu Nome           │ seu.email@email.com  │ 2024-06-01 10:33:00  │ ativo  │
   └────┴──────────┴────────────────────┴──────────────────────┴──────────────────────┴────────┘
   ```

### 6.2 Ver com SQL (Alternativa)
- **File** → **New SQL Script**
- Cole:
  ```sql
  SELECT * FROM alunos;
  ```
- **Ctrl + Enter**
- Mesmos dados aparecerão abaixo

---

## 📸 PASSO 7: Tirar Screenshots (IMPORTANTE!)

Tire e salve em `prints/`:

### Screenshot 1: DBeaver Conectado
- Mostra o painel esquerdo com a conexão "PostgreSQL - database-1"
- Save as: `prints/01-dbeaver-conectado.png`

### Screenshot 2: Tabela Criada
- Painel esquerdo mostrando "alunos" em Tables
- Save as: `prints/02-tabela-alunos-criada.png`

### Screenshot 3: Dados Inseridos
- "Select Rows" mostrando os 4 registros
- Save as: `prints/03-dados-inseridos.png`

**Exemplo de como tirar:**
- Print Screen (ou Snipping Tool)
- Cola em Paint ou similar
- Save em PNG na pasta `prints/`

---

## 💾 PASSO 8: Criar Snapshot (Backup no AWS)

### 8.1 Ir ao Console AWS
- Acesse: https://console.aws.amazon.com
- Login com suas credenciais

### 8.2 Abrir RDS
- Procure por **RDS** (busca no topo)
- Clique em **RDS**

### 8.3 Databases
- No menu esquerdo, clique em **Databases**
- Procure por **database-1**
- Clique nela

### 8.4 Criar Snapshot
1. Clique em **Actions** (botão no topo)
2. Escolha **Create snapshot**
3. No popup, preencha:
   ```
   Snapshot identifier: snapshot-database-1-alunos
   ```
4. Clique **Create snapshot**

### 8.5 Aguardar
- Aguarde status mudar de **"Creating"** para **"Available"**
- Pode levar 1-5 minutos

### 8.6 Screenshot do Snapshot
- Quando ficar "Available", tire screenshot
- Save as: `prints/04-snapshot-created.png`

---

## 📋 PASSO 9: Atualizar README com Evidências

Abra seu `README.md` e adicione no final:

```markdown
## Evidências Práticas - Execução Q6

### 1. DBeaver Conectado ao Database-1
![Conexão DBeaver](prints/01-dbeaver-conectado.png)

**Evidência:**
- Conexão bem-sucedida ao PostgreSQL
- Banco: database-1 (us-east-2)
- Usuário: postgres
- Status: Pronto para consultas

### 2. Tabela "alunos" Criada
![Tabela Criada](prints/02-tabela-alunos-criada.png)

**Evidência:**
- Estrutura da tabela criada com sucesso
- Campos: id, ra, nome, email, data_inscricao, status
- Constraints aplicados (UNIQUE, CHECK, PRIMARY KEY)

### 3. Dados Inseridos e Verificados
![Dados Inseridos](prints/03-dados-inseridos.png)

**Evidência:**
- 4 registros inseridos com sucesso:
  - RA 6325128 - João Silva
  - RA 6325129 - Maria Santos
  - RA 6325130 - Pedro Oliveira
  - RA 4025109 - Seu Nome
- Todos com status 'ativo'
- Data de inscrição preenchida automaticamente

### 4. Snapshot (Backup) Criado
![Snapshot Criado](prints/04-snapshot-created.png)

**Evidência:**
- Snapshot snapshot-database-1-alunos criado
- Status: Available
- Backup dos dados realizado com sucesso
- Recuperação em caso de falha: Possível

---

**Data de Execução:** 01/06/2024
**Ambiente:** AWS RDS PostgreSQL (us-east-2)
**Status:** ✅ Todos os requisitos atendidos
```

---

## ✅ Checklist Final

- [ ] DBeaver instalado
- [ ] Conectado ao database-1 ✅
- [ ] Tabela "alunos" criada ✅
- [ ] 4 registros inseridos ✅
- [ ] Dados vistos em "Select Rows" ✅
- [ ] Screenshot 1: DBeaver (salvo em prints/)
- [ ] Screenshot 2: Tabela (salvo em prints/)
- [ ] Screenshot 3: Dados (salvo em prints/)
- [ ] Snapshot criado ✅
- [ ] Screenshot 4: Snapshot (salvo em prints/)
- [ ] README atualizado com evidências
- [ ] Pronto para entregar no Git

---

## 🚀 PASSO 10: Git e Pull Request

Quando tudo estiver pronto:

```bash
# 1. Ir para a pasta do repositório
cd ~/caminho/do/repositorio

# 2. Adicionar suas mudanças
git add "Aula 011/4025109/"

# 3. Fazer commit
git commit -m "4025109 - [Seu Nome]"

# 4. Fazer push
git push origin main

# 5. No GitHub:
# - Criar Pull Request
# - Título: "4025109 - [Seu Nome]"
# - Descrição: Tarefa Final - Aula 011
# - Enviar até 22:30 ⏰
```

---

## 💡 Resumo Visual

```
1️⃣ DBeaver
   ├─ New Connection → PostgreSQL
   ├─ Credenciais:
   │  ├─ Host: database-1.cl4isc6gy0kk.us-east-2.rds.amazonaws.com
   │  ├─ User: postgres
   │  └─ Pass: postgres
   └─ Test Connection → ✅

2️⃣ CREATE TABLE alunos
   └─ Execute → ✅

3️⃣ INSERT 4 registros
   └─ Execute → ✅

4️⃣ SELECT * FROM alunos
   └─ View Data → ✅

5️⃣ AWS Console
   ├─ RDS → database-1
   ├─ Actions → Create Snapshot
   └─ Status → Available → ✅

6️⃣ Screenshots (4 total)
   └─ Salvar em prints/

7️⃣ Git
   ├─ add → commit → push
   └─ Pull Request → 22:30 ⏰
```

---

## ⚠️ Problemas Comuns

### ❌ "Connection refused"
- Verifique o endpoint (cópia exata)
- Aguarde alguns segundos
- Tente novamente

### ❌ "FATAL: password authentication failed"
- Senha está errada
- Verifique: postgres (sem espaços)
- Resete no console AWS se necessário

### ❌ "Table already exists"
- Se tabela já existe, execute:
  ```sql
  DROP TABLE IF EXISTS alunos;
  ```
  Depois crie novamente

### ❌ "Public accessibility is disabled"
- Se não conseguir conectar de fora:
  - Console AWS → database-1 → Modify
  - Publicly accessible: YES
  - Apply immediately

---

**Status:** 🟢 Pronto para Começar!

Agora é só seguir os passos acima. Boa sorte! 🚀

Avisa quando conseguir conectar e criar a tabela! 👍
