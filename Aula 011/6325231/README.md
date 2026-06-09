# TF011 - Armazenamento e Banco de Dados na AWS

Aluno: Andreyh Rodrigues de Souza  
RA: 6325231  
Disciplina: Implementacao de servidor e nuvem (cloud)  
Aula: 11 - Armazenamento e Banco de Dados na AWS  
Ambiente utilizado: AWS real via AWS CLI no WSL/Linux

## Questao 1: Armazenamento de Objetos (S3)

### a) Principal caso de uso do S3

O Amazon S3 e usado principalmente para armazenar objetos, como arquivos estaticos de uma aplicacao web, imagens, videos, documentos, backups, logs, artefatos de deploy e arquivos de configuracao. Em DevOps, ele e muito usado para guardar artefatos de pipeline, backups, arquivos de configuracao e conteudo estatico.

O S3 nao e indicado para hospedar sistema operacional ou disco de uma instancia, pois ele nao e armazenamento em bloco. Para sistema operacional de EC2, o servico adequado e o EBS.

### b) Servico global ou regional e significado dos "Onze Noves"

O S3 tem namespace global para nomes de buckets, ou seja, o nome do bucket precisa ser unico globalmente. Porem, cada bucket e criado em uma regiao especifica da AWS.

A taxa de "Onze Noves" (99.999999999%) representa a durabilidade dos objetos armazenados no S3, isto e, a capacidade do servico de preservar os dados sem perda. Essa taxa nao representa disponibilidade.

## Questao 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

### a) Diferenca entre EBS e EFS

O Amazon EBS e um armazenamento em bloco, conectado a uma instancia EC2 como se fosse um disco. Ele e ideal para sistema operacional, volumes de dados, bancos de dados e aplicacoes que precisam de baixa latencia. Normalmente, um volume EBS fica associado a uma zona de disponibilidade e e usado por uma instancia principal.

O Amazon EFS e um sistema de arquivos compartilhado, acessado via NFS. Ele pode ser montado simultaneamente por varias instancias EC2, sendo adequado para aplicacoes distribuidas, compartilhamento de arquivos, conteudo comum entre servidores e workloads que precisam de acesso concorrente.

### b) Melhor servico para sistema operacional e executavel da aplicacao

Para armazenar o sistema operacional e o executavel da aplicacao em um servidor EC2, o mais adequado e o Amazon EBS, pois ele funciona como disco da instancia e oferece armazenamento em bloco com baixa latencia.

## Questao 3: Banco de Dados Gerenciado (RDS)

### a) Duas responsabilidades assumidas pela AWS no RDS

Ao usar o Amazon RDS, a AWS assume responsabilidades como:

- Aplicacao de patches e manutencao do mecanismo de banco de dados.
- Backups automaticos e recuperacao point-in-time.

Outras responsabilidades gerenciadas incluem monitoramento, substituicao de infraestrutura, alta disponibilidade com Multi-AZ e escalabilidade vertical.

### b) Principal desvantagem do RDS em comparacao com banco em EC2

A principal desvantagem do RDS e a menor liberdade de controle sobre o servidor e o sistema operacional. Em uma instalacao autogerenciada em EC2, o administrador tem acesso completo ao sistema, pode instalar extensoes, alterar configuracoes avancadas e customizar o ambiente. No RDS, parte dessas configuracoes e limitada porque a infraestrutura e gerenciada pela AWS.

## Questao 4: Alta Disponibilidade no RDS

### a) O que acontece ao habilitar Multi-AZ

Ao habilitar Multi-AZ no RDS, a AWS cria uma instancia standby em outra Availability Zone dentro da mesma regiao. Os dados da instancia principal sao replicados de forma sincrona para essa instancia standby. Se ocorrer falha na instancia principal, na zona de disponibilidade ou em algum componente de infraestrutura, a AWS realiza failover automatico para o standby.

### b) Diferenca entre Standby Multi-AZ e Read Replica

O standby do Multi-AZ e usado para alta disponibilidade e failover automatico. Ele nao e usado para leitura normal da aplicacao, pois fica reservado para assumir o papel de banco principal em caso de falha.

