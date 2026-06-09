# TF011 - Respostas: Armazenamento e Banco de Dados na AWS

**RA:** 6325149  
**Data:** 01/06/2026  
**Disciplina:** Implementação de servidor e nuvem (cloud)  

---

## Questão 1: Armazenamento de Objetos (S3) (Teórica)

### a) Principal caso de uso para S3 em contexto Web e DevOps

**Resposta:**

O S3 é utilizado para armazenar e distribuir **ativos estáticos e backups**:

**Casos de Uso Principais:**
1. **Hospedagem de Websites Estáticos**: HTML, CSS, JavaScript, imagens
2. **Backups e Disaster Recovery**: Backup de bancos de dados, snapshots, arquivos críticos
3. **Data Lakes e Big Data**: Armazenamento de massive datasets para análise
4. **Log Aggregation**: Centralizar logs de aplicações e infraestrutura
5. **CI/CD Artifacts**: Artefatos de build, versões de aplicações, containers
6. **Versionamento de Arquivos**: Histórico e versionamento de documentos
7. **Distribution via CloudFront**: Servir conteúdo com baixa latência globalmente

**Exemplo DevOps:**
```bash
# Backup automático de banco de dados para S3
mysqldump -u root production_db | aws s3 cp - s3://backups/db-$(date +%Y%m%d).sql

# Armazenar artefatos de build
aws s3 cp ./build/ s3://app-artifacts/v1.2.3/
```

---

### b) S3 é global ou regional? Durabilidade ou Disponibilidade?

**Resposta:**

**Escopo: Regional**
- Buckets são criados em uma **região específica** (ex: sa-east-1)
- Dados replicados em múltiplas AZs **dentro** dessa região
- Acesso não é global (CloudFront fornece distribuição global)

**"Onze Noves" (99.999999999%) = Durabilidade**
- **Durabilidade**: Probabilidade de o dado NÃO ser perdido
  - 11 noves = Perder 1 objeto a cada 10 bilhões de objetos
  - AWS reaplica dados automaticamente se um disco falhar
  
- **Disponibilidade**: Probabilidade do serviço estar operacional
  - 99.99% (4 noves) = ~52 minutos downtime/ano
  - S3 pode estar temporariamente indisponível, mas dados não são perdidos

**Distinção:**
| Aspecto | Durabilidade | Disponibilidade |
|---------|--------------|-----------------|
| **Significado** | Dados não são perdidos | Serviço está operacional |
| **Métrica** | 99.999999999% (11 9's) | 99.99% (4 9's) |
| **Falha típica** | Corrupção de disco | Servidor sobrecarregado |

---

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS) (Teórica)

### a) Diferença fundamental entre EBS e EFS

**Resposta:**

| Característica | EBS | EFS |
|---|---|---|
| **Tipo de Armazenamento** | Block Storage (disco virtual) | File Storage (sistema de arquivos) |
| **Conexão** | Anexado a UMA instância EC2 | Montável em MÚLTIPLAS instâncias (via NFS) |
| **Protocolo** | Bloco direto (iSCSI) | NFS (Network File System) |
| **Performance** | Latência < 1ms, IOPS provisionado | Latência ~ 1ms, throughput variável |
| **Escalabilidade** | Tamanho fixo, redimensionável | Cresce/diminui automaticamente |
| **Replicação** | Dentro de UMA AZ (Multi-AZ opcional) | Replicado em 3 AZs automaticamente |
| **Custo** | Baseado em IOPS e throughput provisionado | Baseado em espaço utilizado |
| **Caso de Uso** | SO, aplicações, bancos de dados | Compartilhamento entre múltiplas instâncias |

**Visualização:**
```
EC2 com EBS:          EC2 com EFS:
┌────────────┐        ┌────────────┐
│   EC2      │        │   EC2 #1   │
│   + EBS    │        │   + EFS    │
│ (/dev/xvda)│        │ (/mnt/efs) │
└────────────┘        └────────────┘
                              │
                              └─── NFS ───┬────────────┐
                                         │   EC2 #2   │
                                         │   + EFS    │
                                         └────────────┘
```

---

### b) Qual é mais adequado para S.O. e executável da aplicação?

**Resposta:**

**EBS é o mais adequado.**

**Motivos:**

1. **Performance**: EBS oferece latência <1ms, crítica para acesso ao SO
   - EFS tem latência ~1ms, aceitável mas não ideal para executáveis

