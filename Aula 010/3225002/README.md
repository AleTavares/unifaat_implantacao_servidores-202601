# TF - Aula 10 - Conceitos de Infraestrutura em Nuvem e AWS

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)
**Aula:** 10 — Conceitos de Infraestrutura em Nuvem e AWS

---

## Questão 1 — Modelos de Serviço em Nuvem

### a) AWS EC2 (Elastic Compute Cloud)

O **EC2** representa o modelo **IaaS (Infraestrutura como Serviço)**.

Neste modelo, a AWS provisiona o hardware virtualizado (CPU, memória, rede, storage), mas o **usuário fica responsável por gerenciar tudo do Sistema Operacional pra cima**: instalar e atualizar o SO (Ubuntu, Amazon Linux, Windows Server), aplicar patches de segurança, configurar firewall do SO, instalar runtime (Node, Python, JVM), implantar aplicação, monitorar a instância, fazer backup de dados, etc.

A AWS só garante a camada de infraestrutura (host físico, hypervisor, rede física, energia).

### b) Exemplos de SaaS e PaaS na AWS

**SaaS (Software as a Service)** — usuário só consome o produto pronto:
- **Amazon Chime** — software de videoconferência
- **Amazon WorkMail** — e-mail corporativo gerenciado
- **Amazon Connect** — central de atendimento (call center) na nuvem

**PaaS (Platform as a Service)** — usuário sobe só o código/dado, plataforma cuida do resto:
- **AWS Elastic Beanstalk** — sobe a aplicação web e a AWS gerencia EC2, balanceador, escalonamento automaticamente
- **AWS Lambda** — função serverless, basta enviar o código (a AWS gerencia runtime, escala, infra)
- **Amazon RDS** — banco de dados gerenciado (PostgreSQL, MySQL, etc); usuário gerencia esquema, queries — AWS gerencia versão, backup, patch.

---

## Questão 2 — Identidade e Acesso (IAM)

### a) Usuário IAM vs Grupo IAM

| | Usuário IAM | Grupo IAM |
|---|---|---|
| O que é | Identidade individual com credenciais próprias (login + senha ou chaves de acesso) | Coleção de usuários que **compartilham permissões** |
| Credencial | Tem credencial própria | Não tem credencial (é só agrupamento lógico) |
| Permissão | Pode receber políticas diretamente OU herdar do grupo | Recebe políticas que se aplicam a todos os membros |

**Diferença fundamental:** Usuário é a identidade individual que faz login/autentica. Grupo é uma forma de gerenciamento em escala — em vez de atribuir 10 políticas pra cada um dos 20 usuários, você atribui as políticas a 1 grupo e adiciona os 20 usuários nele.

### b) Role IAM vs chaves de Root/Administrador

Usar **Role IAM** em vez de chaves de Root/Admin pra dar permissão a uma instância EC2 acessar o S3 é melhor prática porque:

1. **Sem credenciais armazenadas na instância:** ao usar chaves de usuário, você precisaria salvar `aws_access_key_id` e `aws_secret_access_key` em algum arquivo dentro do EC2 (ex: `~/.aws/credentials`). Se a instância for comprometida, as chaves são vazadas. Com Role, as credenciais não ficam armazenadas — elas são obtidas dinamicamente do serviço de metadados (IMDS).

2. **Credenciais temporárias com rotação automática:** a Role usa AWS STS (Security Token Service) que gera credenciais temporárias renovadas automaticamente. Mesmo se um atacante capturar essas credenciais, elas expiram em poucas horas.

3. **Princípio do menor privilégio:** a Role concede APENAS as permissões necessárias (ex: ler de um bucket específico). Chaves de Admin/Root têm acesso total — se vazarem, atacante tem controle da conta inteira.

4. **Auditoria:** ações da instância ficam rastreadas como vindas da Role específica no CloudTrail, facilitando auditoria.

5. **Sem necessidade de gerenciar segredos:** você não precisa girar manualmente chaves, atualizar arquivos, redeployar, etc.

---

## Questão 3 — Rede Virtual na AWS (VPC)

### a) Subnet, Subnet Pública vs Privada

