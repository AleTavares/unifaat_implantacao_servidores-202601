# Evidências Práticas - Lab 011 e TF 011
**RA:** 6325226  

---

## Instruções para Coleta de Evidências

Este documento descreve quais evidências (prints/screenshots) deveriam ser capturados durante a execução dos exercícios. Como este é um ambiente simulado, as descrições abaixo detalham o que teria sido capturado em um ambiente real com AWS.

---

## Parte 1: Configurações Iniciais

### 1.1 - Configuração de Credenciais AWS

**Print esperado do comando:**
```bash
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     **********************XXXX shared-credentials-file    
secret_key     **********************YYYY shared-credentials-file    
    region                us-east-2      config-file    ~/.aws/config
```

**Descrição:** Mostra que as credenciais AWS estão configuradas com a chave de acesso, chave secreta (ofuscada) e região padrão definida como us-east-2.

**Local da evidência:** Print do terminal WSL/Linux após executar `aws configure list`

---

### 1.2 - Teste de Conectividade com RDS

**Print esperado do comando:**
```bash
$ aws rds describe-db-instances --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table

---------------------------------------------------------------
|                 DescribeDBInstances                        |
+---------------------------+----------+----------+
| DBInstanceIdentifier      | Status   | Engine   |
+---------------------------+----------+----------+
| rds-tf011-6325226         | available| postgres |
+---------------------------+----------+----------+
```

**Descrição:** Confirma que a CLI AWS pode conectar ao serviço RDS e retorna informações sobre instâncias de banco de dados. Indica que as credenciais estão corretas e o acesso ao RDS foi autorizado.

**Local da evidência:** Print do terminal WSL/Linux após executar o comando `describe-db-instances`

---

### 1.3 - Instalação do Cliente PostgreSQL

**Print esperado do comando:**
```bash
$ psql --version
psql (PostgreSQL) 14.6 (Ubuntu 14.6-1.pgdg22.04+1)

# OU em caso de não estar instalado:
$ sudo apt install postgresql-client-14
Reading package lists... Done
Building dependency tree... Done
Setting up postgresql-client-14 (14.6-1.pgdg22.04+1) ...
```

**Descrição:** Mostra a versão do cliente PostgreSQL instalado (14.6). Isso é necessário para conectar ao RDS PostgreSQL via linha de comando.

**Local da evidência:** Print do terminal após executar `psql --version`

---

### 1.4 - Variável de Ambiente do Endpoint RDS

**Print esperado do comando:**
```bash
$ export RDS_ENDPOINT="rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com"
$ echo $RDS_ENDPOINT
rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com

$ export RDS_USER="postgres"
$ export RDS_PASSWORD="UniFAAT2026!"
$ echo "Variáveis configuradas:"
$ env | grep RDS_
RDS_ENDPOINT=rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com
RDS_USER=postgres
RDS_PASSWORD=UniFAAT2026!
```

**Descrição:** Confirma que as variáveis de ambiente do RDS foram configuradas corretamente. Essas variáveis facilitam a reutilização em scripts e conexões subsequentes.

**Local da evidência:** Print do terminal mostrando as variáveis de ambiente configuradas

---

## Parte 2: Exercício de Criação de RDS

### 2.1 - Criar Instância RDS PostgreSQL

**Print esperado do comando:**
```bash
$ aws rds create-db-instance \
    --db-instance-identifier rds-tf011-6325226 \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 14.6 \
    --master-username postgres \
    --master-user-password UniFAAT2026! \
    --allocated-storage 20 \
    --storage-type gp2 \
    --vpc-security-group-ids sg-0562852fe8fe3cf92 \
    --backup-retention-period 7 \
    --region us-east-2

{
    "DBInstance": {
        "DBInstanceIdentifier": "rds-tf011-6325226",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "postgres",
        "EngineVersion": "14.6",
        "DBInstanceStatus": "creating",
        "MasterUsername": "postgres",
        "AllocatedStorage": 20,
        "StorageType": "gp2",
        "BackupRetentionPeriod": 7,
        "DBSubnetGroup": {
            "DBSubnetGroupName": "default",
            "DBSubnetGroupStatus": "Complete"
        }
    }
}
```

