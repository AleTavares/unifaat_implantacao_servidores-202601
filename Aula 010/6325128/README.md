# TF010 - RA 6325128

## Aluno
- RA: 6325128
- Aula: 10
- Disciplina: Implementação de servidor e nuvem (cloud)

## Questão 1: Modelos de Serviço em Nuvem

1a) AWS EC2 representa **IaaS** (Infrastructure as a Service).
- O usuário é responsável por gerenciar o sistema operacional, o software instalado, a configuração da aplicação, atualizações e segurança no nível da máquina virtual.
- A AWS gerencia a infraestrutura física, a virtualização, o armazenamento e a rede subjacente.

1b) Exemplo de serviço **PaaS**: **AWS Elastic Beanstalk**.
- O Elastic Beanstalk fornece a plataforma para executar aplicações, reduzindo a necessidade de gerenciar diretamente o servidor e o middleware.

## Questão 2: Identidade e Acesso (IAM)

2a) Diferença entre Usuário IAM e Grupo IAM:
- **Usuário IAM**: identidade individual com credenciais (senha, chaves de acesso) usada por uma pessoa ou serviço.
- **Grupo IAM**: coleção de usuários que herdam políticas e permissões em conjunto, facilitando a administração.

2b) Por que usar Role IAM em vez de chaves Root/Admin para EC2 acessar S3:
- Roles fornecem credenciais temporárias e distribuídas automaticamente para a instância.
- Evitam o uso de chaves permanentes de root ou administrador, que são inseguras e aumentam o risco de vazamento.
- Roles permitem aplicar o princípio do menor privilégio com mais segurança.

## Questão 3: Rede Virtual na AWS (VPC)

3a) Subnet dentro de uma VPC:
- Uma **subnet** é uma faixa de endereços IP dentro de uma única zona de disponibilidade (AZ) da VPC.
- **Subnet Pública**: tem rota para o Internet Gateway e normalmente permite endereços IP públicos nas instâncias.
- **Subnet Privada**: não tem rota direta para Internet Gateway e é usada para recursos que não devem ser acessíveis diretamente pela internet.

3b) Componentes de rede:
- Componente obrigatório para internet em subnet pública: **Internet Gateway (IGW)**.
- Componente usado para inspecionar tráfego em nível de subnet: **Network ACL (NACL)**.

## Questão 4: Instâncias EC2

4a) O termo AWS para a imagem pré-configurada do sistema operacional é **AMI** (Amazon Machine Image).

4b) Comando SSH no terminal WSL:
```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67
```

## Questão 5: Comandos AWS CLI

1. Configurar credenciais e região:
```bash
aws configure
```

2. Listar instâncias EC2 na região configurada:
```bash
aws ec2 describe-instances
```

3. Criar um bucket S3 na região sa-east-1:
```bash
aws s3 mb s3://meu-bucket-tf10 --region sa-east-1
```

4. Descrever VPCs na região configurada:
```bash
aws ec2 describe-vpcs
```

## Questão 6: Evidências Práticas de Configuração e Criação de Recursos

### Parte 1: Evidências de Configuração

1. **Instalação AWS CLI**
```bash
aws --version
# aws-cli/2.34.45 Python/3.14.4 Linux/6.6.87.2-microsoft-standard-WSL2 exe/x86_64.ubuntu.24
```

![AWS CLI version](aws_version.svg)

2. **Configuração de credenciais AWS**
```bash
aws configure list
# profile    : <not set>                : None             : None
# access_key : <not set>                : None             : None
# secret_key : <not set>                : None             : None
# region     : <not set>                : None             : None
```

![AWS configure list](aws_configure_list.svg)

3. **LocalStack via Docker**
- Verifiquei que o LocalStack já estava disponível em `http://localhost:4566`.
- Health check:
```bash
curl -s http://localhost:4566/_localstack/health
```
- Resultado:
```json
{"features":{"initScripts":"initialized"},"services":{"s3":"available","ec2":"available", ...},"version":"0.14.3.1"}
```

![LocalStack health](localstack_health.svg)

4. **Teste de conectividade LocalStack**
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 aws --endpoint-url=http://localhost:4566 s3 ls
```
- Saída: nenhum bucket listado, conectividade OK.

![LocalStack S3 ls](s3_ls.svg)

### Parte 2: Exercício de Criação de Recursos

1. **Criar bucket S3 TF010**
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=sa-east-1 aws --endpoint-url=http://localhost:4566 s3 mb s3://tf010-6325128 --region sa-east-1
```
- Saída:
```text
make_bucket: tf010-6325128
```

![Bucket create](bucket_create.svg)

2. **Criar instância EC2 com tag TF010-6325128**
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 aws --endpoint-url=http://localhost:4566 ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type t2.micro \
  --count 1 \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=TF010-6325128}]"
```
- Saída parcial com `InstanceId` e tag:
```json
{
  "Instances": [
    {
      "InstanceId": "i-8bd7acf8f36c109e7",
      "ImageId": "ami-12345678",
      "InstanceType": "t2.micro",
      "State": {"Name": "pending"},
      "Tags": [{"Key": "Name", "Value": "TF010-6325128"}]
    }
  ]
}
```

![EC2 run](ec2_run.svg)

3. **Descrever instâncias EC2**
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```
- Saída parcial:
```json
{
  "Reservations": [
    {
      "Instances": [
        {
          "InstanceId": "i-8bd7acf8f36c109e7",
          "State": {"Name": "running"},
          "Tags": [{"Key": "Name", "Value": "TF010-6325128"}],
          "PublicIpAddress": "54.214.129.2"
        }
      ]
    }
  ]
}
```

![EC2 describe](ec2_describe.svg)

4. **Descrever VPCs**
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
```
- Saída parcial:
```json
{
  "Vpcs": [
    {
      "VpcId": "vpc-b1222c5c",
      "CidrBlock": "172.31.0.0/16",
      "IsDefault": true,
      "State": "available"
    }
  ]
}
```

![VPC describe](vpcs_describe.svg)

## Observações
- Usei o ambiente **WSL/Linux** e o serviço **LocalStack** para simular AWS localmente.
- Como o AWS CLI não tinha credenciais reais configuradas, utilizei variáveis de ambiente dummy (`AWS_ACCESS_KEY_ID=test` e `AWS_SECRET_ACCESS_KEY=test`) para conectar ao LocalStack.
- Todos os comandos de criação e descrição de recursos foram executados com `--endpoint-url=http://localhost:4566`.
- Se fosse usar AWS real, bastaria remover `--endpoint-url` e configurar as credenciais com `aws configure`.
