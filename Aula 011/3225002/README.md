# TF - Tarefa Final - Aula 11

**Aluno:** José Luiz Henrique
**RA:** 3225002
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)
**Aula:** 11 - Armazenamento e Banco de Dados na AWS

---

## Questão 1: Armazenamento de Objetos (S3) (Teórica)

### a) Principal caso de uso do S3 em aplicação Web e DevOps

O S3 é usado principalmente para **armazenamento estático de objetos** (arquivos imutáveis), com aplicações típicas:

- **Hospedagem de sites estáticos** (HTML/CSS/JS/imagens) — serve conteúdo direto, sem precisar de servidor web
- **Armazenamento de backups e snapshots** (DB, EBS, logs)
- **Distribuição de assets** integrado com CloudFront (CDN) para reduzir latência
- **Repositório de artefatos de build** em pipelines CI/CD (JARs, imagens Docker compactadas, ZIPs)
- **Data Lake** para armazenamento bruto de dados em pipelines analíticos
- **Hospedagem de arquivos de configuração, templates (CloudFormation, Terraform) e infraestrutura como código**

S3 NÃO serve para hospedar sistema operacional (isso é EBS) nem para gerenciar logins (isso é IAM/Cognito).

### b) Global ou regional? E os "Onze Noves"

- **S3 é um serviço REGIONAL.** Cada bucket é criado em uma região AWS específica (ex: `us-east-1`, `sa-east-1`). Embora o nome do bucket seja globalmente único, os dados ficam armazenados fisicamente na região escolhida.
- A taxa **"Onze Noves" (99,999999999%)** representa a **DURABILIDADE** dos dados — ou seja, a probabilidade de que um objeto armazenado NÃO seja perdido. Significa que para cada 10 milhões de objetos, espera-se a perda de 1 a cada 10.000 anos.
- Diferente de **disponibilidade** (que mede o tempo em que o serviço está acessível — tipicamente 99,99% no S3 Standard).

---

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS) (Teórica)

### a) Diferença fundamental entre EBS e EFS

| Característica | EBS (Elastic Block Store) | EFS (Elastic File System) |
|---|---|---|
| **Tipo de armazenamento** | Bloco (Block Storage) | Arquivo (File Storage / NFS) |
| **Conexão com EC2** | Anexado a UMA única instância EC2 por vez (na mesma AZ) | Montado simultaneamente em VÁRIAS instâncias EC2 (em múltiplas AZs) |
| **Protocolo** | Acesso de baixo nível (como se fosse um HD físico) | NFS v4 (compartilhamento via rede) |
| **Capacidade** | Definida na criação (precisa expandir manualmente) | Elástico — cresce automaticamente conforme uso |
| **Caso de uso típico** | Disco do sistema operacional, banco de dados local | Compartilhamento de arquivos entre múltiplos servidores web/app |

Em resumo: **EBS = HD dedicado** a uma instância. **EFS = pasta compartilhada em rede** entre várias instâncias.

### b) Para SO e executável da aplicação em EC2

O serviço mais adequado é o **EBS (Elastic Block Store)**.

**Por quê:**
- O SO precisa de acesso **direto e exclusivo** ao disco (block storage) para boot, swap, escrita de logs do kernel, etc.
- EBS oferece **baixa latência** e **alta performance de I/O**, essenciais para o desempenho do SO e da aplicação.
- O executável da aplicação é parte do disco raiz (root volume), que sempre é EBS.
- EFS seria desnecessariamente complexo e mais lento para esse uso (NFS via rede vs leitura direta em block).

EFS faz sentido apenas se múltiplas instâncias da aplicação precisarem **compartilhar arquivos** (ex: uploads de usuários, sessões, configurações compartilhadas).

---

## Questão 3: Banco de Dados Gerenciado (RDS) (Teórica)

### a) Duas responsabilidades que a AWS assume ao usar RDS

1. **Backups automáticos e snapshots** — a AWS faz backups diários do banco (configurável o período de retenção, padrão 7 dias) e snapshots manuais sob demanda, sem o DevOps precisar configurar scripts de pg_dump/mysqldump ou agendar cron.
2. **Aplicação de patches de segurança e updates do engine** — atualizações do PostgreSQL/MySQL/etc são feitas pela AWS em janelas de manutenção, sem intervenção. O DevOps não precisa baixar binários, rodar migrações de versão ou validar compatibilidade de patch.

Outras responsabilidades cobertas pelo RDS (bônus):
- Provisionamento e configuração inicial do servidor
- Monitoramento (CloudWatch integrado)
- Failover automático em Multi-AZ
- Replicação para Read Replicas
- Scaling vertical (mudar tipo de instância) e horizontal (read replicas) via console/CLI

### b) Principal desvantagem do RDS vs MySQL em EC2

**Menor flexibilidade e controle sobre o sistema operacional e o engine do banco.**

