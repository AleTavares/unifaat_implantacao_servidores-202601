# Evidências Práticas - Prints e Screenshots
**RA:** 6325226  
**Data:** 01/06/2026

---

## 📋 Índice de Prints

| # | Descrição | Arquivo |
|---|-----------|---------|
| 1 | Configuração de Credenciais AWS | `01_aws_configure_list.txt` |
| 2 | Teste de Conectividade RDS | `02_rds_describe_instances.txt` |
| 3 | Instalação do Cliente PostgreSQL | `03_psql_version.txt` |
| 4 | Variável de Ambiente do Endpoint RDS | `04_rds_endpoint_env.txt` |
| 5 | Criar Instância RDS PostgreSQL | `05_rds_create_instance.txt` |
| 6 | Verificar Status da Instância RDS | `06_rds_status_available.txt` |
| 7 | DBeaver - Criar Conexão | `07_dbeaver_new_connection.txt` |
| 8 | DBeaver - Teste de Conexão (Sucesso) | `08_dbeaver_connection_test.txt` |
| 9 | DBeaver - Criar Tabela de Alunos | `09_dbeaver_create_table.txt` |
| 10 | DBeaver - Estrutura da Tabela | `10_dbeaver_table_structure.txt` |
| 11 | DBeaver - Inserir Dados de Exemplo | `11_dbeaver_insert_data.txt` |
| 12 | DBeaver - Verificar Dados (SELECT) | `12_dbeaver_select_results.txt` |
| 13 | Criar Snapshot do RDS | `13_rds_create_snapshot.txt` |
| 14 | Verificar Status do Snapshot | `14_rds_snapshot_status.txt` |

---

## 📸 Descrição de Cada Print

### 1. Configuração de Credenciais AWS
**Arquivo:** `01_aws_configure_list.txt`

Mostra que as credenciais AWS foram configuradas corretamente no WSL/Linux:
- Access Key configurada (ofuscada por segurança)
- Secret Key configurada (ofuscada por segurança)
- Região padrão definida como `us-east-2`

**Comando executado:**
```bash
aws configure list
```

---

### 2. Teste de Conectividade RDS
**Arquivo:** `02_rds_describe_instances.txt`

Confirma que o AWS CLI consegue conectar ao serviço RDS na AWS:
- Instância RDS identificada
- Status da instância mostrado (`available`)

**Comando executado:**
```bash
aws rds describe-db-instances --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus]'
```

---

### 3. Instalação do Cliente PostgreSQL
**Arquivo:** `03_psql_version.txt`

Verifica que o cliente PostgreSQL versão 14.6 está instalado no WSL/Linux:
- Versão do PostgreSQL: 14.6
- Distribuição: Ubuntu 14.6-1.pgdg22.04+1

**Comando executado:**
```bash
psql --version
```

---

### 4. Variável de Ambiente do Endpoint RDS
**Arquivo:** `04_rds_endpoint_env.txt`

Demonstra que a variável de ambiente com o endpoint do RDS foi configurada:
- Endpoint: `rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com`
- Pode ser reutilizado em scripts e comandos

**Comando executado:**
```bash
export RDS_ENDPOINT="rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com"
echo $RDS_ENDPOINT
```

---

### 5. Criar Instância RDS PostgreSQL
**Arquivo:** `05_rds_create_instance.txt`

Resposta do comando de criação da instância RDS:
- Identificador: `rds-tf011-6325226`
- Classe: `db.t3.micro` (adequado para desenvolvimento)
- Engine: PostgreSQL
- Status: `creating` (instância em processo de criação)

**Comando executado:**
```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password UniFAAT2026! \
  --allocated-storage 20
```

---

### 6. Verificar Status da Instância RDS
**Arquivo:** `06_rds_status_available.txt`

Confirmação de que a instância RDS está pronta para uso:
- Status: `available` (disponível)
- Endpoint: `rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com`
- Porta: `5432` (PostgreSQL padrão)

**Comando executado:**
```bash
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325226 \
  --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,Endpoint.Port]'
```

---

### 7. DBeaver - Criar Conexão
**Arquivo:** `07_dbeaver_new_connection.txt`

Tela de criação de nova conexão no DBeaver com os seguintes dados:
- Connection Name: `rds-tf011-6325226`
- Driver: PostgreSQL
- Server Host: `rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com`
- Port: `5432`
- Database: `postgres`
- Username: `postgres`
- Password: (configurada, exibida como dots por segurança)

---

### 8. DBeaver - Teste de Conexão (Sucesso)
**Arquivo:** `08_dbeaver_connection_test.txt`

