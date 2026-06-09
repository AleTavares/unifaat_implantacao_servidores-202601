# Respostas sobre Armazenamento e Banco de Dados na AWS

## Questão 1: Armazenamento de Objetos (S3)

a) Qual é o principal caso de uso para o S3 em um contexto de aplicação Web e DevOps? (Ex: Hospedagem de sistema operacional, Logins, etc.). 
* Principal caso de uso: Armazenamento de objetos como imagens, backups e logs.
b) O S3 é um serviço global ou regional? Qual característica do S3 (durabilidade ou disponibilidade) é expressa pela taxa "Onze Noves" (99.999999999%)?
* O S3 é regional. A durabilidade é expressa pela taxa "Onze Noves" (99.999999999%).

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

a) Qual é a diferença fundamental entre o **Amazon EBS (Elastic Block Store)** e o **Amazon EFS (Elastic File System)** em termos de conexão e uso por instâncias EC2?
* EBS conecta-se a uma única instância EC2; EFS é compartilhado entre várias instâncias.
b) No contexto de um servidor de aplicação rodando em EC2, qual desses dois serviços (EBS ou EFS) é o mais adequado para armazenar o **Sistema Operacional** e o **executável da aplicação**?
* EBS é mais adequado para armazenar o sistema operacional e executáveis da aplicação.

## Questão 3: Banco de Dados Gerenciado (RDS)

a) Cite **duas** responsabilidades de gerenciamento de banco de dados que a AWS assume ao usar o RDS (liberando o DevOps dessa tarefa).
* Atualizações automáticas e backups são responsabilidades da AWS no RDS.
b) Qual é a principal desvantagem ou limitação de usar o RDS em comparação com a instalação e gerenciamento de um banco de dados (ex: MySQL) diretamente em uma instância EC2?
* Limitação: Menor controle sobre a configuração e otimização do banco de dados.

## Questão 4: Alta Disponibilidade no RDS

a) Descreva o que acontece quando você habilita o Multi-AZ para um banco de dados RDS (onde os dados são replicados).
* Multi-AZ replica dados em uma zona secundária para failover automático.
b) Qual a diferença entre um *Standby* no Multi-AZ e uma *Read Replica* no RDS em termos de uso e failover?
* Standby é usado para failover; Read Replica é usada para leitura e não suporta failover automático.