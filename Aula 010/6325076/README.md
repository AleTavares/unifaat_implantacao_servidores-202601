
# TF - Final - Sala 10

## Disciplina: Implementação de servidor e nuvem (cloud)

---

# Questão 1 – Modelos de Serviço em Nuvem

## a)
O serviço AWS EC2 pertence ao modelo IaaS (Infrastructure as a Service).

Nesse modelo, a AWS fornece a infraestrutura, enquanto o usuário é responsável por:

- Gerenciar o sistema operacional;
- Instalar aplicações;
- Configurar segurança;
- Administrar os serviços utilizados.

## b)
Exemplo de serviço PaaS:
- AWS Elastic Beanstalk

Exemplo de serviço SaaS:
- Gmail
- Microsoft 365

---

# Questão 2 – IAM

## a)
Diferença entre Usuário IAM e Grupo IAM:

- Usuário IAM: representa uma pessoa ou aplicação com credenciais próprias.
- Grupo IAM: conjunto de usuários que compartilham permissões em comum.

## b)
Criar uma Role IAM é mais seguro porque evita o uso de credenciais permanentes do usuário Root ou Administrador.

As Roles fornecem permissões temporárias e seguem o princípio do menor privilégio, aumentando a segurança da infraestrutura.

---

# Questão 3 – VPC

## a)
Uma Sub-rede é uma divisão lógica dentro de uma VPC.

Diferença:

- Sub-rede Pública: possui acesso à Internet.
- Sub-rede Privada: não possui acesso direto à Internet.

## b)
Componentes:

- Internet Gateway (IGW): permite acesso à Internet.
- Network ACL (NACL): controla tráfego de entrada e saída em nível de sub-rede.

---

# Questão 4 – EC2

## a)
O nome da imagem de sistema operacional utilizada no EC2 é AMI (Amazon Machine Image).

## b)
Comando para conexão SSH:

```bash
ssh -i minha_chave.pem ec2-user@54.123.45.67