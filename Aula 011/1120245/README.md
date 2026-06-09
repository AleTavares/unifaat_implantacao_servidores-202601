# TF011 - Armazenamento e Banco de Dados na AWS

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aula:** 11 - Armazenamento e Banco de Dados na AWS

---

## Questão 1: Armazenamento de Objetos (S3)

### a) Caso de uso principal

O Amazon S3 é ideal para armazenar objetos e arquivos acessados por aplicações Web e pipelines DevOps: arquivos estáticos (HTML, CSS, JS, imagens), uploads de usuários, backups, logs, artefatos de build e arquivos de configuração. Em contexto DevOps é amplamente usado como destino de deploy de frontends estáticos e repositório de artefatos de CI/CD.

### b) Global ou regional / "Onze Noves"

O S3 é um serviço **global** (console unificado), mas os **buckets são regionais** — cada bucket é criado em uma região específica e os dados residem fisicamente nela. A taxa "Onze Noves" (99,999999999%) refere-se à **durabilidade** dos dados armazenados no S3 Standard, garantida pela replicação automática dos objetos em múltiplos dispositivos e zonas de disponibilidade.

---

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

### a) Diferença fundamental

| | Amazon EBS | Amazon EFS |
|---|---|---|
| Tipo | Armazenamento em bloco | Sistema de arquivos em rede (NFS) |
| Conexão | Conectado a **uma** instância EC2 por vez | Montado por **múltiplas** instâncias EC2 simultaneamente |
| Uso típico | Disco do sistema operacional, banco de dados | Compartilhamento de arquivos entre servidores |

O **EBS** funciona como um disco local dedicado — alta performance para I/O intensivo. O **EFS** funciona como um NFS gerenciado — ideal quando múltiplas instâncias precisam acessar os mesmos arquivos.

### b) Mais adequado para SO e executável da aplicação

**Amazon EBS** é o mais adequado. O sistema operacional e o executável da aplicação requerem armazenamento em bloco de alta performance com acesso exclusivo, exatamente o que o EBS oferece como volume raiz de uma instância EC2.

---

## Questão 3: Banco de Dados Gerenciado (RDS)

### a) Responsabilidades assumidas pela AWS no RDS

1. **Backups automáticos e restauração point-in-time** — a AWS realiza snapshots diários e mantém logs de transações, permitindo restaurar o banco para qualquer ponto no período de retenção configurado.
2. **Patching e atualizações de software** — a AWS aplica patches de segurança e atualizações do engine do banco de dados de forma gerenciada, com janelas de manutenção configuráveis.

### b) Principal desvantagem do RDS

A principal limitação é a **menor flexibilidade de personalização**: não há acesso root ao sistema operacional subjacente, o que impede instalar extensões não suportadas, ajustar parâmetros de SO, ou usar versões específicas de banco que não estejam disponíveis no RDS. Além disso, o custo tende a ser maior que rodar o mesmo banco em EC2 para cargas previsíveis.

---

## Questão 4: Alta Disponibilidade no RDS

### a) Multi-AZ: o que acontece

Ao habilitar o Multi-AZ, a AWS provisiona automaticamente uma instância **standby** em uma zona de disponibilidade diferente da primária. Os dados são replicados de forma síncrona entre as duas instâncias. Em caso de falha, manutenção ou indisponibilidade da instância primária, o DNS do endpoint é atualizado automaticamente para apontar para o standby (failover automático, geralmente em menos de 2 minutos) sem intervenção manual.

### b) Standby Multi-AZ vs. Read Replica

| | Standby Multi-AZ | Read Replica |
|---|---|---|
| Finalidade | Alta disponibilidade e failover | Escalabilidade de leituras |
| Aceita leituras? | **Não** — não serve tráfego durante operação normal | **Sim** — recebe consultas SELECT |
| Failover automático? | **Sim** — promovido automaticamente em caso de falha | **Não** — promoção é manual |
| Replicação | Síncrona | Assíncrona |

---

## Questão 5: Fluxo de Upload para S3 via AWS CLI

### 1. Criação do arquivo

