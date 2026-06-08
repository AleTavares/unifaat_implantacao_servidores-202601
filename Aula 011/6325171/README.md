Questão 1

a) O Amazon S3 é utilizado para armazenamento de objetos, como arquivos estáticos de aplicações web, imagens, vídeos, backups e logs.

b) O S3 é um serviço regional. A taxa de 99.999999999% (onze noves) representa a durabilidade dos dados.

Questão 2

a) O Amazon EBS fornece armazenamento em blocos para uma instância EC2 específica. O Amazon EFS fornece um sistema de arquivos compartilhado que pode ser acessado simultaneamente por várias instâncias EC2.

b) O EBS é o mais adequado para armazenar o sistema operacional e os arquivos da aplicação.

Questão 3

a) Duas responsabilidades assumidas pela AWS no RDS:

Backups automáticos.
Aplicação de patches e atualizações.

b) A principal desvantagem é o menor controle sobre a configuração interna do banco de dados e do sistema operacional.

Questão 4

a) Ao habilitar Multi-AZ, a AWS cria uma réplica standby sincronizada em outra Availability Zone.

b) O Standby do Multi-AZ é usado para failover automático. A Read Replica é usada para escalar leituras e não realiza failover automático.

Questão 5
Criação do arquivo
touch db_config.conf
Upload
aws s3 cp db_config.conf s3://config-app-tf11/
Verificação
aws s3 ls s3://config-app-tf11/