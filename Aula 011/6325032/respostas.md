Questão 1

a) O principal caso de uso do S3 é armazenar arquivos como imagens, vídeos, backups, logs, documentos e arquivos estáticos de aplicações web.

b) O S3 é um serviço regional. A taxa de 99,999999999% (11 noves) refere-se à durabilidade dos dados.

Questão 2

a)

EBS: armazenamento em blocos conectado a uma única instância EC2 por vez.
EFS: sistema de arquivos compartilhado que pode ser acessado simultaneamente por várias instâncias EC2.

b) O mais adequado para armazenar o sistema operacional e os arquivos da aplicação é o EBS.

Questão 3

a) O RDS assume tarefas como:

Backups automáticos.
Atualizações e correções do banco de dados.
Monitoramento.
Replicação Multi-AZ.

(Cite duas.)

b) A principal desvantagem é a menor liberdade para personalizar o sistema operacional e o banco de dados em comparação com uma instalação própria em uma EC2.

Questão 4

a) Ao habilitar Multi-AZ, a AWS cria uma cópia sincronizada do banco em outra Zona de Disponibilidade.

b)

Standby (Multi-AZ): usado para failover automático.
Read Replica: usada para leitura e escalabilidade, não para failover automático.

Questão 5

Criação do arquivo

touch db_config.conf

ou

echo "teste" > db_config.conf

Upload

aws s3 cp db_config.conf s3://config-app-tf11/

Verificação

aws s3 ls s3://config-app-tf11/