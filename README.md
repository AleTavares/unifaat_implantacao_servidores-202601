# TF - Aula 11 - Armazenamento e Banco de Dados na AWS

**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Aula:** 11 - Armazenamento e Banco de Dados na AWS  
**Aluno:** Claudio Luiz Pereira da Silva Neto
**RA:** 6325101

---

## 📌 Questão 1: Amazon S3 (Armazenamento de Objetos)

### a) Caso de uso principal do S3
O Amazon S3 é utilizado para armazenamento de objetos escaláveis, como:

- arquivos estáticos de aplicações web (HTML, CSS, JS)
- imagens e vídeos
- backups e logs de sistemas
- artefatos de deploy em pipelines DevOps

Em DevOps, o S3 é amplamente utilizado para backup, versionamento e distribuição de arquivos.

---

### b) S3 é global ou regional? O que significa “11 noves”?

O Amazon S3 é um serviço **regional**, mas com alta durabilidade dentro da região.

A taxa de **99.999999999% (11 noves)** representa a **durabilidade dos dados**, ou seja:
a probabilidade de perda de um objeto armazenado é extremamente baixa.

---

## 📌 Questão 2: EBS vs EFS

### a) Diferença entre EBS e EFS

- **EBS (Elastic Block Store):**
  - armazenamento em bloco
  - conectado a uma única instância EC2 por vez
  - funciona como um disco rígido virtual

- **EFS (Elastic File System):**
  - sistema de arquivos compartilhado
  - acessível por múltiplas instâncias EC2 simultaneamente
  - funciona como um sistema de arquivos em rede

---

### b) Uso em servidor EC2

O serviço mais adequado para armazenar sistema operacional e aplicação é o **EBS**, pois:

- é de baixa latência
- está diretamente acoplado à instância EC2
- é ideal para boot e execução de sistemas

---

## 📌 Questão 3: Amazon RDS

### a) Responsabilidades da AWS no RDS

A AWS gerencia automaticamente:

- backups automáticos
- aplicação de patches de segurança
- replicação e alta disponibilidade (Multi-AZ opcional)
- monitoramento da infraestrutura do banco

---

### b) Limitação do RDS vs EC2

A principal limitação do RDS é o **menor nível de controle** sobre o banco de dados.

No EC2, é possível:
- personalizar totalmente o banco
- instalar extensões livremente
- controlar o sistema operacional

No RDS, essas ações são limitadas pela AWS.

---

## 📌 Questão 4: Alta Disponibilidade (Multi-AZ)

### a) Funcionamento do Multi-AZ

Ao habilitar Multi-AZ:

- o banco primário é replicado para outra zona de disponibilidade
- existe uma instância standby
- a replicação é síncrona
- ocorre failover automático em caso de falha

---

### b) Standby vs Read Replica

- **Standby (Multi-AZ):**
  - usado para failover automático
  - não acessível diretamente
  - replicação síncrona

- **Read Replica:**
  - usada para escalabilidade de leitura
  - pode ser acessada
  - replicação assíncrona

---

## 📌 Questão 5: Fluxo S3 (Simulação AWS CLI)

### 1. Criar arquivo no Linux (WSL)

```bash
touch db_config.conf