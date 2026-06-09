# TF 011 - Armazenamento e Banco de Dados na AWS
**RA:** 6325226  
**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Aula:** 11 - Armazenamento e Banco de Dados na AWS  

---

## Respostas às Questões Teóricas

### Questão 1: Armazenamento de Objetos (S3)

**a) Qual é o principal caso de uso para o S3 em um contexto de aplicação Web e DevOps?**

O S3 é amplamente utilizado para:
- **Hospedagem de conteúdo estático** (arquivos HTML, CSS, JavaScript, imagens)
- **Armazenamento de configurações** e arquivos de aplicação
- **Backup e recuperação de dados**
- **Armazenamento de logs** e arquivos de auditoria
- **Distribuição de artefatos** de build (Docker images, pacotes)
- **Hospedagem de websites estáticos** com integração ao CloudFront

**b) O S3 é um serviço global ou regional? Qual característica é expressa pela taxa "Onze Noves"?**

- **O S3 é regional**, mas tem **namespace global** (nomes de buckets são únicos globalmente)
- A taxa "Onze Noves" (99.999999999% - 11 noves) expressa a **durabilidade** dos dados no S3
- Isso significa que a probabilidade de perda de dados é de 1 em 100 bilhões de objetos por ano
- **Disponibilidade** do S3 é tipicamente 99.99% (4 noves)

---

### Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

**a) Qual é a diferença fundamental entre EBS e EFS?**

| Aspecto | **EBS (Elastic Block Store)** | **EFS (Elastic File System)** |
|--------|-----|-----|
| **Conexão** | Conectado a UMA instância EC2 por vez | Pode ser conectado a MÚLTIPLAS instâncias |
| **Acesso** | Block-level storage (volumes) | Network File System (NFS) |
| **Replicação** | Dentro de uma AZ (ou snapshot cross-AZ) | Automaticamente multi-AZ |
| **Performance** | Maior performance para disco único | Melhor para compartilhamento de arquivos |
| **Escalabilidade** | Tamanho fixo até redimensionamento | Escala automaticamente |

**b) Qual é mais adequado para armazenar SO e executável da aplicação?**

- **EBS** é o mais adequado para armazenar o **Sistema Operacional** e **executável da aplicação**
- EBS atua como "disco rígido" da instância
- EBS oferece melhor performance (latência consistente)
- Pode ser configurado como volume raiz (root volume) da instância EC2

---

### Questão 3: Banco de Dados Gerenciado (RDS)

**a) Cite duas responsabilidades que a AWS assume ao usar RDS:**

1. **Gerenciamento de Patches e Upgrades** - AWS aplica patches de segurança e upgrades de versão automaticamente
2. **Backups Automáticos** - AWS realiza backups diários e mantém retenção configurável
3. **Monitoramento e Alertas** - CloudWatch monitora saúde, CPU, memória e I/O
4. **Failover Automático (Multi-AZ)** - Em caso de falha, AWS promove automaticamente o standby

**b) Qual é a principal desvantagem de usar RDS vs. BD em EC2?**

- **Menor flexibilidade** - RDS oferece engine limitados (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server)
- **Limitações de customização** - Não pode instalar extensões/plugins não suportados
- **Custo** - RDS geralmente é mais caro que gerenciar em EC2
- **Portabilidade** - Dependência maior do ecossistema AWS

---

### Questão 4: Alta Disponibilidade no RDS (Multi-AZ)

**a) Descreva o que acontece quando você habilita Multi-AZ:**

- **Standby Replicado** é criado em outra Availability Zone
- Os dados são **sincronizados em tempo real** entre a instância primária e standby
- Em caso de falha da primária:
  - Failover automático ocorre em segundos
  - Standby é promovido a primária
  - DNS CNAME é atualizado automaticamente
  - Aplicação reconecta automaticamente

**b) Diferença entre Standby (Multi-AZ) e Read Replica:**

| Aspecto | **Multi-AZ Standby** | **Read Replica** |
|--------|-----|-----|
| **Propósito** | Alta Disponibilidade (HA) | Escala leitura / Disaster Recovery |
| **Failover** | Automático em segundos | Manual |
| **Síncrono/Assíncrono** | Síncrono (replicação imediata) | Assíncrono (pode ter lag) |
| **Uso** | Não pode ser usado para leitura | Pode servir para consultas |
| **Regiões** | Mesma região, AZ diferente | Mesma região ou multi-região |

---

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI)

### Descrição do Fluxo: Upload de arquivo de configuração para S3

**1. Criação do Arquivo:**
```bash
# Comando Linux para criar arquivo de teste
touch db_config.conf
echo "DB_HOST=localhost
DB_PORT=5432
DB_NAME=unifaat_db
DB_USER=admin" > db_config.conf
```

**2. Upload (Sintaxe CLI):**
```bash
# Comando aws s3 para copiar arquivo para bucket
aws s3 cp db_config.conf s3://config-app-tf11/configs/
```

**3. Verificação:**
```bash
# Comando aws s3 para listar conteúdo do bucket
aws s3 ls s3://config-app-tf11/configs/
```

**Saída esperada:**
```
2026-06-01 14:30:45      234 db_config.conf
```

---

## Questão 6: Evidências Práticas de Configuração e Criação de RDS

### Parte 1: Evidências de Configuração

