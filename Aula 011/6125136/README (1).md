# TF Aula 11 — Hector Marcelo Pedroso dos Santos · RA: 6125136

## Disciplina: Implementação de Servidor e Nuvem (Cloud)
## Aula 11: Armazenamento e Banco de Dados na AWS

---

## Questão 1 — Armazenamento de Objetos (S3)

**a)** O principal caso de uso do S3 em aplicações Web e DevOps é o armazenamento de **arquivos estáticos** (imagens, HTML, CSS, JavaScript), **backups de banco de dados**, **logs de aplicação** e **artefatos de deploy** (ex: arquivos `.zip` ou `.jar` para deploy em EC2/Lambda). Ele não é adequado para hospedar sistema operacional nem para logins diretos.

**b)** O S3 é um serviço **regional** — os dados ficam armazenados dentro de uma região específica da AWS. A taxa de "Onze Noves" (99.999999999%) refere-se à **durabilidade** dos objetos, ou seja, a probabilidade extremamente baixa de perda de dados armazenados.

---

## Questão 2 — Armazenamento de Blocos vs. Arquivos (EBS/EFS)

**a)** O **Amazon EBS (Elastic Block Store)** funciona como um disco rígido dedicado: ele é anexado a **uma única instância EC2 por vez**, oferecendo armazenamento em bloco de baixa latência. Já o **Amazon EFS (Elastic File System)** é um sistema de arquivos compartilhado em rede, que pode ser montado e acessado por **múltiplas instâncias EC2 simultaneamente**, sendo ideal para workloads que precisam de acesso concorrente aos mesmos arquivos.

**b)** O **EBS** é o mais adequado para armazenar o Sistema Operacional e o executável da aplicação, pois é o volume de boot padrão das instâncias EC2 — oferece alta performance de I/O e acesso exclusivo, que é exatamente o que um sistema operacional e uma aplicação precisam para funcionar corretamente.

---

## Questão 3 — Banco de Dados Gerenciado (RDS)

**a)** Ao usar o RDS, a AWS assume as seguintes responsabilidades de gerenciamento:
1. **Backups automáticos** — a AWS realiza snapshots automáticos do banco de dados conforme a janela de backup configurada, sem necessidade de intervenção manual.
2. **Aplicação de patches e atualizações** — a AWS gerencia as atualizações de segurança e versão do mecanismo de banco de dados (ex: PostgreSQL, MySQL), aplicando-as automaticamente nas janelas de manutenção.

**b)** A principal desvantagem do RDS em relação a um banco instalado em EC2 é a **menor flexibilidade e controle sobre o ambiente**. No RDS não é possível acessar o sistema operacional do servidor, instalar extensões ou plugins não suportados nativamente, ou realizar configurações avançadas no nível do SO. Em uma instância EC2, o administrador tem controle total sobre o servidor, podendo customizar qualquer parâmetro — porém arcando com toda a responsabilidade de gerenciamento.

---

## Questão 4 — Alta Disponibilidade no RDS (Multi-AZ)

**a)** Quando o **Multi-AZ** é habilitado em uma instância RDS, a AWS provisiona automaticamente uma instância **standby** em uma Zona de Disponibilidade diferente da instância primária. Os dados são replicados de forma **síncrona** entre a instância primária e o standby. Em caso de falha da instância primária (hardware, rede ou manutenção), o RDS realiza o **failover automático**, promovendo o standby para primário sem intervenção manual, com mínimo de downtime.

**b)** A diferença entre **Standby Multi-AZ** e **Read Replica** é:

| Característica | Standby Multi-AZ | Read Replica |
|---|---|---|
| **Uso** | Passivo — não recebe nenhuma requisição de leitura ou escrita | Ativo — recebe requisições de **leitura** para desafogar a primária |
| **Replicação** | **Síncrona** — dados sempre idênticos à primária | **Assíncrona** — pode haver pequeno atraso |
| **Failover** | **Automático** — promovido automaticamente em caso de falha | **Manual** — não faz failover automático; requer intervenção |
| **Objetivo** | Alta disponibilidade e recuperação de desastres | Escalabilidade de leitura e performance |

---

## Questão 5 — Tarefa Prática: Upload S3 via AWS CLI

**Etapa 1 — Criação do arquivo:**
```bash
touch db_config.conf
```
Cria um arquivo vazio chamado `db_config.conf` no diretório atual do terminal WSL.

**Etapa 2 — Upload para o bucket S3:**
```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```
Utiliza o comando `aws s3 cp` (copy) para copiar o arquivo local `db_config.conf` para o bucket S3 chamado `config-app-tf11`.

**Etapa 3 — Verificação do upload:**
```bash
aws s3 ls s3://config-app-tf11/
```
Lista o conteúdo do bucket `config-app-tf11`, permitindo confirmar visualmente que o arquivo `db_config.conf` foi carregado com sucesso, exibindo nome, tamanho e data do arquivo.

