# 6325128 - Implementação de Servidor e Nuvem (Aula 11)

## Respostas Teóricas

### Questão 1: Armazenamento de Objetos (S3)

1. a) Principal caso de uso:
- O Amazon S3 é usado para armazenar e distribuir objetos estáticos de aplicações Web e pipelines DevOps, como arquivos de configuração, logs, backups, artefatos de build/deploy e conteúdo estático (imagens, CSS, JS, etc.).

1. b) Global ou regional?
- O S3 funciona como um serviço regional: o bucket é criado em uma região específica, embora o namespace seja global no nível do nome do bucket.
- A taxa "Onze Noves" (99,999999999%) refere-se à durabilidade dos objetos armazenados no S3.

### Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

2. a) Diferença fundamental:
- Amazon EBS é armazenamento em bloco ligado diretamente a uma instância EC2 como um volume de disco. Ele é usado como disco de sistema operacional, armazenamento local persistente e normalmente só pode ser montado por uma instância por vez (exceto em configurações especiais como Multi-Attach para certos tipos de volume).
- Amazon EFS é um sistema de arquivos gerenciado acessível por rede (NFS); várias instâncias EC2 podem montá-lo simultaneamente dentro da mesma VPC/região. Ele é indicado para compartilhamento de arquivos entre instâncias.

2. b) Para sistema operacional e executável da aplicação:
- O mais adequado é o Amazon EBS, pois ele fornece um volume de bloco para a instância EC2 onde o sistema operacional e o executável da aplicação podem ser instalados e executados diretamente.

### Questão 3: Banco de Dados Gerenciado (RDS)

3. a) Duas responsabilidades que a AWS assume com RDS:
- Gestão de backups e snapshots automáticos.
- Aplicação de patches, manutenção de software e gerência da infraestrutura subjacente (hardware, armazenamento, rede, failover e disponibilidade).

3. b) Principal desvantagem do RDS:
- Menor controle e flexibilidade em comparação com um banco de dados instalado diretamente em EC2, pois não há acesso ao sistema operacional do servidor de banco e há limitações em parâmetros de configuração e customização da instância.

### Questão 4: Alta Disponibilidade no RDS

4. a) O que acontece com Multi-AZ:
- Quando o Multi-AZ é habilitado, o RDS cria uma réplica síncrona em outra Availability Zone. Os dados são replicados automaticamente do nó primário para o standby em outra zona de disponibilidade.

4. b) Diferença entre Standby e Read Replica:
- Standby no Multi-AZ é uma réplica de alta disponibilidade usada apenas para failover automático. Ela não serve para leitura normal e fica pronta para assumir automaticamente em caso de falha.
- Read Replica é uma réplica para escalabilidade de leitura. Ela pode ser usada para consultas de leitura e, em alguns casos, pode ser promovida manualmente a instância principal, mas não oferece failover automático como o standby Multi-AZ.

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI)

### Passo 1: Criação do arquivo no WSL/Linux

```bash
cat > db_config.conf <<'EOF'
# Configuração de banco de dados de exemplo
DB_HOST=example-db-host
DB_PORT=5432
DB_NAME=meu_banco
DB_USER=admin
DB_PASSWORD=minha_senha
EOF
```

### Passo 2: Upload para o bucket S3

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### Passo 3: Verificação do arquivo no bucket

```bash
aws s3 ls s3://config-app-tf11/
```

## Questão 6: Evidências Práticas de Configuração e Criação de Banco de Dados RDS

> Observação: aqui estão os comandos e os passos. Para evidências visuais, inclua prints/screenshots na pasta se você executar em AWS real ou LocalStack.

### Parte 1: Evidências de Configuração

1. Configuração de credenciais AWS:
```bash
aws configure list
```

2. Teste de conectividade com RDS:
```bash
aws rds describe-db-instances
```

3. Versão do cliente PostgreSQL:
```bash
psql --version
```

4. Variável de ambiente do endpoint RDS:
```bash
echo "$RDS_ENDPOINT"
# ou
printenv RDS_ENDPOINT
```

### Parte 2: Exercício de Criação de RDS com Tabela de Alunos

1. Comando para criar a instância RDS PostgreSQL:

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325128 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --allocated-storage 20 \
  --master-username admin \
  --master-user-password MinhaSenhaSegura123 \
  --backup-retention-period 7 \
  --publicly-accessible false \
  --storage-type gp2
```

2. Comando para descrever a instância e verificar status:

```bash
aws rds describe-db-instances --db-instance-identifier rds-tf011-6325128
```

3. Anotar o endpoint retornado pelo comando acima e usar para conectar no DBeaver.

4. No DBeaver, criar conexão PostgreSQL usando:
- Server Host: `<endpoint-rds>`
- Port: `5432`
- Database: `<nome-do-banco>`
- Username: `admin`
- Password: `MinhaSenhaSegura123`

5. Script SQL para criar a tabela `alunos`:

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

6. Script SQL para inserir dados de exemplo:

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325128', 'João Silva', 'joao@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

7. Verificar dados:

```sql
SELECT * FROM alunos;
```

8. Criar snapshot do RDS:

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325128 \
  --db-snapshot-identifier snapshot-tf011-6325128
```

> Se estiver usando LocalStack, adicionar `--endpoint-url=http://localhost:4566` em todos os comandos AWS CLI.