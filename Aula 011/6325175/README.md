Questão 1: Armazenamento de Objetos (S3) (Teórica)
O Amazon S3 (Simple Storage Service) é um serviço fundamental na AWS.
a) Qual é o principal caso de uso para o S3 em um contexto de aplicação Web e DevOps? (Ex: Hospedagem de sistema operacional, Logins, etc.).
R:O Amazon S3 é usado para armazenar arquivos como imagens, vídeos, documentos, backups e logs de aplicações.

b) O S3 é um serviço global ou regional? Qual característica do S3 (durabilidade ou disponibilidade) é expressa pela taxa "Onze Noves" (99.999999999%)?
R:O S3 é um serviço regional. A taxa de 99,999999999% refere-se à durabilidade dos dados.

Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS) (Teórica)
Existem diferentes tipos de armazenamento para diferentes necessidades de I/O (Entrada/Saída).
a) Qual é a diferença fundamental entre o Amazon EBS (Elastic Block Store) e o Amazon EFS (Elastic File System) em termos de conexão e uso por instâncias EC2?
R:
- EBS: armazenamento em blocos, geralmente usado por uma única instância EC2.
- EFS: armazenamento em arquivos, pode ser compartilhado por várias instâncias EC2.

b) No contexto de um servidor de aplicação rodando em EC2, quais esses dois serviços (EBS ou EFS) é o mais adequado para armazenar o Sistema Operacional e o apresentadovel da aplicação ?
R:O EBS é o mais indicado para armazenar o sistema operacional e os arquivos da aplicação.

Questão 3: Banco de Dados Gerenciado (RDS) (Teórica)
O RDS (Relational Database Service) é o serviço de banco de dados relacional gerenciado pela AWS.
a) Cite duas responsabilidades de gerenciamento de banco de dados que a AWS assume ao usar o RDS (liberando o DevOps dessa tarefa). 
R:A AWS cuida de Backups automáticos, Atualizações e patches de segurança.

b) Qual é a principal desvantagem ou restrição de uso do RDS em comparação com a instalação e gerenciamento de um banco de dados (ex: MySQL) diretamente em uma instância EC2?
R:A principal desvantagem é ter menos controle e personalização do que um banco instalado diretamente em uma EC2.

Questão 4: Alta Disponibilidade no RDS (Teórica)
Para garantir a Alta Disponibilidade no RDS, a AWS oferece a opção Multi-AZ (Multi-Availability Zone) .
a) Descreva o que acontece quando você habilita o Multi-AZ para um banco de dados RDS (onde os dados são replicados). 
R:O Multi-AZ cria uma cópia do banco em outra Zona de Disponibilidade e mantém os dados sincronizados.

b) Qual a diferença entre um Standby no Multi-AZ e uma Read Replica no RDS em termos de uso e failover?
R:Standby (Multi-AZ): alta disponibilidade e failover automático.
Read Replica: melhora leituras, sem failover automático.

Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI)
Descreva o fluxo de trabalho para fazer o upload de um arquivo de configuração de banco de dados ( db_config.conf) do seu ambiente WSL/Linux para um bucket S3.

Descrição do Fluxo:
Descreva as três etapas fáceis para realizar esta operação, citando o comando/ferramenta utilizado em cada fase:

Criação do Arquivo: Qual comando Linux você usaria para criar um arquivo de teste chamado db_config.confno seu terminal WSL?
R:touch db_config.conf

Upload (Sintaxe CLI):Qual comando aws s3 você usaria para copiar o arquivo db_config.confpara um bucket chamado config-app-tf11?
R:aws s3 cp db_config.conf s3://config-app-tf11/

Verificação: Qual comando aws s3 você usaria para listar o conteúdo do balde e confirmar que o arquivo foi carregado com sucesso?
R:aws s3 ls s3://config-app-tf11/

