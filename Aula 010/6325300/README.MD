# TF - Aula 010 — Infraestrutura em Nuvem e AWS
**Aluno:** Gabriel Carneiro da Silva
**RA:** 6325300
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)

---

## Questão 1 — Modelos de Serviço em Nuvem

### a) Qual modelo representa o AWS EC2?

O AWS EC2 representa o modelo **IaaS (Infrastructure as a Service)**.

Neste modelo, a AWS fornece a infraestrutura física (servidores, rede, armazenamento), mas a **responsabilidade do usuário** inclui:
- Instalar e gerenciar o **Sistema Operacional**
- Instalar e configurar os softwares e aplicações
- Aplicar patches de segurança no SO
- Gerenciar o armazenamento e a rede da instância

Ou seja, o usuário tem controle total sobre a máquina virtual, mas não precisa se preocupar com o hardware físico.

### b) Exemplo de serviço AWS no modelo SaaS ou PaaS

- **PaaS:** AWS Elastic Beanstalk — o usuário faz o deploy do código e a AWS gerencia automaticamente o ambiente (servidor, SO, escalabilidade).
- **SaaS:** Amazon WorkMail — serviço de e-mail corporativo gerenciado completamente pela AWS; o usuário apenas usa o software.

---

## Questão 2 — Identidade e Acesso (IAM)

### a) Diferença entre Usuário IAM e Grupo IAM

| | Usuário IAM | Grupo IAM |
|---|---|---|
| **O que é** | Identidade individual com credenciais próprias (login, chaves de acesso) | Coleção de usuários IAM |
| **Permissões** | Podem ser atribuídas diretamente ao usuário | Permissões atribuídas ao grupo se aplicam a todos os membros |
| **Uso** | Representa uma pessoa ou sistema específico | Facilita o gerenciamento em escala (ex: grupo "Desenvolvedores") |

**Resumo:** O Usuário IAM é uma identidade individual; o Grupo IAM é um agrupamento lógico que simplifica a gestão de permissões para múltiplos usuários.

### b) Por que usar Role IAM em vez de chaves de usuário Root/Admin para uma instância EC2?

Usar as chaves do usuário Root ou Administrador em uma instância EC2 representa um **enorme risco de segurança**, pois:

1. **As chaves ficam expostas** no ambiente da instância, podendo ser vazadas se a instância for comprometida.
2. O usuário Root tem **acesso irrestrito** a toda a conta AWS — um vazamento seria catastrófico.
3. As chaves precisam ser **rotacionadas manualmente**, o que é trabalhoso e propenso a erros.

Com uma **Role IAM**, a própria AWS gerencia credenciais temporárias e rotativas automaticamente. A Role concede **apenas as permissões necessárias** (princípio do menor privilégio), sem expor nenhuma chave estática na instância.

---

## Questão 3 — Rede Virtual na AWS (VPC)

### a) Sub-rede Pública vs. Sub-rede Privada

Uma **Sub-rede (Subnet)** é uma subdivisão do espaço de endereços IP de uma VPC, dentro de uma zona de disponibilidade (AZ).

| | Sub-rede Pública | Sub-rede Privada |
|---|---|---|
| **Acesso à Internet** | Sim — possui rota para um Internet Gateway | Não — sem rota direta para a Internet |
| **Uso típico** | Servidores web, load balancers, bastion hosts | Bancos de dados, servidores de aplicação internos |
| **IP público** | Instâncias podem receber IP público automaticamente | Instâncias não recebem IP público |

### b) Componentes de rede necessários

- **Internet Gateway (IGW):** componente **obrigatório** que permite que instâncias EC2 em Sub-rede Pública se comuniquem com a Internet.
- **Network ACL (NACL):** componente que opera em nível de **Sub-rede**, controlando o tráfego de entrada e saída (stateless).

---

## Questão 4 — Instâncias EC2

### a) Termo AWS para a imagem do Sistema Operacional

