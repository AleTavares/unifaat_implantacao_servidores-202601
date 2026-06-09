# Comandos Práticos - TF011 AWS

Este arquivo contém todos os comandos para executar a Questão 6 (Prática RDS).

## Pré-requisitos

1. AWS CLI instalado: `aws --version`
2. Credenciais configuradas: `aws configure`
3. DBeaver instalado
4. PostgreSQL CLI (psql) instalado: `sudo apt-get install postgresql-client`

## Passo 1: Configurar AWS CLI

```bash
# Configurar credenciais
aws configure

# Será solicitado:
# AWS Access Key ID: [Insira sua Access Key]
# AWS Secret Access Key: [Insira sua Secret Key]
# Default region name: us-east-1
# Default output format: json
```

## Passo 2: Verificar Configuração

```bash
# Listar configuração
aws configure list

# Testar conectividade
aws ec2 describe-regions --region us-east-1
```

## Passo 3: Criar Instância RDS PostgreSQL

```bash
# Criar banco de dados RDS
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-4025109 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.7 \
  --master-username admin \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --publicly-accessible \
  --backup-retention-period 7 \
  --multi-az \
  --region us-east-1

# ⏳ Aguarde 5-10 minutos para a instância ficar "available"
```

## Passo 4: Monitorar Status da Instância

```bash
# Verificar status em tempo real
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-4025109 \
  --region us-east-1 \
  --query 'DBInstances[0].{ID:DBInstanceIdentifier,Status:DBInstanceStatus,Endpoint:Endpoint.Address}' \
  --output table

# Continue executando até ver Status: "available"
```

## Passo 5: Extrair Endpoint e Configurar Variável de Ambiente

```bash
# Extrair o endpoint
ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-4025109 \
  --region us-east-1 \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

# Verificar endpoint
echo "RDS Endpoint: $ENDPOINT"

# Salvar em variável de ambiente permanente (adicione ao ~/.bashrc)
echo "export RDS_ENDPOINT=$ENDPOINT" >> ~/.bashrc
echo "export RDS_USER=admin" >> ~/.bashrc
echo "export RDS_PASSWORD=YourSecurePassword123!" >> ~/.bashrc
echo "export RDS_PORT=5432" >> ~/.bashrc

# Carregar as variáveis no shell atual
source ~/.bashrc
```

## Passo 6: Conectar via psql (Linha de Comando)

```bash
# Conectar ao banco de dados
psql -h $RDS_ENDPOINT -U admin -d postgres

# Será solicitado a senha, insira: YourSecurePassword123!

# Dentro do psql:
\l                          -- Listar bancos de dados
\du                         -- Listar usuários
\q                          -- Sair
```

## Passo 7: Criar Tabela de Alunos (via psql)

Dentro do psql, execute:

```sql
-- Criar tabela
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    ra VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo'))
);

-- Verificar tabela criada
\dt

-- Descrever estrutura da tabela
\d alunos
```

## Passo 8: Inserir Dados

```sql
-- Inserir dados de exemplo
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com'),
('4025109', 'Seu Nome', 'seu.email@email.com');

-- Confirmar inserção
SELECT COUNT(*) FROM alunos;
```

## Passo 9: Verificar Dados

```sql
-- Ver todos os alunos
SELECT * FROM alunos;

-- Ver apenas alguns campos
SELECT ra, nome, email, status FROM alunos;

-- Filtrar por RA
SELECT * FROM alunos WHERE ra = '4025109';

-- Contar alunos ativos
SELECT COUNT(*) as total_alunos FROM alunos WHERE status = 'ativo';
```

## Passo 10: Criar Snapshot (Backup)

```bash
# Criar snapshot
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-4025109 \
  --db-snapshot-identifier snapshot-tf011-4025109 \
  --region us-east-1

# Verificar status do snapshot
aws rds describe-db-snapshots \
  --db-snapshot-identifier snapshot-tf011-4025109 \
  --region us-east-1 \
  --query 'DBSnapshots[0].{ID:DBSnapshotIdentifier,Status:Status,Size:AllocatedStorage}' \
  --output table

# Listar todos os snapshots
aws rds describe-db-snapshots --region us-east-1 --output table
```