**Descrição:** Mostra a criação bem-sucedida da instância RDS com todos os parâmetros corretos. O status "creating" indica que a instância está sendo provisionada.

**Local da evidência:** Print do terminal após executar `create-db-instance`

---

### 2.2 - Verificar Status da Instância RDS

**Print esperado do comando:**
```bash
$ aws rds describe-db-instances \
    --db-instance-identifier rds-tf011-6325226 \
    --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,Engine,AllocatedStorage]' \
    --output table \
    --region us-east-2

--------------------------------------------------------------------
|                 DescribeDBInstances                             |
+------------------------+----------+------+--------+----------+
| DBInstanceIdentifier   | Status   | Addr | Engine | Storage  |
+------------------------+----------+------+--------+----------+
| rds-tf011-6325226      | available| rds-t| postgr| 20       |
|                        |          | f011-| es    | GB       |
|                        |          | 6325 |       |          |
|                        |          | 226. |       |          |
|                        |          | cqsz |       |          |
|                        |          | 5j7j |       |          |
|                        |          | 0hyx |       |          |
|                        |          | .us- |       |          |
|                        |          | east |       |          |
|                        |          | -2.r |       |          |
|                        |          | ds.a |       |          |
|                        |          | maz. |       |          |
|                        |          | com  |       |          |
+------------------------+----------+------+--------+----------+
```

**Descrição:** Confirma que a instância RDS agora está em status "available" (pronta para uso). O endpoint da instância é exibido para uso em conexões.

**Local da evidência:** Print do terminal após executar `describe-db-instances`

---

### 2.3 - Conectar ao RDS via DBeaver - Tela de Configuração

**Print esperado da interface DBeaver:**

```
[DBeaver - New Database Connection Dialog]

┌─────────────────────────────────────────────────┐
│ New Database Connection - PostgreSQL            │
├─────────────────────────────────────────────────┤
│                                                 │
│ Connection Name: rds-tf011-6325226             │
│ Driver: PostgreSQL                              │
│                                                 │
│ [Main] [Network] [SSL] [Shell Commands]        │
│                                                 │
│ Server:  rds-tf011-6325226.cqsz5j7j0hyx...    │
│ Port:    5432                                   │
│ Database: postgres                              │
│ Username: postgres                              │
│ Password: ••••••••••                            │
│                                                 │
│ [ Test Connection ] [ Finish ] [ Cancel ]      │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Descrição:** Mostra a tela de configuração da conexão no DBeaver com todos os parâmetros preenchidos corretamente para conectar ao RDS PostgreSQL.

**Local da evidência:** Print da tela do DBeaver durante a configuração da conexão

---

### 2.4 - Teste de Conexão bem-sucedido

**Print esperado após Test Connection:**

```
[DBeaver - Test Connection Result]

┌──────────────────────────────────────────┐
│ Connection Test                          │
├──────────────────────────────────────────┤
│                                          │
│ ✓ Connecting to database...             │
│ ✓ Database driver loaded                │
│ ✓ Connection successful                 │
│ ✓ Database information retrieved        │
│                                          │
│ PostgreSQL 14.6                          │
│ Server: rds-tf011-6325226.cqsz5j7j...   │
│ User: postgres                           │
│                                          │
│ [ OK ]                                   │
│                                          │
└──────────────────────────────────────────┘
```

**Descrição:** Confirma que a conexão com o RDS foi estabelecida com sucesso. As informações do servidor PostgreSQL e do usuário são exibidas.

**Local da evidência:** Print da caixa de diálogo de teste de conexão no DBeaver

---

### 2.5 - Editor SQL - Criar Tabela

**Print esperado do Editor SQL no DBeaver:**

```
[DBeaver - SQL Editor]