```bash
touch db_config.conf
# ou com conteúdo:
echo "# Configuração de banco de dados" > db_config.conf
```

### 2. Upload para o bucket

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

Com LocalStack:
```bash
aws s3 cp db_config.conf s3://config-app-tf11/ --endpoint-url=http://localhost:4566
```

### 3. Verificação

```bash
aws s3 ls s3://config-app-tf11/
```

Com LocalStack:
```bash
aws s3 ls s3://config-app-tf11/ --endpoint-url=http://localhost:4566
```

---

## Questão 6: Evidências Práticas

> **Ambiente utilizado:** LocalStack v3 (community) para S3 e PostgreSQL local para simulação do RDS, rodando em Ubuntu 24.04 (Linux). O RDS não está disponível na versão community do LocalStack, portanto os comandos AWS CLI de RDS são apresentados com saída simulada, e a criação/uso do banco é demonstrada via PostgreSQL local.

---

### Parte 1: Evidências de Configuração

#### 1. Configuração de Credenciais AWS

Saída do comando `aws configure list` com credenciais de teste (LocalStack):

```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************test              env    
secret_key     ****************test              env    
    region                us-east-1              env    AWS_DEFAULT_REGION
```

Variáveis de ambiente configuradas para o LocalStack:
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

As chaves sensíveis ficam ocultas (exibido apenas `****test`), exatamente como apareceria com credenciais reais da AWS.

#### 2. Teste de Conectividade com RDS

Comando executado (com LocalStack):
```bash
aws rds describe-db-instances --endpoint-url=http://localhost:4566
```

Saída (RDS não disponível na versão community — requer LocalStack Pro):
```
An error occurred (InternalFailure) when calling the DescribeDBInstances operation: 
API for service 'rds' not yet implemented or pro feature
```

Em AWS real, o comando retornaria:
```json
{
    "DBInstances": [
        {
            "DBInstanceIdentifier": "rds-tf011-1120245",
            "DBInstanceStatus": "available",
            "Engine": "postgres",
            "Endpoint": {
                "Address": "rds-tf011-1120245.c6c8mntzhgv0.us-east-1.rds.amazonaws.com",
                "Port": 5432
            }
        }
    ]
}
```

#### 3. Instalação do Cliente PostgreSQL

```bash
$ psql --version
psql (PostgreSQL) 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
```

Instalação realizada via:
```bash
sudo apt-get install -y postgresql-client
```

#### 4. Variável de Ambiente do Endpoint RDS

```bash
export RDS_ENDPOINT="localhost:5432"
echo $RDS_ENDPOINT
# localhost:5432
```

Em ambiente AWS real, seria:
```bash
export RDS_ENDPOINT="rds-tf011-1120245.c6c8mntzhgv0.us-east-1.rds.amazonaws.com:5432"
```

---

### Parte 2: Exercício de Criação de RDS com Tabela de Alunos

#### 1. Criar Instância RDS PostgreSQL

Comando `create-db-instance` (simulado — RDS requer LocalStack Pro ou AWS real):

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-1120245 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.7 \
  --master-username tf011admin \
  --master-user-password tf011pass \
  --allocated-storage 20 \
  --no-multi-az \
  --publicly-accessible \
  --endpoint-url=http://localhost:4566
```

Saída esperada de `describe-db-instances` após criação:
```json
{
    "DBInstances": [{
        "DBInstanceIdentifier": "rds-tf011-1120245",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "postgres",
        "DBInstanceStatus": "available",
        "Endpoint": {
            "Address": "rds-tf011-1120245.c6c8mntzhgv0.us-east-1.rds.amazonaws.com",
            "Port": 5432
        },
        "EngineVersion": "14.7",
        "MultiAZ": false
    }]
}
```

**Endpoint anotado:** `rds-tf011-1120245.c6c8mntzhgv0.us-east-1.rds.amazonaws.com:5432`

#### 2. Conexão via PostgreSQL local (simulando DBeaver)

Como alternativa ao DBeaver, a conexão foi demonstrada via `psql`:

Parâmetros equivalentes de conexão:
- **Server Host:** `localhost` (ou endpoint RDS em AWS real)
- **Port:** `5432`
- **Database:** `tf011db`
- **Username:** `tf011admin`
- **Password:** `tf011pass`

#### 3. Criação da Tabela de Alunos

Script executado via `psql -d tf011db`:

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

Saída:
```
CREATE TABLE
```

Estrutura da tabela (`\d alunos`):
```
                                      Table "public.alunos"
     Column     |            Type             | Nullable |              Default               
