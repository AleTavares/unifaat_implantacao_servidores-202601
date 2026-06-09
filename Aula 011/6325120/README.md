# Respostas teóricas
1)
a- O Amazon S3 é usado principalmente para armazenar arquivos na nuvem, como imagens, vídeos, backups, logs e arquivos de aplicações. Também pode hospedar sites estáticos, mas não executa sistemas ou programas.

b- O S3 é um serviço regional.
A taxa de 99,999999999% (“11 noves”) representa a durabilidade dos dados, ou seja, a chance quase zero de perda de arquivos armazenados.

2)
a- EBS = exclusivo (1 EC2 por volume)
EFS = compartilhado (várias EC2 ao mesmo tempo)

b- O mais adequado é o Amazon EBS.Porque ele funciona como um disco exclusivo da instância EC2.

3)
a- Backups automáticos e recuperação (point-in-time restore)
Patching e atualização do banco de dados (maintenance/updates)

b- Você não tem acesso total ao sistema operacional nem pode personalizar livremente o banco (como instalar plugins, mudar configurações avançadas ou controlar o SO).
Em EC2, você tem controle total, mas precisa gerenciar tudo manualmente.

4)
a- Quando você habilita Multi-AZ no RDS, o banco passa a ter uma instância secundária em outra zona de disponibilidade.

b- Standby (Multi-AZ): é uma cópia idêntica e sincronizada usada só para failover automático (não pode ser usada para leitura).
Read Replica: é uma cópia assíncrona usada para leitura e escalabilidade, mas não faz failover automático.

5)
1. Criação do arquivo (WSL/Linux):
´´´bash
    touch db_config.conf

2. Upload para o S3:
´´´bash
    aws s3 cp db_config.conf s3://config-app-tf11/

3. Verificação do upload:
´´´bash
    aws s3 ls s3://config-app-tf11/

# Respostas Práticas

## Part 1

6)
📸 Print 1: criação do RDS (output do terminal ou console AWS)
[](/Aula%20011/6325120/image/criação%20do%20RDS%20(output%20do%20terminal%20ou%20console%20AWS).png)
[](/Aula%20011/6325120/image/criação%20do%20RDS%20(output%20do%20terminal%20ou%20console%20AWS)2.png)


