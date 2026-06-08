# TF010 — Respostas (Questões 1 a 5)

## Questão 1: Modelos de Serviço em Nuvem (Teórica)

**a)** O **Amazon EC2** representa o modelo **IaaS** (*Infrastructure as a Service*). A AWS provê a infraestrutura de computação (virtualização, hardware, rede na camada de hipervisor/datacenter). A **principal responsabilidade do usuário** é gerenciar o que fica acima do hipervisor: **sistema operacional** (instalação, patches, hardening), **aplicações**, **middleware**, **dados** e a configuração de rede/regras de acesso dentro da instância — não basta “apenas usar o software” como em SaaS.

**b)** Exemplos na AWS:
- **SaaS:** **Amazon WorkMail**, **Amazon Chime** ou **Amazon Connect** (software pronto, acesso via assinatura/uso, sem gerenciar SO ou plataforma).
- **PaaS:** **AWS Elastic Beanstalk** ou **AWS App Runner** (a AWS gerencia grande parte da plataforma de execução; o foco é implantar código).

---

## Questão 2: Identidade e Acesso (IAM) (Teórica)

**a)** Um **usuário IAM** é uma **identidade** (pessoa ou aplicação) que pode receber credenciais de longo prazo (por exemplo, chaves de acesso) e políticas anexadas diretamente. Um **grupo IAM** é um **contêiner lógico de usuários**; não é uma identidade de login por si só. As permissões são normalmente anexadas ao **grupo**, e os **usuários** são associados ao grupo para **herdar** as mesmas permissões, facilitando o gerenciamento em escala.

**b)** **Roles IAM** fornecem **credenciais temporárias** assumidas pela instância (via **instance profile**), sem armazenar chaves de acesso de longa duração no disco. Usar chaves de **Root** ou de um **administrador** na EC2 viola o princípio do **menor privilégio** e amplifica o impacto de vazamento ou comprometimento da instância (acesso amplo à conta). Com **Role**, a permissão é **escopada** ao que a aplicação precisa (por exemplo, apenas leitura em um bucket S3 específico) e as credenciais são **rotacionadas automaticamente** pela AWS.

---

## Questão 3: Rede Virtual na AWS (VPC) (Teórica)

**a)** Uma **subnet** é uma subdivisão do bloco CIDR da **VPC**, associada a uma **Zona de Disponibilidade (AZ)**, onde se colocam interfaces de rede e recursos como EC2. A diferença crucial: em uma **subnet pública**, a **tabela de rotas** direciona tráfego destinado à Internet (ex.: `0.0.0.0/0`) para um **Internet Gateway (IGW)**. Em uma **subnet privada**, **não** há essa rota direta para a Internet; o tráfego de saída, quando necessário, costuma passar por **NAT Gateway** em subnet pública, mantendo as instâncias **sem IP público roteável** para entrada direta da Internet.

**b)** Para a EC2 em subnet pública acessar a Internet de forma bidirecional (com IP público ou via rota adequada), é obrigatório um **Internet Gateway (IGW)** acoplado à VPC e **rotas** na subnet que encaminhem o tráfego para o IGW. Para inspecionar/controlar tráfego de entrada e saída **no nível da subnet**, usa-se a **Network ACL (NACL)** — lista de controle de acesso stateless aplicada à subnet.

---

## Questão 4: Instâncias EC2 (Prática Teórica)

**a)** O termo da AWS é **AMI** (*Amazon Machine Image*).

**b)** No terminal WSL (com a chave no caminho correto e permissões restritas ao arquivo `.pem`):

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

*(Se a AMI for Ubuntu, o usuário padrão costuma ser `ubuntu`; o enunciado indica `ec2-user@54.123.45.67`, portanto o comando acima segue esse pressuposto.)*

---

## Questão 5: Comandos AWS CLI (Prática)

**1. Configurar credenciais e região no ambiente local**

```bash
aws configure
```

*(Solicita Access Key ID, Secret Access Key, região padrão e formato de saída; grava em `~/.aws/credentials` e `~/.aws/config`.)*

**2. Listar todas as instâncias EC2 na região configurada**

```bash
aws ec2 describe-instances
```

**3. Criar o bucket S3 `meu-bucket-tf10` na região `sa-east-1`**

Fora de `us-east-1`, é necessário informar `LocationConstraint`:

```bash
aws s3api create-bucket --bucket meu-bucket-tf10 --region sa-east-1 --create-bucket-configuration LocationConstraint=sa-east-1
```

*(Alternativa de alto nível: `aws s3 mb s3://meu-bucket-tf10 --region sa-east-1`.)*

**4. Descrever as VPCs existentes na região configurada**

```bash
aws ec2 describe-vpcs
```