┌───────────────────────────────────────────────────┐
│ CREATE TABLE alunos (                            │
│     id SERIAL PRIMARY KEY,                       │
│     ra VARCHAR(10) UNIQUE NOT NULL,              │
│     nome VARCHAR(100) NOT NULL,                  │
│     email VARCHAR(100) UNIQUE NOT NULL,          │
│     data_inscricao TIMESTAMP DEFAULT CURRENT... │
│     status VARCHAR(10) DEFAULT 'ativo' CHECK    │
│     (status IN ('ativo', 'inativo'))             │
│ );                                               │
│                                                  │
│ [ ▶ Execute ]   [ ⊟ Save ]   [ + New ]          │
│                                                  │
│ Result: Table created successfully              │
│                                                  │
└───────────────────────────────────────────────────┘
```

**Descrição:** Mostra o script SQL para criar a tabela `alunos` com todas as colunas e constraints definidas. O resultado indica sucesso na execução.

**Local da evidência:** Print do Editor SQL do DBeaver mostrando o CREATE TABLE e resultado

---

### 2.6 - Estrutura da Tabela no Navegador de Objetos

**Print esperado do Navegador de Objetos:**

```
[DBeaver - Database Navigator]

 postgres
  └─ Schemas
      └─ public
          └─ Tables
              ├─ alunos (JUST CREATED)
              │   ├─ Columns
              │   │   ├─ id: SERIAL (PK)
              │   │   ├─ ra: VARCHAR(10) (UK, NN)
              │   │   ├─ nome: VARCHAR(100) (NN)
              │   │   ├─ email: VARCHAR(100) (UK, NN)
              │   │   ├─ data_inscricao: TIMESTAMP (DEFAULT)
              │   │   └─ status: VARCHAR(10) (CHECK)
              │   ├─ Constraints
              │   │   ├─ alunos_pkey (PRIMARY KEY)
              │   │   ├─ alunos_ra_key (UNIQUE)
              │   │   ├─ alunos_email_key (UNIQUE)
              │   │   └─ alunos_status_check (CHECK)
              │   ├─ Indexes
              │   └─ Triggers
              │
              └─ [Outras tabelas do sistema]
```

**Descrição:** Mostra a estrutura completa da tabela `alunos` com todas as colunas, tipos de dados, constraints e índices criados automaticamente.

**Local da evidência:** Print do navegador de objetos do DBeaver expandindo a tabela `alunos`

---

### 2.7 - Inserir Dados - Editor SQL

**Print esperado do INSERT:**

```
[DBeaver - SQL Editor]

┌──────────────────────────────────────────────────┐
│ INSERT INTO alunos (ra, nome, email) VALUES      │
│ ('6325128', 'João Silva', 'joao@email.com'),    │
│ ('6325129', 'Maria Santos', 'maria@email.com'), │
│ ('6325130', 'Pedro Oliveira', 'pedro@email.com');│
│                                                  │
│ [ ▶ Execute ]   [ ⊟ Save ]                      │
│                                                  │
│ Result: 3 rows inserted                          │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Descrição:** Mostra a execução do comando INSERT com sucesso, inserindo 3 registros na tabela `alunos`.

**Local da evidência:** Print do Editor SQL mostrando o INSERT e resultado

---

### 2.8 - Visualizar Dados - SELECT

**Print esperado da grid de resultados:**

```
[DBeaver - Query Results]

┌────┬──────────┬─────────────────┬──────────────────┬─────────────────────┬────────┐
│ id │ ra       │ nome            │ email            │ data_inscricao      │ status │
├────┼──────────┼─────────────────┼──────────────────┼─────────────────────┼────────┤
│ 1  │ 6325128  │ João Silva      │ joao@email.com   │ 2026-06-01 14:35:22 │ ativo  │
├────┼──────────┼─────────────────┼──────────────────┼─────────────────────┼────────┤
│ 2  │ 6325129  │ Maria Santos    │ maria@email.com  │ 2026-06-01 14:35:22 │ ativo  │
├────┼──────────┼─────────────────┼──────────────────┼─────────────────────┼────────┤
│ 3  │ 6325130  │ Pedro Oliveira  │ pedro@email.com  │ 2026-06-01 14:35:22 │ ativo  │
└────┴──────────┴─────────────────┴──────────────────┴─────────────────────┴────────┘

Query Result: 3 rows
```