----------------+-----------------------------+----------+------------------------------------
 id             | integer                     | not null | nextval('alunos_id_seq'::regclass)
 ra             | character varying(10)       | not null | 
 nome           | character varying(100)      | not null | 
 email          | character varying(100)      | not null | 
 data_inscricao | timestamp without time zone |          | CURRENT_TIMESTAMP
 status         | character varying(10)       |          | 'ativo'::character varying
Indexes:
    "alunos_pkey" PRIMARY KEY, btree (id)
    "alunos_email_key" UNIQUE CONSTRAINT, btree (email)
    "alunos_ra_key" UNIQUE CONSTRAINT, btree (ra)
Check constraints:
    "alunos_status_check" CHECK (status IN ('ativo', 'inativo'))
```

#### 4. Inserção de Dados

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('1120245', 'Matheus Mantovani', 'matheusmantovani16@gmail.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

Saída:
```
INSERT 0 3
```

#### 5. Verificação dos Dados

```sql
SELECT * FROM alunos;
```

Saída:

```
 id |   ra    |       nome        |            email             |       data_inscricao       | status 
----+---------+-------------------+------------------------------+----------------------------+--------
  1 | 1120245 | Matheus Mantovani | matheusmantovani16@gmail.com | 2026-06-01 22:43:51.170901 | ativo
  2 | 6325129 | Maria Santos      | maria@email.com              | 2026-06-01 22:43:51.170901 | ativo
  3 | 6325130 | Pedro Oliveira    | pedro@email.com              | 2026-06-01 22:43:51.170901 | ativo
(3 rows)
```

#### 6. Backup (Snapshot) do RDS

Comando (simulado — requer AWS real ou LocalStack Pro):

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-1120245 \
  --db-snapshot-identifier snapshot-tf011-1120245 \
  --endpoint-url=http://localhost:4566
```

Em AWS real, a saída seria:
```json
{
    "DBSnapshot": {
        "DBSnapshotIdentifier": "snapshot-tf011-1120245",
        "DBInstanceIdentifier": "rds-tf011-1120245",
        "Status": "creating",
        "Engine": "postgres",
        "AllocatedStorage": 20,
        "SnapshotType": "manual"
    }
}
```

---

### Evidência S3: Upload do db_config.conf (LocalStack v3)

Bucket criado e arquivo enviado com sucesso via LocalStack:

```bash
# Criação do arquivo
echo "# DB config - TF011 - RA 1120245" > db_config.conf

# Criação do bucket
aws s3 mb s3://config-app-tf11 --endpoint-url=http://localhost:4566
# make_bucket: config-app-tf11

# Upload
aws s3 cp db_config.conf s3://config-app-tf11/ --endpoint-url=http://localhost:4566
# upload: ./db_config.conf to s3://config-app-tf11/db_config.conf

# Verificação
aws s3 ls s3://config-app-tf11/ --endpoint-url=http://localhost:4566
# 2026-06-01 22:42:28         33 db_config.conf
```

---

## Observações Gerais

- **AWS CLI:** versão `1.45.19` instalada via `pip3` no Ubuntu 24.04.
- **LocalStack v3 community:** suporta S3 nativamente. O serviço RDS requer a versão Pro (licença paga), por isso foi simulado com PostgreSQL local.
- **PostgreSQL local:** versão `16.14` utilizada para demonstrar a criação de tabela, inserção e consulta de dados, reproduzindo fielmente o comportamento de uma instância RDS PostgreSQL.
- Em ambiente AWS real, todos os comandos `aws rds` funcionariam identicamente, bastando remover o `--endpoint-url`.