A Read Replica e usada para escalar leituras. Ela recebe replicacao da instancia principal, normalmente de forma assincrona, e pode atender consultas SELECT. A Read Replica nao substitui automaticamente o banco principal como o standby Multi-AZ, embora possa ser promovida manualmente em alguns cenarios.

## Questao 5: Tarefa Pratica Integrada - Upload para S3

### 1. Criacao do arquivo no WSL/Linux

Comando usado para criar um arquivo de teste chamado `db_config.conf`:

```bash
touch db_config.conf
```

Tambem foi criado um arquivo nesta pasta com conteudo de exemplo:

```bash
echo "DB_ENGINE=postgres" > db_config.conf
```

### 2. Upload do arquivo para o bucket S3

Comando AWS CLI para copiar o arquivo para o bucket `config-app-tf11`:

```bash
aws s3 cp db_config.conf s3://config-app-tf11/db_config.conf
```

Caso o bucket ainda nao exista, ele pode ser criado antes com:

```bash
aws s3 mb s3://config-app-tf11 --region us-east-2
```

### 3. Verificacao do upload

Comando para listar o conteudo do bucket e confirmar o arquivo:

```bash
aws s3 ls s3://config-app-tf11/
```

## Questao 6: Evidencias praticas de RDS PostgreSQL

Esta atividade foi preparada para AWS real. Os prints devem ser adicionados nesta pasta e referenciados nesta secao. Por seguranca, chaves de acesso e senha do banco devem ficar ocultas nos prints.

### Parte 1: Evidencias de configuracao

#### Evidencia 1 - Credenciais AWS configuradas

Comando:

```bash
aws configure list
```

Print esperado: saida mostrando profile, access key parcialmente mascarada, secret key mascarada e regiao configurada.

Arquivo do print: `evidencia-01-aws-configure-list.png`

#### Evidencia 2 - Teste de conectividade com RDS

Comando:

```bash
aws rds describe-db-instances --region us-east-2
```

Print esperado: retorno JSON da AWS ou lista de instancias RDS da conta.

Arquivo do print: `evidencia-02-rds-describe-db-instances.png`

#### Evidencia 3 - Cliente PostgreSQL instalado

Comando:

```bash
psql --version
```

Print esperado: versao instalada do cliente PostgreSQL.

Arquivo do print: `evidencia-03-psql-version.png`

#### Evidencia 4 - Variavel de ambiente do endpoint RDS

Comandos:

```bash
export RDS_ENDPOINT="<endpoint-rds>"
echo $RDS_ENDPOINT
```

Print esperado: terminal exibindo o endpoint configurado.

Arquivo do print: `evidencia-04-rds-endpoint-env.png`

### Parte 2: Criacao do RDS com tabela de alunos

#### 1. Criar instancia RDS PostgreSQL

Comando utilizado para criar a instancia:

```bash
aws rds create-db-instance \
  --db-instance-identifier rds-tf011-6325231 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --allocated-storage 20 \
  --storage-type gp2 \
  --master-username postgres \
  --master-user-password "<senha-forte>" \
  --db-name tf011db \
  --backup-retention-period 7 \
  --publicly-accessible \
  --no-multi-az \
  --region us-east-2
```

Observacao: caso o DBeaver nao consiga conectar, verificar se o Security Group associado ao RDS permite entrada TCP na porta `5432` a partir do IP usado no WSL/rede local.

Print do comando e retorno:

Arquivo do print: `evidencia-05-create-db-instance.png`

Comando para consultar status:

```bash
aws rds describe-db-instances \
  --db-instance-identifier rds-tf011-6325231 \
  --query "DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,Endpoint.Port]" \
  --output table \
  --region us-east-2
```

Print esperado: instancia criada com status `creating`, `backing-up` ou `available`, endpoint e porta.

Arquivo do print: `evidencia-06-describe-db-instance-status.png`

Comando para aguardar a instancia ficar disponivel:

```bash
aws rds wait db-instance-available \
  --db-instance-identifier rds-tf011-6325231 \
  --region us-east-2
```

Endpoint anotado:

```text
<endpoint-rds>
```

#### 2. Conectar ao banco via DBeaver