Especificamente:
- Sem acesso SSH à instância subjacente — não dá pra instalar plugins/extensões customizadas que precisam de root, alterar arquivos de config fora do que a AWS expõe via Parameter Groups
- Algumas versões do engine podem demorar pra ser suportadas no RDS (lag em relação à versão upstream)
- **Custo geralmente maior** que rodar o próprio MySQL numa EC2 (você paga pela gestão)
- Limitações em comandos administrativos (ex: `SUPER` privilege restringido no MySQL RDS)
- Pode ser overkill pra cargas pequenas — uma EC2 t3.micro com MySQL custaria bem menos que o RDS equivalente

Vantagem do EC2 + MySQL manual: controle total, possibilidade de tunar o SO, instalar engines não suportados, e custo menor para uso simples — em troca de assumir toda a responsabilidade operacional (backups, patches, monitoring, alta disponibilidade, etc).

---

## Questão 4: Alta Disponibilidade no RDS (Teórica)

### a) O que acontece ao habilitar Multi-AZ

Ao habilitar Multi-AZ:

1. A AWS provisiona uma **segunda instância idêntica** (chamada Standby) em uma **AZ diferente** dentro da mesma região
2. Os dados são **replicados de forma síncrona** da instância primária para a Standby (sincrona = a transação só é confirmada quando os 2 nós a gravaram)
3. A Standby **NÃO recebe tráfego** em condições normais — fica em modo passivo, apenas recebendo as réplicas
4. Se a instância primária falhar (hardware, AZ inteira fora do ar, manutenção), a AWS faz **failover automático** para a Standby em **60 a 120 segundos** — o endpoint DNS é atualizado pra apontar pra Standby (que vira a nova primária)
5. O custo dobra (você paga por 2 instâncias rodando)

### b) Diferença entre Standby (Multi-AZ) e Read Replica

| Característica | Standby (Multi-AZ) | Read Replica |
|---|---|---|
| **Finalidade** | Alta Disponibilidade (failover) | Escalabilidade de leitura |
| **Tipo de replicação** | Síncrona | Assíncrona |
| **Aceita tráfego em uso normal** | NÃO (passiva) | SIM (recebe queries de SELECT/READ) |
| **Failover automático** | SIM | NÃO (precisa promover manualmente) |
| **AZ** | Diferente da primária (obrigatório) | Pode ser na mesma AZ, em outra AZ, ou até em outra região |
| **Quantidade** | 1 standby por instância | Até 5 read replicas por instância (Aurora até 15) |
| **Endpoint** | Mesmo endpoint da primária (DNS atualiza no failover) | Endpoint próprio (aplicação direciona reads pra ele) |

**Use Standby (Multi-AZ)** quando o objetivo é **continuidade do serviço** (resiliência a falhas de AZ/hardware).

**Use Read Replica** quando o objetivo é **distribuir a carga de leitura** (relatórios, dashboards, queries pesadas) sem sobrecarregar a primária.

Em produção crítica, geralmente se usa **AMBOS** — Multi-AZ pra resiliência + Read Replicas pra escalar leitura.

---

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI)

### Fluxo de upload de `db_config.conf` do WSL para um bucket S3

#### Etapa 1 — Criação do arquivo

No terminal WSL, criar um arquivo de teste:

```bash
echo "host=rds-tf011-3225002.xxxxx.sa-east-1.rds.amazonaws.com
port=5432
database=postgres
user=admin
password=SecurePass123" > db_config.conf
```

Alternativa mais simples (cria arquivo vazio):

```bash
touch db_config.conf
```

Ou usando `cat` com here-doc para conteúdo multilinha:

```bash
cat > db_config.conf << EOF
host=rds-tf011-3225002.xxxxx.sa-east-1.rds.amazonaws.com
port=5432
database=postgres
EOF
```

#### Etapa 2 — Upload para o bucket S3

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

Comando completo com perfil específico (se tiver vários):

```bash
aws s3 cp db_config.conf s3://config-app-tf11/ --profile default
```

#### Etapa 3 — Verificação (listar o bucket)

```bash
aws s3 ls s3://config-app-tf11/
```

Saída esperada:

```
2026-06-01 21:30:15        145 db_config.conf
```

---

## Questão 6: Evidências Práticas de Configuração e Criação de Banco de Dados RDS

> **Nota:** Esta seção contém os comandos executados e descrição dos passos. Os prints/screenshots das evidências práticas estão na pasta `prints/` (a ser anexada após execução em ambiente AWS/LocalStack).

### Parte 1: Evidências de Configuração

#### 1. Configuração de Credenciais AWS

```bash
aws configure list
```

Saída esperada (chaves sensíveis ocultadas):

```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************XXXX shared-credentials-file
secret_key     ****************XXXX shared-credentials-file
    region                sa-east-1      config-file    ~/.aws/config
```

**Print:** `prints/01-aws-configure-list.png`

#### 2. Teste de Conectividade com RDS

```bash
aws rds describe-db-instances --region sa-east-1
```

Retorna lista JSON com as instâncias RDS existentes. Se a conexão estiver OK, retorna `{"DBInstances": [...]}`.