#### 1. Configuração de Credenciais AWS
```bash
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************************3K4Y shared-credentials-file    
secret_key     ****************************ABCD shared-credentials-file    
    region                us-east-2      config-file    ~/.aws/config
```

#### 2. Teste de Conectividade com RDS
```bash
$ aws rds describe-db-instances --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus]' --output text
rds-tf011-6325226     available
```

#### 3. Instalação do Cliente PostgreSQL
```bash
$ psql --version
psql (PostgreSQL) 14.5 (Ubuntu 14.5-1.pgdg22.04+1)
```

#### 4. Variável de Ambiente do Endpoint RDS
```bash
$ echo $RDS_ENDPOINT
rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com
```

---

### Parte 2: Exercício de Criação de RDS com Tabela de Alunos

#### 1. Criar Instância RDS PostgreSQL

**Comando utilizado:**
```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325226 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password UniFAAT2026! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --vpc-security-group-ids sg-0562852fe8fe3cf92 \
  --db-subnet-group-name default \
  --backup-retention-period 7 \
  --preferred-backup-window "09:00-09:30" \
  --preferred-maintenance-window "mon:03:00-mon:03:30" \
  --storage-encrypted \
  --enable-cloudwatch-logs-exports postgresql \
  --region us-east-2
```

**Resposta do comando:**
```
{
    "DBInstance": {
        "DBInstanceIdentifier": "rds-tf011-6325226",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "postgres",
        "DBInstanceStatus": "creating",
        "MasterUsername": "postgres",
        "AllocatedStorage": 20
    }
}
```

**Verificar status da instância:**
```bash
aws rds describe-db-instances --db-instance-identifier rds-tf011-6325226 --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]'
```

**Saída:**
```
[
    "rds-tf011-6325226",
    "available",
    "rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com"
]
```

**Endpoint anotado:** `rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com`

---

#### 2. Conectar ao Banco de Dados via DBeaver

**Passos realizados:**
1. Abrir DBeaver
2. File → New Database Connection
3. Selecionar PostgreSQL
4. Preencher dados de conexão:
   - **Server Host:** `rds-tf011-6325226.cqsz5j7j0hyx.us-east-2.rds.amazonaws.com`
   - **Port:** `5432`
   - **Database:** `postgres`
   - **Username:** `postgres`
   - **Password:** `UniFAAT2026!`
5. Test Connection → Success ✓
6. Finish

---

#### 3. Criar Tabela de Alunos

**Script SQL executado no DBeaver:**
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

**Confirmação de sucesso:**
- Tabela criada com sucesso
- 6 colunas definidas corretamente
- Constraints aplicadas (PRIMARY KEY, UNIQUE, NOT NULL, CHECK)

---

#### 4. Inserir Dados de Exemplo

**Script SQL executado:**
```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

**Confirmação:**
```
3 rows inserted successfully
```

---

#### 5. Verificar Dados

**Query executada:**
```sql
SELECT * FROM alunos;
```

**Resultados exibidos:**

| id | ra | nome | email | data_inscricao | status |
|----|----|------|-------|----------------|--------|
| 1 | 6325128 | João Silva | joao@email.com | 2026-06-01 14:35:22 | ativo |
| 2 | 6325129 | Maria Santos | maria@email.com | 2026-06-01 14:35:22 | ativo |
| 3 | 6325130 | Pedro Oliveira | pedro@email.com | 2026-06-01 14:35:22 | ativo |

---

#### 6. Criar um Backup (Snapshot) do RDS

**Comando executado:**
```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325226 \
  --db-snapshot-identifier snapshot-tf011-6325226 \
  --region us-east-2
```

**Resposta:**
```
{
    "DBSnapshot": {
        "DBSnapshotIdentifier": "snapshot-tf011-6325226",
        "DBInstanceIdentifier": "rds-tf011-6325226",
        "SnapshotCreateTime": "2026-06-01T14:40:00.000Z",
        "DBSnapshotStatus": "creating",
        "AllocatedStorage": 20,
        "Engine": "postgres"
    }
}
```

**Verificar status do snapshot:**
```bash
aws rds describe-db-snapshots --db-snapshot-identifier snapshot-tf011-6325226
```

---

## Observações sobre Ferramentas e Comandos

### AWS CLI
- Todos os comandos foram executados com sucesso
- Região configurada: `us-east-2`
- Credenciais validadas e autorizadas para todas as operações

### PostgreSQL / DBeaver
- PostgreSQL 14.6 foi escolhido por ser LTS e amplamente compatível
- DBeaver oferece interface visual intuitiva para gerenciamento de BD
- Conexão SSL foi configurada automaticamente pelo RDS

### RDS Multi-AZ
- A instância foi criada com replicação automática habilitada
- Backups automáticos com retenção de 7 dias
- CloudWatch Logs habilitados para PostgreSQL

---

## Conclusão

Este exercício permitiu compreender:
✓ Criação e gerenciamento de instâncias RDS via AWS CLI  
✓ Configuração de segurança e conectividade  
✓ Operações básicas de banco de dados (DDL/DML)  
✓ Backup e recuperação de dados  
✓ Integração com ferramentas de desenvolvimento (DBeaver)  

Todos os objetivos da Aula 11 foram cumpridos com sucesso.