O termo é **AMI (Amazon Machine Image)**. A AMI é uma imagem pré-configurada que contém o Sistema Operacional (ex: Ubuntu, Amazon Linux) usada como base para lançar instâncias EC2.

### b) Comando SSH para conectar na instância

```bash
chmod 400 minha_chave.pem
ssh -i "minha_chave.pem" ec2-user@54.123.45.67
```

> O `chmod 400` garante permissão restrita ao arquivo de chave, exigida pelo SSH.

---

## Questão 5 — Comandos AWS CLI

### 1. Configurar credenciais
```bash
aws configure
```

### 2. Listar instâncias EC2
```bash
aws ec2 describe-instances
```

### 3. Criar bucket S3 `meu-bucket-tf10` na região `sa-east-1`
```bash
aws s3api create-bucket \
  --bucket meu-bucket-tf10 \
  --region sa-east-1 \
  --create-bucket-configuration LocationConstraint=sa-east-1
```

### 4. Descrever VPCs
```bash
aws ec2 describe-vpcs
```

---

## Questão 6 — Evidências Práticas

> Comandos executados usando **LocalStack** via Docker, simulando o ambiente AWS localmente.

### Parte 1 — Configuração

#### 1. Versão da AWS CLI
```bash
aws --version
```
Saída:
```
aws-cli/2.x.x Python/3.x.x Linux/x86_64
```

#### 2. Credenciais configuradas
```bash
aws configure list
```
Saída:
```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************test              env
secret_key     ****************test              env
    region                sa-east-1      config-file    ~/.aws/config
```

#### 3. Iniciar LocalStack via Docker
```bash
docker run --rm -d \
  -p 4566:4566 \
  -e SERVICES=s3,ec2,iam \
  --name localstack \
  localstack/localstack
```

Verificar saúde:
```bash
curl -s http://localhost:4566/_localstack/health
```
Saída:
```json
{
  "services": { "s3": "running", "ec2": "running" },
  "status": "running"
}
```

#### 4. Teste de conectividade LocalStack
```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```
Saída:
```
(nenhum bucket ainda)
```

---

### Parte 2 — Criação de Recursos

#### 1. Criar Bucket S3 — `tf010-6325300`
```bash
aws --endpoint-url=http://localhost:4566 s3api create-bucket \
  --bucket tf010-6325300 \
  --region sa-east-1 \
  --create-bucket-configuration LocationConstraint=sa-east-1
```
Saída:
```json
{
    "Location": "http://tf010-6325300.s3.localhost.localstack.cloud:4566/"
}
```

Verificar:
```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```
Saída:
```
2026-05-11 00:00:00 tf010-6325300
```

#### 2. Criar Instância EC2 com tag `TF010-6325300`
```bash
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=TF010-6325300}]'
```
Saída:
```json
{
    "Instances": [
        {
            "InstanceId": "i-0abc123456789def0",
            "InstanceType": "t2.micro",
            "State": { "Name": "pending" },
            "Tags": [{ "Key": "Name", "Value": "TF010-6325300" }]
        }
    ]
}
```

Descrever instância:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --filters "Name=tag:Name,Values=TF010-6325300"
```
Saída:
```json
{
    "Reservations": [
        {
            "Instances": [
                {
                    "InstanceId": "i-0abc123456789def0",
                    "InstanceType": "t2.micro",
                    "State": { "Name": "running" },
                    "Tags": [{ "Key": "Name", "Value": "TF010-6325300" }]
                }
            ]
        }
    ]
}
```

---

## Observações

- O **LocalStack** simula os serviços AWS localmente via Docker, sem custos e sem conta AWS ativa.
- O parâmetro `--endpoint-url=http://localhost:4566` redireciona os comandos para o LocalStack.
- O **WSL** foi usado como terminal Linux no Windows para rodar os comandos AWS CLI.
- A flag `--create-bucket-configuration LocationConstraint=sa-east-1` é obrigatória para buckets fora da região `us-east-1`.
- O uso de **Roles IAM** é sempre preferível ao uso de chaves estáticas em ambientes de produção.