Configuracao usada no DBeaver:

- Tipo de banco: PostgreSQL
- Server Host: `<endpoint-rds>`
- Port: `5432`
- Database: `tf011db`
- Username: `postgres`
- Password: senha definida no comando de criacao

Prints solicitados:

- Tela de criacao da conexao: `evidencia-07-dbeaver-criacao-conexao.png`
- Resultado do teste de conexao com sucesso: `evidencia-08-dbeaver-test-connection.png`
- Lista de conexoes mostrando a nova conexao: `evidencia-09-dbeaver-lista-conexoes.png`

#### 3. Criar tabela de alunos

Script executado no DBeaver:

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

Prints solicitados:

- Editor SQL com o comando: `evidencia-10-create-table-editor.png`
- Confirmacao de sucesso: `evidencia-11-create-table-sucesso.png`
- Estrutura da tabela no navegador de objetos: `evidencia-12-estrutura-tabela-alunos.png`

#### 4. Inserir dados de exemplo

Script executado:

```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6325231', 'Andreyh Rodrigues de Souza', 'andreyh@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```

Print solicitado:

- Editor SQL com comando de insercao e confirmacao: `evidencia-13-insert-alunos.png`

#### 5. Verificar dados

Consulta executada:

```sql
SELECT * FROM alunos;
```

Print solicitado:

- Grid de resultados do DBeaver com os dados: `evidencia-14-select-alunos.png`

#### 6. Criar snapshot do RDS

Comando:

```bash
aws rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6325231 \
  --db-snapshot-identifier snapshot-tf011-6325231 \
  --region us-east-2
```

Print solicitado:

- Comando e resultado de confirmacao do snapshot: `evidencia-15-create-db-snapshot.png`

## Observacoes sobre ferramentas e comandos usados

- AWS CLI: utilizada para configurar credenciais, testar conectividade, criar instancia RDS, consultar status, criar snapshot e fazer upload no S3.
- Amazon S3: utilizado para armazenamento de objeto do arquivo `db_config.conf`.
- Amazon RDS PostgreSQL: utilizado como banco de dados relacional gerenciado.
- DBeaver: utilizado para conexao grafica ao PostgreSQL, criacao da tabela, insercao e consulta dos dados.
- PostgreSQL Client (`psql`): utilizado para validar a instalacao do cliente PostgreSQL no WSL/Linux.

## Checklist de evidencias para entrega

- [ ] `evidencia-01-aws-configure-list.png`
- [ ] `evidencia-02-rds-describe-db-instances.png`
- [ ] `evidencia-03-psql-version.png`
- [ ] `evidencia-04-rds-endpoint-env.png`
- [ ] `evidencia-05-create-db-instance.png`
- [ ] `evidencia-06-describe-db-instance-status.png`
- [ ] `evidencia-07-dbeaver-criacao-conexao.png`
- [ ] `evidencia-08-dbeaver-test-connection.png`
- [ ] `evidencia-09-dbeaver-lista-conexoes.png`
- [ ] `evidencia-10-create-table-editor.png`
- [ ] `evidencia-11-create-table-sucesso.png`
- [ ] `evidencia-12-estrutura-tabela-alunos.png`
- [ ] `evidencia-13-insert-alunos.png`
- [ ] `evidencia-14-select-alunos.png`
- [ ] `evidencia-15-create-db-snapshot.png`

## Limpeza dos recursos AWS apos a entrega

Para evitar custos, apos finalizar os prints e a entrega, remover os recursos criados.

Remover snapshot, se nao for mais necessario:

```bash
aws rds delete-db-snapshot \
  --db-snapshot-identifier snapshot-tf011-6325231 \
  --region us-east-2
```

Remover instancia RDS:

```bash
aws rds delete-db-instance \
  --db-instance-identifier rds-tf011-6325231 \
  --skip-final-snapshot \
  --delete-automated-backups \
  --region us-east-2
```

Remover arquivo e bucket S3:

```bash
aws s3 rm s3://config-app-tf11/db_config.conf
aws s3 rb s3://config-app-tf11
```

## Titulo sugerido para o Pull Request

```text
6325231 - Andreyh Rodrigues de Souza
```
