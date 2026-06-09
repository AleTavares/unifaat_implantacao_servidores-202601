# Resposta TF011 - RA 1120245

## Questão 1: Armazenamento de Objetos (S3)

### a) Caso de uso principal
O Amazon S3 é ideal para armazenar arquivos estáticos e objetos acessados por aplicações Web e pipelines DevOps, como backups, arquivos de configuração, logs, imagens, conteúdos estáticos e artefatos de build. Em um contexto de aplicação Web, o S3 é amplamente usado para distribuição de mídia, uploads de usuários e hospedagem de arquivos estáticos.

### b) Global ou regional / "Onze Noves"
O S3 é um serviço global com buckets definidos em regiões, mas os endpoints de bucket são regionais. A taxa "Onze Noves" (99,999999999%) refere-se à durabilidade dos dados no S3.

## Questão 2: Armazenamento de Blocos vs. Arquivos (EBS/EFS)

### a) Diferença fundamental
O Amazon EBS fornece volumes de bloco conectados a uma única instância EC2 por vez e funciona como um disco local, adequado para sistemas operacionais e aplicativos. O Amazon EFS é um sistema de arquivos em rede que pode ser montado simultaneamente por várias instâncias EC2, permitindo compartilhamento de arquivos entre servidores.

### b) Mais adequado para Sistema Operacional e executável
Para o sistema operacional e o executável da aplicação em uma instância EC2, o mais adequado é o Amazon EBS, pois oferece armazenamento em bloco para a raiz da instância e desempenho consistente.

## Questão 3: Banco de Dados Gerenciado (RDS)

### a) Responsabilidades assumidas pela AWS no RDS
- Gerenciamento de backups automáticos e restaurações.
- Aplicação de patches de software e manutenção do mecanismo de banco de dados.
- Monitoramento básico, detecção de falhas e replicação de infraestrutura.

### b) Principal desvantagem do RDS
A principal limitação é a menor flexibilidade para personalizar configurações avançadas do banco de dados e do sistema operacional, além de um custo potencialmente maior em comparação com um banco de dados gerenciado em uma instância EC2.

## Questão 4: Alta Disponibilidade no RDS

### a) O que acontece com Multi-AZ
Quando o Multi-AZ é habilitado, a AWS cria uma réplica de standby em outra zona de disponibilidade e mantém os dados sincronizados. Em caso de falha da instância principal, o failover ocorre automaticamente para a instância standby.

### b) Diferença entre Standby Multi-AZ e Read Replica
Um standby Multi-AZ é usado apenas para failover automático e não serve para consultas de leitura. Uma Read Replica é destinada a offload de leituras e escalabilidade de consultas, e não é automaticamente promovida para failover sem intervenção.

## Questão 5: Fluxo de upload para S3 via AWS CLI

### 1. Criação do arquivo
```bash
cat > db_config.conf <<'EOFDB'
# Configuração de banco de dados
EOFDB
```
Ou:
```bash
touch db_config.conf
```

### 2. Upload para o bucket
```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### 3. Verificação
```bash
aws s3 ls s3://config-app-tf11/
```
a
## Instruções práticas

### Passos para executar no WSL/Linux
1. Instalar o AWS CLI:
   ```bash
   sudo apt update && sudo apt install awscli -y
   ```
2. Configurar as credenciais AWS:
   ```bash
   aws configure
   ```
3. Testar a conectividade RDS:
   ```bash
   aws rds describe-db-instances
   ```
4. Enviar o arquivo para o bucket S3:
   ```bash
   aws s3 cp db_config.conf s3://config-app-tf11/
   ```
5. Listar o conteúdo do bucket:
   ```bash
   aws s3 ls s3://config-app-tf11/
   ```
6. Criar o snapshot do RDS:
   ```bash
   aws rds create-db-snapshot \
     --db-instance-identifier rds-tf011-1120245 \
     --db-snapshot-identifier snapshot-tf011-1120245
   ```

### Observação
Neste ambiente de edição não há AWS CLI instalado, por isso os comandos devem ser executados localmente no seu WSL/Linux.