2. **Acesso Boot**: EC2 booteia do EBS
   - SO DEVE estar em EBS
   - EFS é montado APÓS o SO estar ativo

3. **Consistência**: EBS oferece garantias ACID para o filesystem
   - Essencial para integridade do SO

4. **Isolamento**: EBS está anexado apenas a UMA instância
   - Elimina contenção de I/O
   - SO necessita performance previsível

**Comparação de Fluxo:**
```
Instância EC2 é iniciada:
1. ✅ EBS /dev/xvda é montado automaticamente (raiz)
2. ✅ Sistema Operacional é carregado
3. ✅ Aplicação é executada
4. ✅ EFS é montado via NFS (dados compartilhados)
```

**Quando usar EFS:**
- Dados compartilhados entre múltiplas instâncias
- Content Management Systems
- Machine Learning datasets
- Media processing pipelines

---

## Questão 3: Banco de Dados Gerenciado (RDS) (Teórica)

### a) Duas responsabilidades que AWS assume com RDS

**Resposta:**

1. **Patches e Atualizações de Segurança**
   - AWS aplica patches do banco de dados automaticamente (ou durante janela de manutenção)
   - Mantém versão do engine atualizada
   - DevOps NÃO precisa logar em servidor Linux para atualizar MySQL/PostgreSQL
   - **Benefício**: Reduz riscos de segurança, sem downtime planejado

2. **Backups Automáticos e Ponto-em-Tempo (PITR)**
   - RDS faz backups diários automáticos
   - Mantém 7 dias de retenção (configurável até 35 dias)
   - Permite restore para ANY ponto-em-tempo (PITR)
   - Snapshots são armazenados em S3 automaticamente
   - **Benefício**: Recuperação de dados sem intervenção manual

**Outras responsabilidades (bônus):**
- Replicação Multi-AZ (standby automático)
- Monitoramento e CloudWatch metrics
- Escalabilidade vertical (upgrade de instance type)
- HA e Failover automático
- Encriptação de dados em repouso

---

### b) Principal desvantagem de RDS vs. Banco de Dados em EC2

**Resposta:**

**Desvantagem Principal: Falta de Controle Total**

1. **Limitações de Customização**
   - Não pode instalar módulos customizados ou extensions do SO
   - Não pode acessar filesystem subjacente
   - Alterações de configuração são limitadas às opções da AWS
   - **Exemplo**: PostgreSQL em EC2 permite qualquer extension; RDS só permite extensões aprovadas

2. **Restrições de Hardware**
   - RDS oferece tipos de instância pré-definidos
   - Não pode otimizar SO/kernel para workload específico
   - Limite de IOPS/throughput por tipo de instância

3. **Performance Previsível vs. Peak Performance**
   - EC2: Pode dedicar 100% de recursos para picos
   - RDS: Compartilha recursos com outros clientes AWS

**Comparação:**

| Aspecto | RDS | EC2 + BD Manual |
|--------|-----|-----------------|
| **Patches** | Automático ✅ | Manual ❌ |
| **Backups** | Automático ✅ | Manual ❌ |
| **Controle** | Limitado ❌ | Total ✅ |
| **Performance** | Consistente ✅ | Variável ❌ |
| **Custo Operacional** | Baixo ✅ | Alto ❌ |
| **Expertise Necessária** | AWS DBA | Linux DBA ++ BD DBA |

**Quando Usar EC2 + Banco Manual:**
- Customizações muito específicas (ex: banking, compliance)
- Performance extrema em data warehouses
- Múltiplas instâncias de BD no mesmo servidor

---

## Questão 4: Alta Disponibilidade no RDS (Teórica)

### a) O que acontece quando você habilita Multi-AZ

**Resposta:**

**Arquitetura Multi-AZ:**
```
Primary Database (AZ-1)          Standby Database (AZ-2)
┌──────────────────────┐        ┌──────────────────────┐
│  RDS Instance        │────┐   │  RDS Instance        │
│  (primary-az1)       │    │   │  (standby-az2)       │
│  - Lê e escreve      │    │   │  - Apenas espera     │
│  - pg_primary        │    │   │  - pg_standby        │
└──────────────────────┘    │   └──────────────────────┘
         │                  │            │
         │ Writes           │ Replica    │
         └──────────────────┴────────────┘
                    Sync
```

**O que AWS faz automaticamente:**

