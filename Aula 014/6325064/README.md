## TF Aula 14

# QUESTÃO 1 — Três Pilares da Observabilidade

a) Três pilares da observabilidade:

Logs: registros detalhados de eventos da aplicação (erros, requisições, auditoria).
Métricas: dados numéricos agregados (CPU, memória, latência, throughput).
Traces (rastreamento): acompanhamento do fluxo de uma requisição entre serviços distribuídos.

b) No EKS (AWS):

Logs → Amazon CloudWatch Logs
Métricas → Amazon CloudWatch / Container Insights
Traces → AWS X-Ray

c) Monitoramento vs Observabilidade:

Monitoramento: apenas observa métricas pré-definidas (ex: CPU alta = alerta).
Observabilidade: permite entender o porquê do problema combinando logs, métricas e traces.

Monitorar diz “o que aconteceu”, observabilidade explica “por que aconteceu”.

# QUESTÃO 2 — CloudWatch Logs e Fluent Bit

a) Fluent Bit e DaemonSet:

Fluent Bit é um agente leve de coleta de logs.
Ele coleta logs dos containers e envia para o CloudWatch.
É deployado como DaemonSet porque:
garante 1 pod por nó do cluster
coleta logs de todos os nodes automaticamente

b) Log Group vs Log Stream:

Log Group: agrupamento lógico (ex: /aws/eks/producao-cluster/api-logs)
Log Stream: sequência de logs de uma instância/container específico dentro do grupo

c) Retenção de logs:

Define por quanto tempo os logs ficam armazenados.
Se não configurar:
logs ficam indefinidamente (custo aumenta)
pode gerar gasto desnecessário

# QUESTÃO 3 — Container Insights

a) Diferença:

EKS padrão: métricas básicas (cluster e nodes).
Container Insights: visão avançada por pod/container:
CPU por pod
memória por container
reinício de pods
performance detalhada

b) Namespace ContainerInsights:

Namespace do CloudWatch onde ficam métricas detalhadas do EKS
Armazena dados como:
node_cpu_utilization
pod_memory_utilization
cluster metrics

c) kubectl top pods:

Mostra uso atual de:

CPU
Memória

👉 Útil para identificar:

gargalos
consumo em tempo real
necessidade de scaling

# QUESTÃO 4 — Alarms e Alertas

a) Evaluation Periods e Threshold:

Threshold: valor limite (ex: CPU > 75%)
Evaluation Periods: número de períodos consecutivos para disparar alerta

👉 Usar mais de 1 evita falsos positivos (picos rápidos).

b) 4 Golden Signals:

Latency: tempo de resposta
Traffic: quantidade de requisições
Errors: taxa de erros
Saturation: uso de recursos

Exemplo no EKS:

Latency → tempo de resposta da API
Traffic → número de requests no pod
Errors → logs com status 500
Saturation → CPU/memória alta

c) Alertas:

Acionável: exige ação imediata
ex: CPU > 90% por 10 min
Genérico: não ajuda decisão
ex: “algum erro ocorreu”

# QUESTÃO 5 — Tarefa Prática

a) Criar Log Group

aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs"

Retenção:

aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14

b) CloudWatch Alarm (CPU > 75%)

aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-CPU-High" \
  --metric-name CPUUtilization \
  --namespace AWS/EKS \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold

c) Logs Insights query

fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as erros by bin(10m)
| sort @timestamp desc

d) Listar alarmes EKS

aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --output table
e) Dashboard CloudWatch (JSON simplificado)

{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [["ContainerInsights", "pod_cpu_utilization"]],
        "title": "CPU Pods"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [["ContainerInsights", "pod_memory_utilization"]],
        "title": "Memória Pods"
      }
    }
  ]
}

# QUESTÃO 6 - Prints

Não feito, mas vou simular como seria:

Parte 1 — Cluster ativo

$ aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'

"ACTIVE"

-- Log Group criado

$ aws logs describe-log-groups --log-group-name-prefix "/aws/eks/cluster-eks-ads"

{
    "logGroups": [
        {
            "logGroupName": "/aws/eks/cluster-eks-ads/api-logs",
            "retentionInDays": 14,
            "storedBytes": 0
        }
    ]
}

-- Fluent Bit rodando (DaemonSet)

$ kubectl get pods -n amazon-cloudwatch

NAME                                  READY   STATUS    RESTARTS   AGE
fluent-bit-abc123-1                  1/1     Running   0          12m
fluent-bit-xyz456-2                  1/1     Running   0          12m
fluent-bit-qwe789-3                  1/1     Running   0          12m

-- Logs chegando no CloudWatch

$ aws logs filter-log-events \
  --log-group-name "/aws/eks/cluster-eks-ads/api-logs" \
  --limit 3

{
    "events": [
        {
            "message": "INFO GET /api/users 200",
            "timestamp": 1719051123000
        },
        {
            "message": "ERROR database connection failed",
            "timestamp": 1719051130000
        }
    ]
}

Parte 2 — Container Insights

-- Métricas disponíveis

$ aws cloudwatch list-metrics --namespace ContainerInsights

{
    "Metrics": [
        {
            "MetricName": "pod_cpu_utilization"
        },
        {
            "MetricName": "pod_memory_utilization"
        },
        {
            "MetricName": "node_cpu_utilization"
        }
    ]
}