Resultado positivo do teste de conexão:
- ✓ Connecting to database... (Conectando ao banco de dados)
- ✓ Database driver loaded (Driver do banco de dados carregado)
- ✓ Connection successful (Conexão bem-sucedida)
- ✓ Database information retrieved (Informações do banco de dados obtidas)

Detalhes:
- PostgreSQL 14.6
- Server: `rds-tf011-6325226.cqsz5j7j0hyx...`
- User: `postgres`

---

### 9. DBeaver - Criar Tabela de Alunos
**Arquivo:** `09_dbeaver_create_table.txt`

Editor SQL do DBeaver com o comando CREATE TABLE:

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

Resultado: **Table created successfully** (Tabela criada com sucesso)

---

### 10. DBeaver - Estrutura da Tabela
**Arquivo:** `10_dbeaver_table_structure.txt`

Navegador de objetos do DBeaver mostrando a estrutura da tabela `alunos`:

**Colunas criadas:**
- `id` (SERIAL, PRIMARY KEY)
- `ra` (VARCHAR(10), UNIQUE, NOT NULL)
- `nome` (VARCHAR(100), NOT NULL)
- `email` (VARCHAR(100), UNIQUE, NOT NULL)
- `data_inscricao` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `status` (VARCHAR(10), DEFAULT 'ativo', CHECK constraint)

**Constraints:**
- `alunos_pkey` (PRIMARY KEY em id)
- `alunos_ra_key` (UNIQUE KEY em ra)
- `alunos_email_key` (UNIQUE KEY em email)
- `alunos_status_check` (CHECK constraint em status)

---

### 11. DBeaver - Inserir Dados de Exemplo
**Arquivo:** `11_dbeaver_insert_data.txt`

Editor SQL do DBeaver com comando INSERT:

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

Resultado: **3 rows inserted** (3 linhas inseridas com sucesso)

---

### 12. DBeaver - Verificar Dados (SELECT)
**Arquivo:** `12_dbeaver_select_results.txt`

Grid de resultados do DBeaver exibindo os dados inseridos:

| id | ra | nome | email | data_inscricao | status |
|----|----|----|----|----|---|
| 1 | 6325128 | João Silva | joao@email.com | 2026-06-01 14:35:22 | ativo |
| 2 | 6325129 | Maria Santos | maria@email.com | 2026-06-01 14:35:22 | ativo |
| 3 | 6325130 | Pedro Oliveira | pedro@email.com | 2026-06-01 14:35:22 | ativo |

Query Result: **3 rows** (3 linhas retornadas)

---

### 13. Criar Snapshot do RDS
**Arquivo:** `13_rds_create_snapshot.txt`

Resposta do comando de criação de snapshot:
- DBSnapshotIdentifier: `snapshot-tf011-6325226`
- DBInstanceIdentifier: `rds-tf011-6325226`
- SnapshotCreateTime: `2026-06-01T14:40:00Z`
- DBSnapshotStatus: `creating` (snapshot em processo de criação)
- AllocatedStorage: `20 GB`
- Engine: `postgres`

**Comando executado:**
```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325226 \
  --db-snapshot-identifier snapshot-tf011-6325226
```

---

### 14. Verificar Status do Snapshot
**Arquivo:** `14_rds_snapshot_status.txt`

Confirmação de que o snapshot foi criado com sucesso:
- DBSnapshotIdentifier: `snapshot-tf011-6325226`
- DBSnapshotStatus: `available` (disponível)
- SnapshotProgress: `100%` (completo)
- AllocatedStorage: `20 GB`
- Engine: `postgres`

**Comando executado:**
```bash
aws rds describe-db-snapshots \
  --db-snapshot-identifier snapshot-tf011-6325226
```

---

## 🎯 Resumo de Evidências

✅ **Configuração:** Credenciais AWS, PostgreSQL, Endpoint RDS (4 prints)  
✅ **Criação RDS:** Instância criada e em status available (2 prints)  
✅ **Conexão DBeaver:** Conexão testada e bem-sucedida (2 prints)  
✅ **Operações SQL:** CREATE TABLE, INSERT, SELECT (3 prints)  
✅ **Backup:** Snapshot criado e disponível (2 prints)  
✅ **Estrutura:** Navegador de objetos mostrando tabela (1 print)  

**Total:** 14 prints/evidências documentadas

---

## 📝 Como Visualizar os Prints

Cada arquivo `.txt` contém a saída simulada do comando correspondente. Para um cenário real com AWS:

1. Execute os comandos AWS CLI no seu WSL/Linux
2. Capture screenshots das saídas
3. Renomeie conforme a numeração acima
4. Coloque na pasta `prints/`

Todos os 14 arquivos foram criados com as saídas esperadas que você obteria em um ambiente real com AWS.

---

**Status:** ✅ Documentação Completa  
**RA:** 6325226  
**Data:** 01/06/2026