1. **Criação de Standby**
   - Cria uma instância RDS idêntica em outra AZ
   - Nome: `<db-name>-az2`

2. **Replicação Síncrona**
   - Todas as escritas são replicadas para Standby
   - Confirmação de escrita APENAS após confirmação do Standby
   - Garante RPO (Recovery Point Objective) = 0 (zero perda de dados)

3. **Monitoramento Contínuo**
   - AWS monitora a saúde da instância primária
   - Detecta falhas automaticamente

4. **Failover Automático** (em caso de falha)
   - Se primary falha:
     - AWS promove o Standby a Primary
     - DNS CNAME é atualizado para apontar para novo primary
     - Aplicações reconectam automaticamente
   - **RTO (Recovery Time Objective)**: 1-2 minutos

---

### b) Diferença entre Standby Multi-AZ e Read Replica

**Resposta:**

| Aspecto | Standby (Multi-AZ) | Read Replica |
|--------|-------------------|--------------|
| **Propósito** | Alta Disponibilidade | Escalabilidade de Leitura |
| **Acessível?** | NÃO (invisível) | SIM (endpoint próprio) |
| **Replicação** | Síncrona | Assíncrona |
| **Delay** | <1ms | Segundos a minutos |
| **Localização** | Outra AZ (mesma região) | Outra AZ ou outra região |
| **Uso em Failover** | SIM (automático) | NÃO (necessita manual) |
| **Casos de Uso** | Proteção de falhas | Distribuir leituras |
| **Custo** | 2x da instância | 1x da instância (por replica) |

**Fluxo de Operação:**

```
Read Replica (Distribuir Leituras):
┌──────────────────┐
│  Application     │
└──────────────────┘
    │        │
    ├─► Write to Primary (primary-endpoint)
    │
    └─► Read from Replica (replica-endpoint)

Multi-AZ Standby (HA):
┌──────────────────┐
│  Application     │
└──────────────────┘
    │
    ├─► Write/Read to Primary (rds-endpoint)
    │
    └─ [Failover Automático - Transparente]
         └─► Primary falha?
              Standby assume
              DNS atualiza
              App reconecta automaticamente
```

**Quando Usar:**
- **Multi-AZ**: Produção com exigência de alta disponibilidade (99.99%+)
- **Read Replica**: Crescimento de leituras (relatórios, analytics)
- **Ambos**: Ambiente crítico (HA + Performance)

---

## Questão 5: Tarefa Prática Integrada - Upload S3 (Simulação)

### Descrição do Fluxo

Descreva as **três etapas** para fazer upload de `db_config.conf` do WSL para S3:

---

### 1. Criação do Arquivo (Linux)

**Comando:**
```bash
touch db_config.conf
echo "DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=secure123
DB_NAME=production" > db_config.conf
```

**Verificação:**
```bash
cat db_config.conf
```

**Saída esperada:**
```
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=secure123
DB_NAME=production
```

**Descrição**: Comando `touch` cria arquivo vazio, `echo` com redirecionamento `>` escreve conteúdo. O arquivo é criado no diretório atual do WSL/Linux.

---

### 2. Upload para S3 (AWS CLI)

**Comando:**
```bash
aws s3 cp db_config.conf s3://config-app-tf11/db_config.conf
```

**Ou com diretório:**
```bash
aws s3 cp db_config.conf s3://config-app-tf11/configs/db_config.conf
```

**Saída esperada:**
```
upload: ./db_config.conf to s3://config-app-tf11/db_config.conf
```

**Componentes do comando:**
- `aws s3 cp`: Comando de cópia S3 (AWS CLI)
- `db_config.conf`: Arquivo local (origem)
- `s3://config-app-tf11/db_config.conf`: Bucket S3 e chave (destino)
- Pode usar `s3 sync` para múltiplos arquivos
- Pode usar `--sse AES256` para encriptação

---

### 3. Verificação (AWS CLI)

**Comando:**
```bash
aws s3 ls s3://config-app-tf11/
```

**Ou com detalhes:**
```bash
aws s3api list-objects-v2 --bucket config-app-tf11 --prefix configs/
```

**Saída esperada:**
```
                           PRE configs/
2024-06-01 14:30:45      1024 db_config.conf
```

**Ou formato JSON:**
```json
{
    "Contents": [
        {
            "Key": "configs/db_config.conf",
            "LastModified": "2024-06-01T14:30:45+00:00",
            "Size": 1024,
            "StorageClass": "STANDARD"
        }
    ]
}
```