## Passo 11: Usar DBeaver (Alternativa Gráfica)

1. Abrir DBeaver
2. File → New Database Connection
3. Selecionar PostgreSQL
4. Preencher:
   - **Server Host**: `$ENDPOINT` (cole o endpoint do RDS)
   - **Port**: 5432
   - **Database**: postgres
   - **Username**: admin
   - **Password**: YourSecurePassword123!
5. Clicar "Test Connection" → Sucesso
6. Clicar "Finish"
7. No painel esquerdo, expandir PostgreSQL → postgres → public
8. Right-click em Tables → Create New Table
9. Preencher os campos conforme o schema da tabela `alunos`

## Passo 12: Conectar LocalStack (Alternativa Gratuita)

Se preferir não usar AWS real, pode usar LocalStack:

```bash
# Instalar Docker e LocalStack
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
docker pull localstack/localstack

# Iniciar LocalStack em outra aba
docker run -it -p 4566:4566 -p 4571:4571 localstack/localstack

# Em outra aba, configurar AWS CLI para LocalStack
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1

# Testar LocalStack
aws s3 ls --endpoint-url=http://localhost:4566

# Criar bucket S3
aws s3 mb s3://config-app-tf11 --endpoint-url=http://localhost:4566

# Upload de arquivo
aws s3 cp db_config.conf s3://config-app-tf11/ --endpoint-url=http://localhost:4566

# Listar bucket
aws s3 ls s3://config-app-tf11 --endpoint-url=http://localhost:4566
```

## Limpeza (Deletar Recursos - ⚠️ Cuidado!)

```bash
# Deletar snapshot
aws rds delete-db-snapshot \
  --db-snapshot-identifier snapshot-tf011-4025109 \
  --region us-east-1

# Deletar instância RDS (sem fazer snapshot final)
aws rds delete-db-instance \
  --db-instance-identifier rds-tf011-4025109 \
  --skip-final-snapshot \
  --region us-east-1

# Deletar bucket S3
aws s3 rm s3://config-app-tf11 --recursive --endpoint-url=http://localhost:4566
aws s3 rb s3://config-app-tf11 --endpoint-url=http://localhost:4566
```

---

## Dicas Importantes

- 💰 **Custos**: RDS db.t3.micro é cobrado por hora de uso. Não esqueça de deletar após terminar!
- 🔐 **Segurança**: Nunca comita senhas em repositórios. Use variáveis de ambiente.
- ⏱️ **Timing**: RDS leva ~5-10 minutos para ficar pronto após criação
- 📸 **Evidências**: Tire screenshots dos passos para documentar na entrega
- 🔄 **Multi-AZ**: Aumenta custo, mas garante HA (recomendado para produção)

---

## Padrão de Resposta para Capturas de Tela

Ao capturar, inclua:

```
[Evidência 1] aws configure list
- Data/Hora: YYYY-MM-DD HH:MM:SS
- Comando: aws configure list
- Resultado: [Cole a saída aqui]
- Observação: Credenciais parcialmente ocultas (*****)

[Evidência 2] RDS Status
- Comando: aws rds describe-db-instances
- Status: available
- Endpoint: rds-tf011-4025109.xxxxx.rds.amazonaws.com

[Evidência 3] DBeaver Connection
- Screenshot: [Cole printscreen]
- Status: Connection Successful
- Tables: alunos (4 registros)
```

---

## Arquivos Gerados

Após completar todos os passos, você terá:

```
Aula 011/4025109/
├── README.md                    (Respostas teóricas)
├── COMANDOS_PRATICOS.md         (Este arquivo)
├── prints/
│   ├── 01-aws-configure-list.png
│   ├── 02-rds-describe.png
│   ├── 03-psql-version.png
│   ├── 04-tabela-criada.png
│   ├── 05-dados-inseridos.png
│   ├── 06-snapshot-criado.png
│   └── 07-dbeaver-conexao.png
└── scripts/
    ├── create-table.sql
    └── insert-data.sql
```

Bom trabalho! 🚀
