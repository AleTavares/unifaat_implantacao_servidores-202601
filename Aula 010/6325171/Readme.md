# TF Aula 10 - Cloud AWS (LocalStack)

## Aluno
RA: 6325171
Nome: Nicolas de Jesus Silva

---

## ⚠️ Observação

O ambiente AWS real não foi utilizado por ausência de credenciais (Access Key e Secret Key).  
Foi utilizada a ferramenta LocalStack para simulação dos serviços AWS conforme permitido no laboratório.

---

## 📌 Respostas Teóricas

### 1. Modelos de Cloud
- EC2 = IaaS
- Responsabilidade: gerenciar sistema operacional, aplicações e segurança

Exemplos:
- SaaS: Gmail
- PaaS: AWS Elastic Beanstalk

---

### 2. IAM
- Usuário IAM = identidade individual
- Grupo IAM = conjunto de usuários
- Role IAM = permissões temporárias (melhor prática para EC2)

---

### 3. VPC
- Subnet = subdivisão da rede
- Subnet pública = acesso à internet
- Subnet privada = sem acesso direto

Componentes:
- Internet Gateway = acesso à internet
- Security Group = firewall da instância

---

### 4. EC2
- AMI = imagem do sistema operacional

SSH:
ssh -i chave.pem ec2-user@IP

---

### 5. AWS CLI comandos
1. aws configure
2. aws ec2 describe-instances
3. aws s3 mb s3://meu-bucket-tf10
4. aws ec2 describe-vpcs

---

## 📌 Conclusão
O laboratório foi realizado com sucesso utilizando LocalStack para simulação dos serviços AWS.