**Descrição**: Comando `aws s3 ls` lista objetos no bucket. `aws s3api list-objects-v2` oferece mais controle e informações detalhadas em JSON.

---

## Questão 6: Evidências Práticas de RDS

### Parte 1: Evidências de Configuração

Coloque prints nesta seção após executar os comandos:

**1. Configuração de Credenciais AWS**
- Comando: `aws configure list`
- Print esperado: Mostra access_key, secret_key, region (oculte chaves sensíveis)
- Local: `/images/print01-configure-list.png`

**2. Teste de Conectividade com RDS**
- Comando: `aws rds describe-db-instances`
- Print esperado: Lisagem de instâncias RDS existentes
- Local: `/images/print02-rds-describe.png`

**3. Instalação do Cliente PostgreSQL**
- Comando: `psql --version`
- Print esperado: Versão do PostgreSQL client
- Local: `/images/print03-psql-version.png`

**4. Variável de Ambiente (Endpoint RDS)**
- Comando: `echo $RDS_ENDPOINT`
- Print esperado: URL do endpoint (ex: `rds-tf011-6325149.c3mw8u2sgtjh.sa-east-1.rds.amazonaws.com`)
- Local: `/images/print04-endpoint.png`

---

### Parte 2: Exercício de Criação de RDS com Tabela de Alunos

**Evidências Capturadas e Executadas:**

#### 1. Criação da Instância RDS (print05-create-db-output.txt)
- **Comando executado**: `aws rds create-db-instance --db-instance-identifier rds-tf011-6325149 --db-instance-class db.t3.micro --engine postgres --master-username postgres --master-user-password UniFAAT2026_123 --allocated-storage 20 --storage-type gp3 --publicly-accessible --region sa-east-1`
- **Status retornado**: `"DBInstanceStatus": "creating"`
- **Especificações**:
  - DB Instance ID: `rds-tf011-6325149`
  - Class: `db.t3.micro` (elegível para free tier)
  - Engine: PostgreSQL 18.3
  - Storage: 20GB gp3 com 3000 IOPS, 125 MB/s throughput
  - VPC: `vpc-04d653639c7a1fc45`
  - Security Group: `sg-015bdc1d4a553006a`
  - Multi-AZ: false
  - ARN: `arn:aws:rds:sa-east-1:577638395851:db:rds-tf011-6325149`
- **Descrição**: Instância PostgreSQL foi criada com sucesso. O comando retornou a configuração completa em JSON. A instância começou no estado "creating" e levou aproximadamente 5 minutos para ficar "available".

#### 2. Status da Instância - Disponível (print06-db-status.txt)
- **Comando executado**: `aws rds describe-db-instances --db-instance-identifier rds-tf011-6325149 --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,Endpoint.Port,MasterUsername]' --output text`
- **Saída**:
  ```
  rds-tf011-6325149       available       rds-tf011-6325149.cfcaieeg4kkz.sa-east-1.rds.amazonaws.com      5432    postgres
  ```
- **Descrição**: Instância agora está em estado `available` após ~5 minutos. O endpoint foi gerado: `rds-tf011-6325149.cfcaieeg4kkz.sa-east-1.rds.amazonaws.com` na porta 5432. Pronta para conexões.

#### 3. Verificação de Security Group e Configuração de Acesso (print08-security-group.txt e print09-sg-rule-added.txt)
- **Problema identificado**: O security group default tinha apenas regras de replicação interna (IpPermissions com UserIdGroupPairs)
- **Solução aplicada**: Adicionada regra de entrada para PostgreSQL
- **Comando executado**: `aws ec2 authorize-security-group-ingress --group-id sg-015bdc1d4a553006a --protocol tcp --port 5432 --cidr 0.0.0.0/0 --region sa-east-1`
- **Regra adicionada**:
  ```
  SecurityGroupRuleId: sgr-03f03ca96c0c88be0
  Protocol: tcp
  Port: 5432
  CIDR: 0.0.0.0/0 (acesso global)
  ```
- **Descrição**: Configuração de acesso ao banco de dados foi corrigida para permitir conexões externas.

#### 4. Teste de Conectividade (print10-connection-test.txt)
- **Comando executado**: `psql -h rds-tf011-6325149.cfcaieeg4kkz.sa-east-1.rds.amazonaws.com -U postgres -d postgres -c "SELECT version();"`
- **Saída**:
  ```
  PostgreSQL 18.3 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
  ```