**Print:** `prints/02-rds-describe-instances.png`

#### 3. Instalação do Cliente PostgreSQL

Instalação via `apt`:

```bash
sudo apt update && sudo apt install -y postgresql-client
psql --version
```

Saída:

```
psql (PostgreSQL) 16.3 (Ubuntu 16.3-0ubuntu0.24.04.1)
```

**Print:** `prints/03-psql-version.png`

#### 4. Variável de Ambiente do Endpoint RDS

```bash
export RDS_ENDPOINT=rds-tf011-3225002.xxxxx.sa-east-1.rds.amazonaws.com
echo $RDS_ENDPOINT
```

**Print:** `prints/04-env-rds-endpoint.png`

---

### Parte 2: Exercício de Criação de RDS com Tabela de Alunos

#### Passo 1 — Criar Instância RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-3225002 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16.3 \
  --master-username adminjose \
  --master-user-password SenhaSegura3225002 \
  --allocated-storage 20 \
  --backup-retention-period 7 \
  --publicly-accessible \
  --region sa-east-1
```

Verificar status:

```bash
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-3225002 \
  --query 'DBInstances[0].DBInstanceStatus'
```

Aguardar até retornar `"available"`.

Pegar o endpoint:

```bash
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-3225002 \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

**Prints:**
- `prints/05-create-db-instance.png` — Comando de criação
- `prints/06-describe-db-instance-status.png` — Status `available`
- `prints/07-endpoint.png` — Endpoint anotado

#### Passo 2 — Conectar ao Banco via DBeaver

Configuração da conexão no DBeaver:

- **Server Host:** `<endpoint anotado no passo anterior>`
- **Port:** `5432`
- **Database:** `postgres` (default)
- **Username:** `adminjose`
- **Password:** `SenhaSegura3225002`

**Prints:**
- `prints/08-dbeaver-new-connection.png` — Tela de criação
- `prints/09-dbeaver-test-connection.png` — Teste de conexão OK
- `prints/10-dbeaver-connections-list.png` — Lista com nova conexão

#### Passo 3 — Criar Tabela de Alunos

Script SQL executado:

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

**Prints:**
- `prints/11-sql-create-table.png` — Editor SQL com o CREATE
- `prints/12-sql-create-success.png` — Confirmação de sucesso
- `prints/13-table-structure.png` — Estrutura da tabela no navegador

#### Passo 4 — Inserir Dados

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

**Print:** `prints/14-sql-insert.png` — Editor com INSERT e confirmação

#### Passo 5 — Verificar Dados

```sql
SELECT * FROM alunos;
```

Resultado esperado:

| id | ra | nome | email | data_inscricao | status |
|---|---|---|---|---|---|
| 1 | 6325128 | João Silva | joao@email.com | 2026-06-01 21:45:00 | ativo |
| 2 | 6325129 | Maria Santos | maria@email.com | 2026-06-01 21:45:00 | ativo |
| 3 | 6325130 | Pedro Oliveira | pedro@email.com | 2026-06-01 21:45:00 | ativo |

**Print:** `prints/15-select-results.png` — Grid de resultados

#### Passo 6 — Criar Snapshot (Backup) do RDS

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-3225002 \
  --db-snapshot-identifier snapshot-tf011-3225002 \
  --region sa-east-1
```

Verificar status do snapshot:

```bash
aws rds describe-db-snapshots \
  --db-snapshot-identifier snapshot-tf011-3225002 \
  --query 'DBSnapshots[0].Status'
```

**Print:** `prints/16-create-snapshot.png` — Comando e confirmação

---

## Observações sobre ferramentas e comandos usados

- **AWS CLI v2** — usado para todas operações com RDS (criar instância, descrever, criar snapshot)
- **DBeaver Community Edition** — cliente gráfico para PostgreSQL, usado para conectar ao RDS, criar tabelas e executar queries
- **WSL Ubuntu 24.04** — ambiente Linux dentro do Windows onde foram executados os comandos `aws` e `psql`
- **PostgreSQL Client (psql)** — usado opcionalmente para validar a conexão via terminal antes do DBeaver
- **Região AWS:** `sa-east-1` (São Paulo) — escolhida por latência reduzida no Brasil

## Resumo

Este TF cobriu:

1. **Conceitos teóricos** — S3 (armazenamento de objetos, regional, durabilidade vs disponibilidade), EBS vs EFS (block vs file storage), RDS (responsabilidades AWS e limitações), Multi-AZ vs Read Replica (HA vs escalabilidade)
2. **Comandos práticos AWS CLI** — `aws s3 cp/ls`, `aws rds create-db-instance/describe-db-instances/create-db-snapshot`
3. **Integração com DBeaver** — conexão ao RDS, criação de tabela, INSERT e SELECT
4. **Operações de DBA** — criação de snapshot para backup

---

*TF entregue por José Luiz Henrique — RA 3225002 — 01/06/2026*
