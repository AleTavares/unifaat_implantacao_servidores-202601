## TF - Aula 11 - Armazenamento e Banco de Dados na AWS
Disciplina: Implementação de Servidor e Nuvem (Cloud)
Aluno: Caroline Lejne Geli
RA: 6325016

# Questão 1 - Amazon S3

### a)

O Amazon S3 (Simple Storage Service) é um serviço de armazenamento de objetos utilizado principalmente para armazenar arquivos estáticos, backups, logs, imagens, vídeos, documentos e artefatos de aplicações Web. Também é amplamente utilizado para hospedagem de sites estáticos e armazenamento de dados de aplicações.

### b)

O Amazon S3 é um serviço regional, onde os dados são armazenados em uma região AWS específica escolhida pelo usuário.

A taxa "Onze Noves" (99,999999999%) refere-se à **durabilidade** dos dados, garantindo uma probabilidade extremamente baixa de perda de objetos armazenados.

---

# Questão 2 - Amazon EBS e Amazon EFS

### a)

O Amazon EBS (Elastic Block Store) fornece armazenamento em blocos e normalmente é anexado a uma única instância EC2 por vez, funcionando como um disco rígido virtual.

O Amazon EFS (Elastic File System) fornece armazenamento em arquivos utilizando o protocolo NFS, permitindo que múltiplas instâncias EC2 acessem simultaneamente o mesmo sistema de arquivos.

### b)

O Amazon EBS é o serviço mais adequado para armazenar o sistema operacional e os executáveis da aplicação, pois oferece armazenamento em blocos com baixa latência e alto desempenho para esse tipo de uso.

---

# Questão 3 - Amazon RDS

### a)

Duas responsabilidades assumidas pela AWS ao utilizar o RDS são:

* Aplicação de patches e atualizações do banco de dados.
* Realização de backups automáticos e recuperação dos dados.

Outras responsabilidades incluem monitoramento, manutenção e gerenciamento da infraestrutura do banco.

### b)

A principal desvantagem do RDS é a menor flexibilidade administrativa em comparação com um banco instalado diretamente em uma instância EC2, pois o usuário não possui acesso completo ao sistema operacional e às configurações internas do servidor.

---

# Questão 4 - Alta Disponibilidade no RDS

### a)

Ao habilitar o Multi-AZ, a AWS cria automaticamente uma instância standby em uma Zona de Disponibilidade (AZ) diferente da instância principal e mantém os dados sincronizados por replicação automática.

### b)

O Standby do Multi-AZ é utilizado exclusivamente para alta disponibilidade e failover automático, não permitindo consultas diretas.

A Read Replica é utilizada para distribuir carga de leitura e pode receber consultas, porém não realiza failover automático como o Standby do Multi-AZ.

---

# Questão 5 - Fluxo de Upload para o Amazon S3

### 1. Criação do Arquivo

```bash
touch db_config.conf
```

### 2. Upload para o Bucket S3

```bash
aws s3 cp db_config.conf s3://config-app-tf11/
```

### 3. Verificação do Upload

```bash
aws s3 ls s3://config-app-tf11/
```