**Subnet** é uma subdivisão da VPC com um intervalo de endereços IP CIDR específico (ex: `10.0.1.0/24`), vinculada a uma **Availability Zone (AZ)** específica. Toda subnet pertence a uma única VPC e a uma única AZ — para alta disponibilidade, distribui-se recursos em múltiplas subnets de AZs diferentes.

**Diferença Pública vs Privada:** a distinção não está no IP da subnet em si, mas na **tabela de rotas (Route Table)** associada a ela.

| | Subnet Pública | Subnet Privada |
|---|---|---|
| Tabela de Rotas | Tem rota `0.0.0.0/0` → **Internet Gateway (IGW)** | NÃO tem rota direta pro IGW |
| Acesso da Internet | Instâncias podem receber IP público e ser acessadas externamente | Instâncias não são acessíveis diretamente pela Internet |
| Saída pra Internet | Direto via IGW | Apenas via **NAT Gateway** posicionado em subnet pública |
| Uso típico | Servidores web, bastion hosts, balanceadores | Bancos de dados, app servers internos, recursos sensíveis |

### b) Componentes de rede

- **Componente obrigatório pra subnet pública acessar Internet:** **Internet Gateway (IGW)** — gateway de rede horizontalmente escalável e altamente disponível que permite comunicação entre a VPC e a Internet. Sem IGW associado à VPC + rota na route table apontando pra ele, instâncias da subnet pública não conseguem nem sair pra Internet nem receber tráfego dela.

- **Componente que inspeciona tráfego em nível de subnet:** **Network ACL (NACL)** — atua como firewall stateless em nível de subnet inteira. Permite definir regras de allow/deny pra tráfego de entrada (inbound) e saída (outbound), por número de regra (avaliado em ordem). Como é stateless, precisa criar regras nos dois sentidos (entrada E saída) pra cada fluxo.

> **Diferenciação útil:** **Security Group** também inspeciona tráfego, MAS em nível de instância (ENI), é stateful (resposta automática permitida), e só permite regras de allow. NACL é em nível de subnet, stateless, e permite allow e deny.

---

## Questão 4 — Instâncias EC2

### a) Termo da imagem do SO

**AMI — Amazon Machine Image**.

A AMI é um template que contém o sistema operacional, aplicações pré-instaladas, configurações, mapeamento de volumes EBS, etc. Pode ser:
- **AMI pública da AWS** (Amazon Linux 2023, Ubuntu, Windows Server, etc)
- **AMI do Marketplace** (vendedores terceirizados)
- **AMI customizada** (criada pelo próprio usuário a partir de uma instância existente)

### b) Comando SSH pra conectar via WSL

```bash
chmod 400 minha_chave.pem
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

Detalhes:
- `chmod 400`: o SSH **exige** que a chave privada tenha permissão restrita (somente leitura pelo dono). Sem isso, o SSH recusa com erro `Permissions are too open`.
- `-i minha_chave.pem`: aponta para o arquivo da chave privada (a contraparte da pública que está em `~/.ssh/authorized_keys` na instância).
- `ec2-user@`: usuário padrão do **Amazon Linux**. Para Ubuntu seria `ubuntu@`, para Debian `admin@` ou `debian@`.
- `54.123.45.67`: IP público (ou DNS público `ec2-54-123-45-67.compute-1.amazonaws.com`) da instância.

---

## Questão 5 — Comandos AWS CLI

### 1. Configurar credenciais e região

```bash
aws configure
```

Solicita interativamente:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (ex: `sa-east-1`)
- Default output format (ex: `json`)

As credenciais são salvas em `~/.aws/credentials` e a configuração em `~/.aws/config`.

### 2. Listar instâncias EC2 na região configurada

```bash
aws ec2 describe-instances
```

Para uma saída mais legível, pode formatar:

```bash
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

### 3. Criar um bucket S3 chamado `meu-bucket-tf10` na região `sa-east-1`

```bash
aws s3 mb s3://meu-bucket-tf10 --region sa-east-1
```

Alternativamente, usando o subcomando `s3api`:

```bash
aws s3api create-bucket \
  --bucket meu-bucket-tf10 \
  --region sa-east-1 \
  --create-bucket-configuration LocationConstraint=sa-east-1
```

