# TF011 - RESUMO EXECUTIVO
## RA: 4025109 | Status: ✅ PRONTO PARA ENTREGA

---

## 📊 Sumário da Atividade

| Questão | Tema | Status | Arquivo |
|---------|------|--------|---------|
| Q1-Q4 | Teórica (S3, EBS/EFS, RDS, Multi-AZ) | ✅ Completo | [README.md](README.md) |
| Q5 | Workflow S3 Upload | ✅ Completo | [README.md](README.md#questão-5) |
| Q6 | Prática RDS + Evidências | ✅ Estruturado | [COMANDOS_PRATICOS.md](COMANDOS_PRATICOS.md) |

---

## 📁 Arquivos Criados

### 📄 Documentação
- **README.md** (Principal)
  - Respostas detalhadas de Q1-Q6
  - Exemplos de comandos AWS CLI
  - Saídas esperadas de cada operação

- **COMANDOS_PRATICOS.md**
  - Passo-a-passo executável
  - Instruções para AWS CLI, DBeaver, psql
  - Padrão de resposta para evidências

- **INSTRUCOES_ENTREGA.md**
  - Checklist de entrega
  - Troubleshooting
  - Cronograma de execução

### 🔧 Scripts Automatizados
- **create-rds.sh**
  - Cria instância RDS PostgreSQL
  - Monitora criação por até 10 minutos
  - Salva configuração em rds-config.env

- **upload-to-s3.sh**
  - Cria arquivo db_config.conf
  - Faz upload para S3
  - Verifica sucesso do upload

### 📝 Scripts SQL
- **create-table.sql**
  - Cria tabela `alunos` com constraints
  - Cria índices para performance
  - Adiciona comentários descritivos

- **insert-data.sql**
  - Insere 4 registros de exemplo
  - Valida inserção com SELECT
  - Mostra estatísticas

---

## 🎯 Conteúdo Respondido

### Questão 1: S3 - Armazenamento de Objetos
```
✅ Casos de uso práticos (hospedagem, backups, data lakes)
✅ S3 é global (buckets em região específica)
✅ "Onze Noves" = Durabilidade (99.999999999%)
```

### Questão 2: EBS vs EFS
```
✅ EBS = Block storage dedicado a 1 instância (para SO)
✅ EFS = File system distribuído em múltiplas instâncias
✅ EBS melhor para SO e executáveis
```

### Questão 3: RDS Gerenciado
```
✅ AWS assume: Backups automáticos + Patching
✅ Desvantagem: Falta flexibilidade vs EC2
```

### Questão 4: Multi-AZ e Read Replicas
```
✅ Multi-AZ: Standby síncrono com failover automático
✅ Read Replica: Assíncrono para distribuir leituras
✅ Tabela comparativa fornecida
```

### Questão 5: S3 Workflow
```
✅ Passo 1: Criar arquivo (echo ou cat)
✅ Passo 2: Upload com aws s3 cp
✅ Passo 3: Verificar com aws s3 ls
```

### Questão 6: RDS Prática
```
✅ Comando AWS CLI completo para criar RDS
✅ Instruções DBeaver com campos preenchidos
✅ Script SQL para tabela alunos
✅ Script SQL para inserir dados
✅ Instruções para backup (snapshot)
```

---

## 🚀 Próximos Passos (Ação do Aluno)

### Fase 1: Setup (5-10 min)
```bash
# 1. Instalar AWS CLI
sudo apt-get install awscli

# 2. Configurar credenciais
aws configure

# 3. Instalar PostgreSQL CLI
sudo apt-get install postgresql-client
```

### Fase 2: Criar Recursos (15-20 min)
```bash
# 1. Executar script RDS
cd Aula\ 011/4025109
chmod +x *.sh
./create-rds.sh        # Aguarde ~10 minutos

# 2. Criar tabela
source rds-config.env
psql -h $RDS_ENDPOINT -U admin -d postgres -f create-table.sql

# 3. Inserir dados
psql -h $RDS_ENDPOINT -U admin -d postgres -f insert-data.sql
```

### Fase 3: Evidências (10-15 min)
```bash
# 1. Capturar screenshots de cada comando
# 2. Salvar em pasta prints/
# 3. Documentar no README
```

### Fase 4: Git & Entrega (5-10 min)
```bash
# 1. Fazer commit
git add "Aula 011/4025109/"
git commit -m "4025109 - [Seu Nome]"

# 2. Push e PR no GitHub
git push origin main
# Criar PR com título: "4025109 - [Seu Nome]"
```

---

## ⏱️ Cronograma

| Fase | Descrição | Tempo | Deadline |
|------|-----------|-------|----------|
| Setup | Instalar dependências | 10 min | ASAP |
| Recursos | Criar RDS + Tabela | 20 min | Até 22:00 |
| Evidências | Capturar screenshots | 15 min | Até 22:15 |
| Entrega | Git + Pull Request | 10 min | **22:30** ⏰ |

**⚠️ IMPORTANTE**: Pull Request deve estar aberto até 22:30!

---

## 💡 Informações Importantes

### Variáveis de Ambiente
```bash
RDS_INSTANCE=rds-tf011-4025109
RDS_ENDPOINT=rds-tf011-4025109.xxxxx.rds.amazonaws.com
RDS_PORT=5432
RDS_USER=admin
RDS_PASSWORD=TempPassword123!
RDS_REGION=us-east-1
```

### Credenciais de Acesso
```
Username: admin
Password: TempPassword123!
Database: postgres
Port: 5432
```

### Bucket S3
```
Name: config-app-tf11
Region: us-east-1
```

### Snapshot RDS
```
ID: snapshot-tf011-4025109
```

---

## 📝 Estrutura Final Esperada

```
Aula 011/4025109/
├── README.md                    (✅ Feito)
├── COMANDOS_PRATICOS.md         (✅ Feito)
├── INSTRUCOES_ENTREGA.md        (✅ Feito)
├── RESUMO_EXECUTIVO.md          (✅ Feito - este arquivo)
├── create-table.sql             (✅ Feito)
├── insert-data.sql              (✅ Feito)
├── create-rds.sh                (✅ Feito)
├── upload-to-s3.sh              (✅ Feito)
├── rds-config.env               (Será criado ao executar create-rds.sh)
└── prints/                      (A criar durante execução)
    ├── 01-aws-configure.png
    ├── 02-rds-status.png
    ├── 03-psql-version.png
    ├── 04-tabela-criada.png
    ├── 05-dados-inseridos.png
    ├── 06-snapshot.png
    └── 07-dbeaver-conexao.png
```

---

## ✅ Checklist Rápido

- [x] Folder `Aula 011/4025109/` criado
- [x] Respostas teóricas (Q1-Q4) documentadas
- [x] Workflow S3 descrito (Q5)
- [x] Exemplos RDS fornecidos (Q6)
- [x] Scripts SQL criados
- [x] Scripts shell criados
- [x] Instruções de entrega elaboradas
- [ ] AWS CLI instalado (aluno fazer)
- [ ] Credenciais configuradas (aluno fazer)
- [ ] RDS criado (aluno fazer)
- [ ] Tabela criada (aluno fazer)
- [ ] Dados inseridos (aluno fazer)
- [ ] Screenshots capturados (aluno fazer)
- [ ] README atualizado com evidências (aluno fazer)
- [ ] Pull Request aberto (aluno fazer)

---

## 🎓 Competências Demonstradas

Ao completar esta tarefa, você terá demonstrado:

✅ **AWS Storage**
- S3: Cases de uso e características
- EBS: Storage em blocos dedicado
- EFS: File system distribuído

✅ **AWS Databases**
- RDS: Banco gerenciado
- Multi-AZ: Alta disponibilidade
- Backups e snapshots

✅ **Comandos AWS CLI**
- Criar recursos
- Monitorar status
- Gerenciar snapshots

✅ **SQL e PostgreSQL**
- DDL: CREATE TABLE
- DML: INSERT, SELECT
- Constraints e índices

✅ **Ferramentas DevOps**
- AWS CLI
- DBeaver
- PostgreSQL CLI (psql)
- Bash scripting

✅ **Git e GitHub**
- Fork e clone
- Commit e push
- Pull requests

---

## 📚 Referências Úteis

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Status Final**: ✅ PRONTO PARA EXECUÇÃO
**Criado em**: 01/06/2024
**RA**: 4025109

Boa sorte na entrega! 🚀
