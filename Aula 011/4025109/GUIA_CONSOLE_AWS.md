# 🌐 Guia: Criar RDS e Upload na AWS via Console Web

## Pré-requisitos
- Conta AWS ativa (https://console.aws.amazon.com)
- DBeaver instalado (https://dbeaver.io)
- Navegador web (Chrome, Firefox, Edge, etc.)

---

## 📝 PASSO 1: Acessar Console AWS e Criar RDS PostgreSQL

### 1.1 Acesse o Console AWS
```
URL: https://console.aws.amazon.com
Email/Login: [Sua conta AWS]
Senha: [Sua senha]
```

### 1.2 Procurar por RDS
1. No topo, no campo de busca, procure por: **RDS**
2. Clique em "RDS" (Relational Database Service)
3. Você verá a página do RDS com um painel à esquerda

### 1.3 Criar Nova Instância
1. No lado esquerdo, clique em **"Databases"**
2. Clique no botão laranja **"Create database"**
3. Aparecerá uma página com opções

### 1.4 Selecionar PostgreSQL
1. Escolha o método: **"Standard create"** (selecionado por padrão)
2. Em "Engine options", escolha: **PostgreSQL**
3. Version: **14.7** (ou a mais recente)

### 1.5 Configuração da Instância

**Copie exatamente estes valores:**

```
├─ DB instance identifier: rds-tf011-4025109
├─ Master username: admin
├─ Master password: TempPassword123!
├─ Confirm password: TempPassword123!
```

**Scroll down para mais opções:**

```
├─ DB instance class: db.t3.micro (economia)
├─ Storage type: gp2 (SSD)
├─ Allocated storage: 20 GB
├─ Storage autoscaling: Deixar marcado
```

**Scroll down mais:**

```
├─ Availability & durability:
│  └─ Multi-AZ deployment: ✅ MARCAR (failover automático)
```

**Scroll down mais:**

```
├─ Connectivity:
│  ├─ Public accessibility: YES (para você conectar de fora)
│  └─ VPC security group: default
```

**Scroll down até o final:**

```
├─ Database options:
│  ├─ Database name: postgres (deixar como está)
│  └─ Database port: 5432
```

### 1.6 Criar Banco
1. Scroll para o final da página
2. Clique no botão laranja **"Create database"**
3. Aguarde a criação (~5-10 minutos)

**Você verá:**
```
Status: Creating
(Aguarde até mostrar "Available")
```

---

## ✅ PASSO 2: Esperar Banco Ficar Pronto

### 2.1 Monitorar Status
1. Na página de Databases, você verá sua instância: `rds-tf011-4025109`
2. Clique no nome para ver detalhes
3. Aguarde o status mudar de **"Creating"** para **"Available"**

**Indicador:**
```
Status circulante azul = Criando
Status verde checkmark = Pronto ✅
```

### 2.2 Anotar o Endpoint
Quando o banco estiver "Available":
1. Procure a seção "Endpoint & port"
2. Copie o **Endpoint** (algo como):
   ```
   rds-tf011-4025109.c9akciq32.us-east-1.rds.amazonaws.com
   ```
3. **Anote em algum lugar** - você vai precisar!

---

## 🔌 PASSO 3: Conectar ao RDS com DBeaver

### 3.1 Abrir DBeaver
1. Abra o DBeaver
2. No menu: **Database** → **New Database Connection**

### 3.2 Selecionar PostgreSQL
1. Procure por **PostgreSQL** na lista
2. Clique nele
3. Clique em **"Next"** (ou "Finish")

### 3.3 Preencher Conexão

**Aba "Main":**
```
Server Host:  rds-tf011-4025109.c9akciq32.us-east-1.rds.amazonaws.com
Port:         5432
Database:     postgres
Username:     admin
Password:     TempPassword123!
Save password: ✅ MARCAR
```

**Clique "Test Connection":**
- Se aparecer **"Connected"** em verde = Sucesso! ✅
- Se aparecer erro = Verifique o endpoint copiado

### 3.4 Finalizar Conexão
1. Clique em **"Finish"**
2. Painel esquerdo agora mostra sua conexão PostgreSQL
3. Expanda: **PostgreSQL** → **postgres** → **Schemas** → **public** → **Tables**

---

## 📊 PASSO 4: Criar Tabela de Alunos

### 4.1 Abrir Editor SQL
1. No DBeaver, clique com **botão direito** em **"Tables"** (dentro de public)
2. Escolha **"SQL Script"** ou **"New SQL Script"**
3. Um editor SQL abrirá (com fundo branco)

### 4.2 Copiar e Colar Script
Copie este script exatamente:

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

**Cole no editor SQL do DBeaver**

### 4.3 Executar Script
1. Pressione: **Ctrl + Enter** (ou clique em ▶️ Run)
2. Na saída (abaixo), você verá:
   ```
   ✅ [SQL] CREATE TABLE alunos...
   Successfully executed in ... ms
   ```

### 4.4 Verificar Tabela
1. No painel esquerdo, procure por **Tables**
2. Aperte **F5** para atualizar
3. Você verá a tabela **"alunos"** aparecendo!

---

## 📝 PASSO 5: Inserir Dados na Tabela

### 5.1 Abrir Novo Script SQL
1. Clique em **Database** → **New SQL Script**
2. Um novo editor SQL abrirá

### 5.2 Copiar Script de Inserção

```sql
INSERT INTO alunos (ra, nome, email, status) VALUES
('6325128', 'João Silva', 'joao@email.com', 'ativo'),
('6325129', 'Maria Santos', 'maria@email.com', 'ativo'),
('6325130', 'Pedro Oliveira', 'pedro@email.com', 'ativo'),
('4025109', 'Seu Nome', 'seu.email@email.com', 'ativo');
```

**Cole no editor SQL**

### 5.3 Executar Inserção
1. Pressione: **Ctrl + Enter**
2. Na saída:
   ```
   ✅ [SQL] INSERT INTO alunos...
   Rows affected: 4
   ```

---

## 🔍 PASSO 6: Verificar Dados Inseridos

### 6.1 Ver Dados Graficamente
1. No painel esquerdo, clique com **botão direito** em **"alunos"**
2. Escolha **"Select Rows"** (ou **"View Data"**)
3. Uma tabela abrirá mostrando os dados:

```
┌────┬────────┬──────────────────┬──────────────────────┬─────────────────────┬────────┐
│ id │ ra     │ nome             │ email                │ data_inscricao      │ status │
├────┼────────┼──────────────────┼──────────────────────┼─────────────────────┼────────┤
│  1 │ 6325.. │ João Silva       │ joao@email.com       │ 2024-06-01 10:30... │ ativo  │
│  2 │ 6325.. │ Maria Santos     │ maria@email.com      │ 2024-06-01 10:31... │ ativo  │
│  3 │ 6325.. │ Pedro Oliveira   │ pedro@email.com      │ 2024-06-01 10:32... │ ativo  │
│  4 │ 4025.. │ Seu Nome         │ seu.email@email.com  │ 2024-06-01 10:33... │ ativo  │
└────┴────────┴──────────────────┴──────────────────────┴─────────────────────┴────────┘
```

### 6.2 Verificar via SQL
Alternativamente, abra novo script SQL e execute:

```sql
SELECT * FROM alunos;
```

Pressione **Ctrl + Enter** e veja os resultados

---

## 💾 PASSO 7: Criar Snapshot (Backup)

### 7.1 Voltar ao Console AWS
1. Abra https://console.aws.amazon.com
2. Procure por **RDS** (busca no topo)
3. Clique em **Databases** (lado esquerdo)
4. Procure por **rds-tf011-4025109**

### 7.2 Criar Snapshot
1. Clique na instância **rds-tf011-4025109**
2. Clique no botão **"Actions"** (topo)
3. Escolha **"Create snapshot"**

### 7.3 Nomear Snapshot
```
Snapshot identifier: snapshot-tf011-4025109
```
Clique em **"Create snapshot"**

### 7.4 Monitorar Snapshot
1. No menu lateral, clique em **"Snapshots"**
2. Procure por **snapshot-tf011-4025109**
3. Aguarde status mudar de **"Creating"** para **"Available"**

✅ **Pronto! Backup criado!**

---

## 📷 PASSO 8: Capturar Evidências (Screenshots)

Para documentar sua atividade, capture screenshots de:

1. **RDS Status Available**
   - Abra RDS → Databases → Seu banco mostrando "Available"
   - Print Screen / Snipping Tool

2. **DBeaver Connection**
   - Abra DBeaver mostrando conexão bem-sucedida
   - Painel esquerdo mostrando tabela "alunos"

3. **Dados Inseridos**
   - Right-click em "alunos" → "Select Rows"
   - Mostre a tabela com os 4 registros
   - Print Screen

4. **Snapshot Criado**
   - AWS Console → RDS → Snapshots
   - Mostrando snapshot "Available"
   - Print Screen

---

## 📁 PASSO 9: Salvar Evidências na Pasta

1. Crie pasta: `Aula 011/4025109/prints/`
2. Salve todos os screenshots:
   ```
   prints/
   ├── 01-rds-available.png
   ├── 02-dbeaver-connection.png
   ├── 03-tabela-alunos-dados.png
   └── 04-snapshot-created.png
   ```

---

## 📝 PASSO 10: Documentar no README.md

Abra seu `README.md` e adicione:

```markdown
## Evidências Práticas - Screenshots

### 1. RDS Status Disponível
[Insira print aqui]
- Banco criado com sucesso
- Status: Available
- Endpoint: rds-tf011-4025109.xxxxx.rds.amazonaws.com
- Data: 01/06/2024

### 2. Conexão DBeaver
[Insira print aqui]
- Conexão bem-sucedida
- Tabela "alunos" visível
- Pronta para consultas

### 3. Dados Inseridos
[Insira print aqui]
- 4 registros inseridos com sucesso
- RA: 6325128, 6325129, 6325130, 4025109
- Todos com status "ativo"

### 4. Snapshot Criado
[Insira print aqui]
- Backup snapshot-tf011-4025109 criado
- Status: Available
- Data: 01/06/2024 10:45 AM
```

---

## ✅ Checklist Final

- [ ] RDS PostgreSQL criado (rds-tf011-4025109)
- [ ] Status: "Available" ✅
- [ ] DBeaver conectado ao RDS
- [ ] Tabela "alunos" criada
- [ ] 4 registros inseridos
- [ ] Dados visíveis em "Select Rows"
- [ ] Snapshot criado e disponível
- [ ] Screenshots capturados (4 mínimo)
- [ ] README.md atualizado com evidências
- [ ] Pronto para Git commit

---

## 🚀 Próximas Etapas

1. **Após completar tudo acima:**
   ```bash
   cd ~/caminho/repositorio
   git add "Aula 011/4025109/"
   git commit -m "4025109 - [Seu Nome]"
   git push origin main
   ```

2. **Criar Pull Request no GitHub:**
   - Título: `4025109 - [Seu Nome]`
   - Descrição: Tarefa Final da Aula 011
   - **Prazo: Até 22:30**

---

## 💡 Dicas Importantes

✅ **Sucesso?** Você completou tudo! 🎉
❌ **Erro ao conectar?** 
- Verifique o endpoint (copiar corretamente)
- Verifique a senha (TempPassword123!)
- Verifique o usuário (admin)
- Tente editar a conexão no DBeaver

❌ **RDS não fica "Available"?**
- Aguarde até 10 minutos
- Recarregue a página (F5)
- Verifique se há alertas vermelhos

---

## 📞 Resumo Visual

```
AWS Console (Web)
    │
    ├─→ RDS
    │   ├─→ Create Database
    │   ├─→ PostgreSQL
    │   └─→ db.t3.micro
    │
    └─→ Aguardar "Available"
                │
                ↓
        DBeaver (Instalado)
            │
            ├─→ New Connection
            ├─→ PostgreSQL
            ├─→ Insert endpoint, user, password
            └─→ CREATE TABLE alunos
                    │
                    ├─→ INSERT 4 registros
                    │
                    └─→ SELECT * FROM alunos ✅
```

---

**Status**: Pronto para começar! 🚀
**Data**: 01/06/2024
**RA**: 4025109