> Importante: para qualquer região fora de `us-east-1`, o parâmetro `LocationConstraint` é obrigatório no `s3api create-bucket`.

### 4. Descrever VPCs da região configurada

```bash
aws ec2 describe-vpcs
```

Saída resumida útil:

```bash
aws ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,CidrBlock,State,IsDefault]' \
  --output table
```

---

## Questão 6 — Evidências Práticas

Todos os comandos foram executados no ambiente **WSL (Ubuntu)** com **LocalStack** como simulador da AWS, conforme orientação do Lab010.md. Os prints estão na pasta [`prints/`](./prints/) deste diretório.

### Parte 1 — Configuração

#### 1. Instalação da AWS CLI

**Comando:** `aws --version`
**Print:** [`prints/01-aws-version.png`](./prints/01-aws-version.png)

Versão instalada: `aws-cli/2.x.x Python/3.x Linux/x.x`

Comando usado pra instalar:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### 2. Configuração de Credenciais AWS

**Comando:** `aws configure list`
**Print:** [`prints/02-aws-configure-list.png`](./prints/02-aws-configure-list.png)

Credenciais de teste foram configuradas pra apontar para o LocalStack (`access_key=test`, `secret_key=test`, `region=us-east-1`).

#### 3. Instalação do LocalStack via Docker

**Comando:** `docker run -d --name localstack -p 4566:4566 localstack/localstack`
**Print:** [`prints/03-docker-run-localstack.png`](./prints/03-docker-run-localstack.png)

Confirmação de saúde:

```bash
curl -s http://localhost:4566/_localstack/health
```

**Print:** [`prints/04-localstack-health.png`](./prints/04-localstack-health.png)

Retorno esperado: `{"services": {...}, "version": "..."}` mostrando todos os serviços `"available"` ou `"running"`.

#### 4. Teste de Conectividade LocalStack

**Comando:** `aws --endpoint-url=http://localhost:4566 s3 ls`
**Print:** [`prints/05-localstack-s3-ls.png`](./prints/05-localstack-s3-ls.png)

Saída vazia confirma conectividade (nenhum bucket ainda).

### Parte 2 — Criação de Recursos

#### 1. Criar Bucket S3 com nome TF010-3225002

**Comando:**

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf010-3225002
```

**Print:** [`prints/06-criar-bucket-s3.png`](./prints/06-criar-bucket-s3.png)

Saída esperada: `make_bucket: tf010-3225002`

Listagem confirmando:

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

**Print:** [`prints/07-listar-bucket.png`](./prints/07-listar-bucket.png)

#### 2. Criar Instância EC2 com tag TF010-3225002

**Comando:**

```bash
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=TF010-3225002}]'
```

**Print:** [`prints/08-run-instances.png`](./prints/08-run-instances.png)

Verificação da instância criada:

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags]' \
  --output table
```

**Print:** [`prints/09-describe-instances.png`](./prints/09-describe-instances.png)

---

## Observações sobre Ferramentas e Comandos

- **WSL (Windows Subsystem for Linux)** foi essencial pra rodar os comandos `aws` e `docker` em um shell Linux nativo, evitando incompatibilidades do PowerShell/cmd.
- **LocalStack** simula localmente a maioria dos serviços AWS, permitindo praticar sem custo (em uma conta real, criar EC2 e bucket S3 podem gerar pequena cobrança ou consumir crédito Free Tier).
- O parâmetro **`--endpoint-url=http://localhost:4566`** redireciona qualquer comando AWS CLI pro LocalStack ao invés da AWS real — útil pra testes.
- Em uma conta AWS real, basta omitir `--endpoint-url` e os comandos vão pro endpoint oficial.

---

## Estrutura de Arquivos

```
Aula 010/3225002/
├── README.md          ← este arquivo (respostas)
└── prints/            ← evidências práticas da Questão 6
    ├── 01-aws-version.png
    ├── 02-aws-configure-list.png
    ├── 03-docker-run-localstack.png
    ├── 04-localstack-health.png
    ├── 05-localstack-s3-ls.png
    ├── 06-criar-bucket-s3.png
    ├── 07-listar-bucket.png
    ├── 08-run-instances.png
    └── 09-describe-instances.png
```