---

## Questão 6 — Evidências Práticas (LocalStack)

> **Nota:** Como não possuo conta na AWS, utilizei o **LocalStack** para simular os serviços AWS localmente. O LocalStack emula os serviços S3, RDS e outros da AWS em ambiente local via Docker, sendo amplamente utilizado para desenvolvimento e testes sem custo.

---

### Parte 1 — Evidências de Configuração

#### 1. Configuração de Credenciais AWS
Comando utilizado para configurar credenciais de teste no LocalStack:
```bash
aws configure
# AWS Access Key ID: test
# AWS Secret Access Key: test
# Default region name: us-east-1
# Default output format: json

aws configure list
```
> 📸 *Print 1: Saída do comando `aws configure list` mostrando as credenciais configuradas.*
![alt text](<Captura de tela de 2026-06-03 19-26-17.png>)

#### 2. Teste de Conectividade com RDS
```bash
aws --endpoint-url=http://localhost:4566 rds describe-db-instances
```
> 📸 *Print 2: Saída do comando `describe-db-instances` confirmando conectividade com o serviço RDS no LocalStack.*
![alt text](<Imagem colada.png>)
#### 3. Instalação do Cliente PostgreSQL
```bash
sudo apt install postgresql-client -y
psql --version
```
> 📸 *Print 3: Saída do comando `psql --version` exibindo a versão instalada do cliente PostgreSQL.*
![alt text](<Captura de tela de 2026-06-03 21-13-24.png>)
#### 4. Variável de Ambiente do Endpoint RDS
```bash
export RDS_ENDPOINT="localhost"
echo $RDS_ENDPOINT
```
> 📸 *Print 4: Saída do comando `echo $RDS_ENDPOINT` exibindo o endpoint configurado.*
![alt text](<Captura de tela de 2026-06-03 21-14-57.png>)
---

### Parte 2 — Criação de RDS com Tabela de Alunos

#### 1. Criar Instância RDS PostgreSQL
```bash
aws --endpoint-url=http://localhost:4566 rds create-db-instance \
  --db-instance-identifier rds-tf011-6125136 \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password admin123 \
  --allocated-storage 20 \
  --no-multi-az
```

Verificação da instância criada:
```bash
aws --endpoint-url=http://localhost:4566 rds describe-db-instances \
  --db-instance-identifier rds-tf011-6125136
```
> 📸 *Print 5: Saída do `create-db-instance` confirmando criação da instância `rds-tf011-6125136`.*
> 📸 *Print 6: Saída do `describe-db-instances` mostrando a instância e seu status.*

**Endpoint anotado:** `localhost:4510` (LocalStack)

---

#### 2. Conectar ao Banco de Dados
```bash
sudo -u postgres psql
```
> 📸 *Print 7: Tela de conexão ao PostgreSQL via terminal, confirmando acesso ao banco de dados.*

---

#### 3. Criar Tabela de Alunos
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
> 📸 *Print 8: Execução do script SQL de criação da tabela `alunos` com confirmação de sucesso (`CREATE TABLE`).*

---

#### 4. Inserir Dados de Exemplo
```sql
INSERT INTO alunos (ra, nome, email) VALUES
('6125136', 'Hector Marcelo Pedroso dos Santos', 'hector@email.com'),
('6325129', 'Maria Santos', 'maria@email.com'),
('6325130', 'Pedro Oliveira', 'pedro@email.com');
```
> 📸 *Print 9: Execução do comando INSERT com confirmação (`INSERT 0 3`).*

---

#### 5. Verificar Dados
```sql
SELECT * FROM alunos;
```
> 📸 *Print 10: Resultado do SELECT exibindo os 3 registros inseridos na tabela `alunos`.*

---

#### 6. Criar Snapshot do RDS
```bash
aws --endpoint-url=http://localhost:4566 rds create-db-snapshot \
  --db-instance-identifier rds-tf011-6125136 \
  --db-snapshot-identifier snapshot-tf011-6125136
```
> 📸 *Print 11: Saída do comando `create-db-snapshot` confirmando a criação do snapshot `snapshot-tf011-6125136`.*

---

## Observações Finais

- Todos os comandos AWS CLI foram executados com o parâmetro `--endpoint-url=http://localhost:4566` por utilizar o **LocalStack** como substituto da AWS real.
- O LocalStack foi iniciado via `localstack start -d` e roda sobre Docker.
- O cliente PostgreSQL (`psql`) foi instalado via `sudo apt install postgresql-client` no WSL/Ubuntu.
- As credenciais AWS configuradas são de teste (`test/test`), padrão do LocalStack.
- O endpoint RDS foi armazenado na variável de ambiente `RDS_ENDPOINT` para uso nos comandos de conexão.
