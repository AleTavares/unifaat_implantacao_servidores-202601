Nome: Leonardo Rafael Contini Costa  RA: 6325054

# Respostas - AWS Storage e Banco de Dados

## Questão 1: Armazenamento de Objetos (S3)

### a)
O principal caso de uso do Amazon S3 em aplicações Web e ambientes DevOps é o armazenamento de objetos, como arquivos estáticos, imagens, vídeos, backups, logs, documentos e artefatos de aplicações. Também é amplamente utilizado para hospedagem de sites estáticos, armazenamento de logs e backup de dados.

### b)
O Amazon S3 é um serviço regional. Embora os buckets sejam acessados globalmente por meio de URLs, cada bucket é criado em uma região específica da AWS.

A taxa de "Onze Noves" (99,999999999%) representa a **durabilidade** dos dados armazenados no S3. Isso significa que a probabilidade de perda de dados é extremamente baixa.

---

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

### a)
A principal diferença entre Amazon EBS e Amazon EFS é:

- **Amazon EBS (Elastic Block Store):** fornece armazenamento em blocos que normalmente é conectado a uma única instância EC2 por vez, funcionando como um disco rígido virtual.
- **Amazon EFS (Elastic File System):** fornece um sistema de arquivos compartilhado que pode ser montado simultaneamente por várias instâncias EC2.

### b)
Para armazenar o Sistema Operacional e o executável da aplicação em uma instância EC2, o serviço mais adequado é o **Amazon EBS**, pois ele oferece armazenamento em blocos com baixa latência e é ideal para discos de inicialização (boot volumes).

---

## Questão 3: Banco de Dados Gerenciado (RDS)

### a)
Ao utilizar o Amazon RDS, a AWS assume diversas tarefas administrativas, entre elas:

1. Aplicação de patches e atualizações do banco de dados.
2. Realização de backups automáticos e recuperação de dados.

Outras responsabilidades incluem monitoramento, provisionamento de hardware e gerenciamento de armazenamento.

### b)
A principal desvantagem do RDS em comparação com um banco de dados instalado diretamente em uma EC2 é a menor flexibilidade de administração. O usuário não possui acesso completo ao sistema operacional ou ao banco de dados para realizar configurações avançadas e personalizações específicas.

---

## Questão 4: Alta Disponibilidade no RDS

### a)
Quando o Multi-AZ é habilitado no RDS, a AWS cria automaticamente uma instância de banco de dados secundária (Standby) em outra Availability Zone da mesma região. Os dados são replicados de forma síncrona da instância principal para a instância Standby.

### b)
Diferenças entre Standby e Read Replica:

| Característica | Multi-AZ Standby | Read Replica |
|---------------|------------------|--------------|
| Objetivo | Alta disponibilidade | Escalabilidade de leitura |
| Replicação | Síncrona | Assíncrona |
| Acesso para leitura | Não | Sim |
| Failover automático | Sim | Não |
| Uso principal | Recuperação em falhas | Distribuição de consultas de leitura |

---

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI)

### 1. Criação do Arquivo

Para criar um arquivo de teste chamado `db_config.conf` no ambiente WSL/Linux:

```bash
touch db_config.conf
```

Opcionalmente, para adicionar conteúdo:

```bash
echo "database=config" > db_config.conf
```

### 2. Upload (Sintaxe CLI)

Para copiar o arquivo para o bucket `config-app-tf11`:

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### 3. Verificação

Para listar o conteúdo do bucket e confirmar o upload:

```bash
aws s3 ls s3://config-app-tf11/
```

Se o arquivo foi carregado com sucesso, ele aparecerá na listagem retornada pelo comando.