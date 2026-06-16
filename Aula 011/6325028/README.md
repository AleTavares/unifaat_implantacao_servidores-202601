# Conclusão

Durante o laboratório foram realizados procedimentos de armazenamento utilizando Amazon S3 e gerenciamento de banco de dados utilizando Amazon RDS PostgreSQL. Também foram realizados testes de conectividade, criação de tabela, inserção de dados, consulta de registros e criação de snapshot para backup da instância.# TF011 - Armazenamento e Banco de Dados na AWS

## Aluna
Denise Maider

## RA
6325028

---

# Questão 1 - Amazon S3

### a)
O Amazon S3 (Simple Storage Service) é um serviço de armazenamento de objetos utilizado para armazenar arquivos estáticos, backups, logs, imagens, documentos e arquivos de configuração de aplicações Web.

### b)
O Amazon S3 é um serviço regional. A taxa de 99.999999999% (Onze Noves) refere-se à durabilidade dos dados armazenados.

---

# Questão 2 - EBS e EFS

### a)
O Amazon EBS (Elastic Block Store) fornece armazenamento em blocos que normalmente é conectado a uma única instância EC2.

O Amazon EFS (Elastic File System) fornece um sistema de arquivos compartilhado que pode ser utilizado simultaneamente por várias instâncias EC2.

### b)
O Amazon EBS é o serviço mais adequado para armazenar o sistema operacional e os executáveis de uma aplicação hospedada em uma instância EC2.

---

# Questão 3 - Amazon RDS

### a)
Ao utilizar o Amazon RDS, a AWS assume diversas tarefas administrativas, entre elas:

- Backups automáticos.
- Aplicação de patches e atualizações do banco de dados.

### b)
A principal limitação do RDS em relação a um banco instalado diretamente em uma EC2 é a menor flexibilidade e controle sobre o sistema operacional e a configuração interna do banco.

---

# Questão 4 - Multi-AZ

### a)
Ao habilitar o Multi-AZ, a AWS cria automaticamente uma instância standby em outra Availability Zone e replica os dados de forma síncrona.

### b)
A instância Standby do Multi-AZ é utilizada para failover automático em caso de falha.

Já a Read Replica é utilizada para aumentar a capacidade de leitura do banco de dados e não realiza failover automático.

---

# Questão 5 - Fluxo de Upload para o S3

### Criação do Arquivo

```bash
touch db_config.conf
```

### Upload para o Bucket

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### Verificação

```bash
aws s3 ls s3://config-app-tf11/
```

---

# Questão 6 - Evidências Práticas

## Evidência 1 - Configuração da AWS CLI

Comando executado:

```bash
aws configure list
```

Resultado:

- Credenciais configuradas com sucesso.
- Região configurada: us-east-2.

Print: aws-configure-list.png

---

## Evidência 2 - Criação do Bucket S3

Bucket utilizado:

```text
lab-devops-config-app-tf11
```

Comandos executados:

```bash
aws s3 mb s3://lab-devops-config-app-tf11
aws s3 cp config_app_v1.txt s3://lab-devops-config-app-tf11/config/
aws s3 ls s3://lab-devops-config-app-tf11
```

Resultado:

- Bucket criado com sucesso.
- Arquivo enviado para a pasta config.

Print: s3-bucket.png

---

## Evidência 3 - Criação da Instância RDS PostgreSQL

Comando executado:

```bash
aws rds create-db-instance
```

Configurações utilizadas:

- Identificador: rds-tf011-6325028
- Engine: PostgreSQL
- Classe: db.t3.micro
- Região: us-east-2

Print: rds-create.png

---

## Evidência 4 - Verificação da Instância RDS

Comando executado:

```bash
aws rds describe-db-instances
```

Resultado:

- Status: available
- Endpoint:
  rds-tf011-6325028.czcioqemkib9.us-east-2.rds.amazonaws.com

Print: rds-available.png

---

## Evidência 5 - Instalação do Cliente PostgreSQL

Comando executado:

```bash
psql --version
```

Resultado:

Cliente PostgreSQL instalado com sucesso.

Print: psql-version.png

---

## Evidência 6 - Conexão via DBeaver

Conexão realizada com sucesso utilizando:

- Host: rds-tf011-6325028.czcioqemkib9.us-east-2.rds.amazonaws.com
- Porta: 5432
- Database: postgres
- Usuário: postgres

Prints:

- dbeaver-connection.png
- dbeaver-test-success.png

---

## Evidência 7 - Criação da Tabela Alunos

Script executado:

```sql
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    ra VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Resultado:

Tabela criada com sucesso.

Print: create-table.png

---

## Evidência 8 - Inserção de Dados

Script executado:

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

Resultado:

3 registros inseridos com sucesso.

Print: insert-alunos.png

---

## Evidência 9 - Consulta dos Dados

Script executado:

```sql
SELECT * FROM alunos;
```

Resultado:

Foram retornados 3 registros da tabela alunos.

Print: select-alunos.png

---

## Evidência 10 - Snapshot do Banco

Comando executado:

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325028 \
  --db-snapshot-identifier snapshot-tf011-6325028
```

Resultado:

Snapshot criado com sucesso para backup da instância RDS.

Print: snapshot.png

---

# Conclusão

Durante o laboratório foram realizados procedimentos de armazenamento utilizando Amazon S3 e gerenciamento de banco de dados utilizando Amazon RDS PostgreSQL. Também foram realizados testes de conectividade, criação de tabela, inserção de dados, consulta de registros e criação de snapshot para backup da instância.
