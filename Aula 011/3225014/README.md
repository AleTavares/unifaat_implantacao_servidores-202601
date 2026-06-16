## Questao 01 ##
O Amazon S3 (Simple Storage Service) é um serviço fundamental na AWS.

a) Qual é o principal caso de uso para o S3 em um contexto de aplicação Web e DevOps? (Ex: Hospedagem de sistema operacional, Logins, etc.). 
R: O principal caso de uso do Amazon S3 é o armazenamento escalável e durável de arquivos (objetos), sendo amplamente utilizado para armazenar conteúdo estático de aplicações web, backups, logs e arquivos enviados pelos usuários.

b) O S3 é um serviço global ou regional? Qual característica do S3 (durabilidade ou disponibilidade) é expressa pela taxa "Onze Noves" (99.999999999%)?
R: O Amazon S3 é um serviço regional. Essa porcentagem refere-se à durabilidade dos dados.

## Questão 2 ##
Existem diferentes tipos de armazenamento para diferentes necessidades de I/O (Input/Output).

a) Qual é a diferença fundamental entre o **Amazon EBS (Elastic Block Store)** e o **Amazon EFS (Elastic File System)** em termos de conexão e uso por instâncias EC2?
R: A diferença fundamental entre o Amazon EBS (Elastic Block Store) e o Amazon EFS (Elastic File System) está na forma como o armazenamento é conectado e compartilhado entre instâncias EC2.

b) No contexto de um servidor de aplicação rodando em EC2, qual desses dois serviços (EBS ou EFS) é o mais adequado para armazenar o **Sistema Operacional** e o **executável da aplicação**?
R: No contexto de um servidor de aplicação rodando em uma instância EC2, o serviço mais adequado para armazenar o Sistema Operacional e o executável da aplicação é o Amazon EBS.

## Questão 3 ##
O RDS (Relational Database Service) é o serviço de banco de dados relacional gerenciado pela AWS.

a) Cite **duas** responsabilidades de gerenciamento de banco de dados que a AWS assume ao usar o RDS (liberando o DevOps dessa tarefa).
R: Ao utilizar o Amazon RDS (Relational Database Service), a AWS assume diversas tarefas administrativas do banco de dados, reduzindo o trabalho da equipe de DevOps.

b) Qual é a principal desvantagem ou limitação de usar o RDS em comparação com a instalação e gerenciamento de um banco de dados (ex: MySQL) diretamente em uma instância EC2?
R: A principal desvantagem do Amazon RDS em comparação com um banco de dados instalado diretamente em uma instância EC2 é a menor flexibilidade e controle sobre o ambiente.
R: A principal desvantagem do Amazon RDS em comparação com um banco de dados instalado diretamente em uma instância EC2 é a menor flexibilidade e controle sobre o ambiente.


## Questão 4 ##
Para garantir a Alta Disponibilidade no RDS, a AWS oferece a opção **Multi-AZ (Multi-Availability Zone)**.

a) Descreva o que acontece quando você habilita o Multi-AZ para um banco de dados RDS (onde os dados são replicados).
R: Quando o Multi-AZ é habilitado em um banco de dados Amazon RDS, a AWS cria automaticamente uma instância de banco de dados secundária (standby) em uma Availability Zone (AZ) diferente, dentro da mesma região.

b) Qual a diferença entre um *Standby* no Multi-AZ e uma *Read Replica* no RDS em termos de uso e failover?
R: A principal diferença entre um Standby (Multi-AZ) e uma Read Replica está no objetivo e no comportamento em caso de falha.

## Questão 5 ##
Descreva o fluxo de trabalho para fazer o *upload* de um arquivo de configuração de banco de dados (`db_config.conf`) do seu ambiente **WSL/Linux** para um *bucket* S3.
R: 
- Instalar e configurar a AWS CLI no ambiente WSL/Linux.
- Verificar se o arquivo existe no diretório desejado.:
    ls -l db_config.conf
- Executar o comando de upload para o S3.
    aws s3 cp db_config.conf s3://meu-bucket/db_config.conf
- Confirmar que o arquivo foi enviado listando o conteúdo do bucket.
    aws s3 ls s3://meu-bucket/
- Para realizar o upload ao bucket S3. Após o envio, é possível verificar o sucesso da operação com:
    aws s3 ls s3://meu-bucket/

    ### Descrição do Fluxo: ###

    Descreva as **três etapas** necessárias para realizar esta operação, citando o comando/ferramenta utilizada em cada fase:

    1.  **Criação do Arquivo:** Qual comando Linux você usaria para criar um arquivo de teste chamado `db_config.conf` no seu terminal WSL?
    R: touch db_config.conf

    2.  **Upload (Sintaxe CLI):** Qual comando `aws s3` você usaria para copiar o arquivo `db_config.conf` para um *bucket* chamado `config-app-tf11`?
    R:aws s3 cp db_config.conf s3://config-app-tf11/

    3.  **Verificação:** Qual comando `aws s3` você usaria para listar o conteúdo do *bucket* e confirmar que o arquivo foi carregado com sucesso?
    R: aws s3 ls s3://config-app-tf11/  

