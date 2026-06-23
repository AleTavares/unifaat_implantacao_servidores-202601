# Aula 14: Monitoramento e Observabilidade de Containers na AWS

**Disciplina:** Implementação de servidor e nuvem (cloud)  
**Módulo:** VII - CI/CD + ECR + Deploy + Monitoramento  
**Carga horária:** 3,5h (teórica + prática)

---

## Objetivo da Aula

Capacitar o aluno a implementar **observabilidade completa** em aplicações containerizadas rodando no AWS EKS, cobrindo os três pilares: **Logs**, **Métricas** e **Alertas**. Ao final, o aluno entenderá por que monitoramento é tão importante quanto o próprio deploy e saberá configurar ferramentas profissionais usadas no mercado.

---

## Por que esta Aula é Importante?

Fazer deploy de uma aplicação é apenas **metade do trabalho**. Em produção, problemas acontecem:

- Pods ficam sem memória e são reiniciados silenciosamente
- A latência aumenta e os usuários abandonam o site
- Um bug novo introduz erros 500 que ninguém percebe
- A conta AWS dispara porque um pod está em loop consumindo CPU

**Sem observabilidade, você só descobre problemas quando os usuários reclamam.** Com observabilidade, você descobre antes deles — e às vezes até previne.

> 💡 Na indústria, equipes de **SRE (Site Reliability Engineering)** dedicam ~50% do tempo a monitoramento e observabilidade. Empresas como Google, Netflix e Amazon consideram esta habilidade tão crítica quanto saber programar.

---

## Conceitos Fundamentais

### Os 3 Pilares da Observabilidade

| Pilar | Pergunta que responde | Ferramenta AWS |
|-------|----------------------|----------------|
| **Logs** | "O que aconteceu?" | CloudWatch Logs |
| **Métricas** | "Como está agora?" | CloudWatch Metrics / Container Insights |
| **Alertas** | "Preciso agir?" | CloudWatch Alarms |

### Monitoramento vs Observabilidade

| Conceito | Definição |
|----------|-----------|
| **Monitoramento** | Saber que algo está errado (dashboards, alertas) |
| **Observabilidade** | Entender **por quê** está errado, a partir dos dados emitidos pelo sistema |

Um sistema **monitorado** te avisa: "CPU está alta".  
Um sistema **observável** te permite descobrir: "A CPU está alta porque o endpoint `/search` está fazendo queries sem índice no banco."

---

## Tecnologias e Serviços Abordados

### Amazon CloudWatch

Serviço central de monitoramento da AWS. Funciona como um "painel de controle" unificado para toda sua infraestrutura.

| Componente | Função |
|-----------|--------|
| **CloudWatch Logs** | Armazena e pesquisa logs de aplicações e infraestrutura |
| **CloudWatch Metrics** | Coleta e visualiza métricas numéricas (CPU, memória, latência) |
| **CloudWatch Alarms** | Monitora métricas e dispara ações quando ultrapassam thresholds |
| **CloudWatch Dashboards** | Painéis visuais personalizados com gráficos e widgets |
| **CloudWatch Logs Insights** | Engine de query para análise avançada de logs |

### Container Insights

Extensão do CloudWatch específica para containers. Coleta automaticamente métricas detalhadas de clusters EKS/ECS:

- **CPU e Memória** por pod, container, node e cluster
- **Rede:** bytes enviados/recebidos por pod
- **Disco:** I/O por node
- **Status:** pods running, pending, failed

### Fluent Bit

Agente leve de coleta e encaminhamento de logs. No EKS, roda como **DaemonSet** (um pod em cada node) e captura todos os logs dos containers via stdout/stderr.

```
Pod (stdout) → Fluent Bit (coleta) → CloudWatch Logs (armazena)
```

**Por que Fluent Bit e não Fluentd?**
- Fluent Bit: ~450KB de memória, escrito em C, alta performance
- Fluentd: ~40MB de memória, escrito em Ruby, mais plugins disponíveis
- Para coleta básica no EKS, Fluent Bit é a escolha recomendada pela AWS

### CloudWatch Alarms

Monitora uma métrica continuamente e muda de estado:

```
OK → INSUFFICIENT_DATA → ALARM
```

Conceitos importantes:
- **Threshold:** Valor que define o limite (ex: CPU > 70%)
- **Period:** Intervalo de coleta (ex: 300 segundos = 5 minutos)
- **Evaluation Periods:** Quantos períodos consecutivos precisam violar o threshold
- **Datapoints to Alarm:** Quantos dos períodos avaliados precisam estar em violação

### Os 4 Golden Signals (Google SRE)

Definidos no livro "Site Reliability Engineering" do Google, são as 4 métricas mais importantes para qualquer serviço:

| Signal | O que mede | Como monitorar |
|--------|-----------|---------------|
| **Latência** | Tempo de resposta das requisições | P50, P90, P99 response time |
| **Tráfego** | Volume de demanda no sistema | Requests/segundo |
| **Erros** | Taxa de requisições que falham | % de respostas 5xx |
| **Saturação** | Quanto do recurso está sendo usado | CPU %, Memória %, Disco % |

> Se você só pudesse monitorar 4 coisas, monitore essas.

---

## Estrutura da Aula