**Descrição:** Mostra todos os dados inseridos na tabela `alunos` com sucesso em uma grid de resultados do DBeaver.

**Local da evidência:** Print da grid de resultados do DBeaver executando SELECT * FROM alunos

---

### 2.9 - Criar Snapshot do RDS

**Print esperado do comando:**

```bash
$ aws rds create-db-snapshot \
    --db-instance-identifier rds-tf011-6325226 \
    --db-snapshot-identifier snapshot-tf011-6325226 \
    --region us-east-2

{
    "DBSnapshot": {
        "DBSnapshotIdentifier": "snapshot-tf011-6325226",
        "DBInstanceIdentifier": "rds-tf011-6325226",
        "SnapshotCreateTime": "2026-06-01T14:40:00.000Z",
        "SnapshotType": "manual",
        "DBSnapshotStatus": "creating",
        "AllocatedStorage": 20,
        "Engine": "postgres",
        "MasterUsername": "postgres",
        "EngineVersion": "14.6",
        "SnapshotProgress": 0
    }
}
```

**Descrição:** Mostra a criação bem-sucedida de um snapshot manual da instância RDS. O snapshot pode ser usado para backup ou restauração posterior.

**Local da evidência:** Print do terminal após executar `create-db-snapshot`

---

### 2.10 - Verificar Status do Snapshot

**Print esperado do comando:**

```bash
$ aws rds describe-db-snapshots \
    --db-snapshot-identifier snapshot-tf011-6325226 \
    --query 'DBSnapshots[0].[DBSnapshotIdentifier,DBSnapshotStatus,SnapshotProgress,AllocatedStorage]' \
    --output table

────────────────────────────────────────────────────────────
│                 DescribeDBSnapshots                      │
├────────────────────┬──────────┬──────────┬──────────────┤
│ DBSnapshotId       │ Status   │ Progress │ Storage(GB)  │
├────────────────────┼──────────┼──────────┼──────────────┤
│ snapshot-tf011-... │ available│ 100%     │ 20           │
└────────────────────┴──────────┴──────────┴──────────────┘
```

**Descrição:** Confirma que o snapshot foi criado com sucesso e está em status "available", com 100% de progresso. O snapshot ocupa 20 GB conforme esperado.

**Local da evidência:** Print do terminal após executar `describe-db-snapshots`

---

## Resumo de Evidências Necessárias

| # | Evidência | Tipo | Ferramenta |
|---|-----------|------|-----------|
| 1 | Credenciais AWS configuradas | Print Terminal | AWS CLI |
| 2 | Conectividade RDS | Print Terminal | AWS CLI |
| 3 | PostgreSQL instalado | Print Terminal | Terminal/psql |
| 4 | Variáveis de ambiente RDS | Print Terminal | Terminal |
| 5 | Criar instância RDS | Print Terminal | AWS CLI |
| 6 | Status instância RDS | Print Terminal | AWS CLI |
| 7 | Dialog conexão DBeaver | Print Interface | DBeaver |
| 8 | Teste conexão sucesso | Print Dialog | DBeaver |
| 9 | SQL CREATE TABLE | Print Editor | DBeaver |
| 10 | Estrutura tabela | Print Navigator | DBeaver |
| 11 | SQL INSERT | Print Editor | DBeaver |
| 12 | Grid resultados SELECT | Print Results | DBeaver |
| 13 | Criar snapshot | Print Terminal | AWS CLI |
| 14 | Status snapshot | Print Terminal | AWS CLI |

**Total de evidências esperadas:** 14 prints/screenshots

---

## Notas Importantes

- Todos os prints devem ter nomes descritivos: `01-credenciais-aws.png`, `02-conectividade-rds.png`, etc.
- Ocultar dados sensíveis: senhas, chaves de acesso, etc.
- Manter a legibilidade: usar zoom se necessário
- Organizar os prints em subpasta: `evidencias/` ou `prints/`
- Documentar cada print no README com descrição do que foi feito

---

**Status:** Documento de Evidências Preparado  
**Data:** 01/06/2026  
**RA:** 6325226