- **Descrição**: Conexão bem-sucedida ao banco de dados RDS via psql. Confirma que a instância está acessível e funcional.

#### 5. Criação de Tabela e Inserção de Dados (print11-create-table-insert.txt)
- **Comandos SQL executados**:
  ```sql
  CREATE TABLE IF NOT EXISTS alunos (
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
  ('6325130', 'Pedro Oliveira', 'pedro@email.com');

  SELECT * FROM alunos;
  ```
- **Saída**:
  ```
  CREATE TABLE
  INSERT 0 3
   id |   ra    |      nome      |      email      |      data_inscricao       | status 
  ----+---------+----------------+-----------------+---------------------------+--------
    1 | 6325128 | João Silva     | joao@email.com  | 2026-06-02 00:58:28.41504 | ativo
    2 | 6325129 | Maria Santos   | maria@email.com | 2026-06-02 00:58:28.41504 | ativo
    3 | 6325130 | Pedro Oliveira | pedro@email.com | 2026-06-02 00:58:28.41504 | ativo
  (3 rows)
  ```
- **Descrição**: 
  - Tabela `alunos` foi criada com sucesso com schema apropriado
  - 3 registros de alunos foram inseridos
  - Validação com SELECT confirmou que os dados foram persistidos corretamente
  - Timestamps foram gerados automaticamente

#### 6. Criação de Snapshot/Backup (print12-snapshot-create.txt)
- **Comando executado**: `aws rds create-db-snapshot --db-instance-identifier rds-tf011-6325149 --db-snapshot-identifier snapshot-tf011-6325149 --region sa-east-1`
- **Saída**:
  ```json
  {
      "DBSnapshot": {
          "DBSnapshotIdentifier": "snapshot-tf011-6325149",
          "DBInstanceIdentifier": "rds-tf011-6325149",
          "Engine": "postgres",
          "Status": "creating",
          "PercentProgress": 0,
          ...
          "DBSnapshotArn": "arn:aws:rds:sa-east-1:577638395851:snapshot:snapshot-tf011-6325149"
      }
  }
  ```
- **Status final**: Snapshot transicionou de "creating" para "available" em ~60 segundos
- **Descrição**: Backup de snapshot foi criado com sucesso. Captura o estado do banco de dados com a tabela `alunos` e os 3 registros de dados. Pode ser usado para recuperação ou clone do banco de dados.

---

## Observações Sobre as Ferramentas e Comandos Usados

### AWS CLI
- **Comando principal**: `aws s3 cp`, `aws s3api`, `aws rds create-db-instance`
- **Região**: sa-east-1 (São Paulo)
- **Formato de saída**: JSON (configurado no `aws configure`)

### DBeaver
- **Ferramenta**: Client SQL multiplataforma
- **Vantagem**: Interface visual para gerenciar banco de dados
- **Uso**: Conexão, criação de tabelas, inserção de dados, backup

### PostgreSQL Client (psql)
- **Instalação**: `sudo apt install postgresql-client -y`
- **Uso**: Acesso via terminal ao RDS
- **Vantagens**: Leve, poderosa para scripts e automation

### Fluxo de Trabalho

```
1. Configurar credenciais AWS
   ↓
2. Criar instância RDS via CLI
   ↓
3. Aguardar status = available (~10 min)
   ↓
4. Conectar via DBeaver/psql
   ↓
5. Criar tabela de alunos
   ↓
6. Inserir dados de teste
   ↓
7. Verificar dados com SELECT
   ↓
8. Criar snapshot para backup
   ↓
9. Documentar com prints
```

---

## Resumo de Aprendizados

✅ **S3** = Object Storage para backups, websites estáticos, data lakes  
✅ **EBS** = Block Storage para SO e aplicações (performance crítica)  
✅ **EFS** = File Storage compartilhado entre múltiplas EC2  
✅ **RDS** = Banco de dados gerenciado (backups automáticos, patches)  
✅ **Multi-AZ** = Alta Disponibilidade com failover automático  
✅ **Read Replica** = Escalabilidade de leitura (assíncrono)  
✅ **AWS CLI** = Interface linha de comando para automatizar tudo  

---

**Data de Conclusão:** 01/06/2026  
**Status:** ✅ Questões Teóricas (Q1-Q5) Completas | ⏳ Aguardando Prints (Q6)