| Seção | Tema | Duração Estimada |
|-------|------|-----------------|
| 1 | Preparação do ambiente (start.sh) | 20 min |
| 2 | CloudWatch Logs + Fluent Bit | 30 min |
| 3 | Container Insights (métricas) | 20 min |
| 4 | CloudWatch Alarms (alertas) | 25 min |
| 5 | Logs Insights (queries) | 20 min |
| 6 | Geração de tráfego e observação | 20 min |
| 7 | Console AWS e Dashboard | 15 min |
| 8 | Boas práticas de monitoramento | 15 min |
| 9 | Limpeza do ambiente | 15 min |

---

## Arquivos desta Pasta

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Este arquivo — visão geral e conceitos da aula |
| `Lab014.md` | Laboratório prático passo a passo |
| `TF014.md` | Tarefa Final (avaliativa) com questões teóricas e evidências |
| `start.sh` | Script para subir toda a infraestrutura EKS automaticamente (~20 min) |
| `cleanup.sh` | Script para limpar recursos de monitoramento + opção de limpeza total |

---

## Pré-requisitos

### Ferramentas Necessárias

| Ferramenta | Versão Mínima | Verificar com |
|-----------|--------------|---------------|
| AWS CLI | 2.x | `aws --version` |
| Docker | 20.x+ | `docker --version` |
| kubectl | 1.28+ | `kubectl version --client` |

### Conhecimentos Prévios

- ✅ Aula 12: CI/CD e ECR (push de imagens)
- ✅ Aula 13: Deploy no EKS (cluster, nodes, pods, services)
- ✅ Conceitos de Kubernetes: Pod, Deployment, Service, Namespace
- ✅ Conceitos de AWS: IAM Roles, VPC, EC2

### Permissões AWS Necessárias

O usuário IAM precisa das seguintes permissões:
- `CloudWatchFullAccess` (logs, métricas, alarmes, dashboards)
- `AmazonEKSClusterPolicy` (gerenciar cluster)
- `IAMFullAccess` (criar/editar roles e policies)

---

## Como Iniciar

### Se o cluster da Aula 13 ainda está rodando:

```bash
# Verificar
aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'
kubectl get pods -n ads-unifaat

# Se retornar "ACTIVE" e pods "Running", siga direto para o Lab014.md
```

### Se o cluster foi removido (cleanup da Aula 13):

```bash
# Configurar variáveis
export AWS_ACCOUNT_ID="seu-account-id"
export AWS_REGION="us-east-2"

# Dar permissão e executar
chmod +x start.sh
./start.sh

# Aguardar ~20 minutos para toda infraestrutura subir
```

### Após a aula:

```bash
# Limpar recursos de monitoramento (e opcionalmente o cluster inteiro)
chmod +x cleanup.sh
./cleanup.sh
```

---

## Custos AWS Estimados

| Recurso | Custo/hora | Custo para 3h de lab |
|---------|-----------|---------------------|
| EKS Control Plane | $0.10/h | $0.30 |
| 2x EC2 t3.medium (nodes) | $0.0416/h cada | $0.25 |
| LoadBalancer (ELB) | $0.025/h | $0.08 |
| CloudWatch Logs (ingest) | ~$0.50/GB | ~$0.01 |
| CloudWatch Alarms (3) | Grátis (Free Tier) | $0.00 |
| CloudWatch Dashboard | $3.00/mês | ~$0.01 |
| **Total estimado** | | **~$0.65 para 3h** |

> ⚠️ **IMPORTANTE:** Sempre execute o `cleanup.sh` ao final da aula! Deixar o cluster rodando por 24h custa ~$4. Uma semana esquecido custa ~$28.

---

## Glossário Rápido

| Termo | Definição |
|-------|-----------|
| **DaemonSet** | Recurso K8s que garante 1 pod em cada node do cluster |
| **Log Group** | Container lógico de logs no CloudWatch (como uma pasta) |
| **Log Stream** | Sequência de eventos de log dentro de um Log Group |
| **Namespace (CW)** | Agrupamento de métricas (ex: `ContainerInsights`, `AWS/EKS`) |
| **Threshold** | Valor limite que define quando um alarme dispara |
| **Evaluation Period** | Intervalo de tempo avaliado por um alarme |
| **SRE** | Site Reliability Engineering — disciplina de confiabilidade |
| **Observability** | Capacidade de inferir estado interno a partir de outputs externos |
| **Baseline** | Comportamento normal do sistema (referência para detectar anomalias) |
| **Runbook** | Documento com passos para resolver um problema específico |

---

## Referências e Leitura Complementar

- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [Container Insights for EKS](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)
- [Fluent Bit for EKS](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html)
- [Google SRE Book - Chapter 6: Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [The Three Pillars of Observability](https://www.oreilly.com/library/view/distributed-systems-observability/9781492033431/)

---

## Conexão com o Mercado de Trabalho

Profissionais que dominam observabilidade são altamente valorizados:

- **DevOps Engineer:** Configura pipelines de monitoramento e alertas
- **SRE (Site Reliability Engineer):** Define SLOs, SLIs e error budgets
- **Cloud Engineer:** Implementa observabilidade na infraestrutura
- **Platform Engineer:** Constrói plataformas internas com monitoramento embutido

Ferramentas equivalentes no mercado:
- **Datadog** — Monitoramento SaaS completo (concorrente do CloudWatch)
- **Grafana + Prometheus** — Stack open-source para métricas
- **ELK Stack (Elasticsearch + Logstash + Kibana)** — Análise de logs
- **Jaeger / Zipkin** — Tracing distribuído open-source

---

*Aula 14 — Módulo VII — Implantação de Servidor e Nuvem (Cloud) — UniFAAT 2026.1*
