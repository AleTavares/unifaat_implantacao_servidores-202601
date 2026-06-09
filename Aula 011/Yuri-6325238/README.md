Questoes
1)A) O principal caso de uso do Amazon S3 em aplicações Web e DevOps é armazenamento de objetos (object storage)

1)B)O Amazon S3 é um serviço regional, não global.

Quando você cria um bucket, ele fica localizado em uma região específica (ex: us-east-1, sa-east-1).
Os dados não são automaticamente replicados entre regiões (a menos que você configure replicação).

Apesar disso, ele pode ser acessado globalmente via internet, desde que autorizado.

## 2

A)armazenamento exclusivo por instância

B)Amazon EBS

# 3

A)Aplicação de patches e atualizações do banco de dados
A AWS cuida de atualizações de versão (minor e, em alguns casos, major upgrades controlados), além de correções de segurança do engine (ex: MySQL, PostgreSQL, etc.), reduzindo o risco de falhas e vulnerabilidades.
Backups automatizados e recuperação
O RDS realiza backups automáticos (incluindo snapshots e point-in-time recovery), permitindo restaurar o banco para um estado anterior sem necessidade de scripts manuais ou infraestrutura adicional.

Outras responsabilidades que também são gerenciadas incluem monitoramento básico, failover (em Multi-AZ) e gerenciamento do armazenamento subjacente.

B)Menor controle e flexibilidade sobre o ambiente do banco de dados

# 4

A)No Multi-AZ do RDS, os dados são replicados sincronamente para uma instância standby em outra AZ, usada apenas para failover

B)Standby = alta disponibilidade com failover automático; Read Replica = escala de leitura, sem failover automático e com replicação assíncrona

# 5

"DB_HOST=localhost
DB_USER=admin
DB_PASS=123456" > db_config.conf

aws s3 cp db_config.conf s3://config-app-tf11/

aws s3 ls s3://config-app-tf11/config/

# 6 
