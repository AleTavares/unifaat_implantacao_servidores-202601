# TF014 - Monitoramento e Observabilidade de Containers na AWS

**RA:** 6325149  
**Data:** 22/06/2026  
**Disciplina:** Implementação de servidor e nuvem (cloud)

---

## Questão 1: Três Pilares da Observabilidade (Teórica)

### a) Os três pilares e o objetivo de cada um

**1. Logs — "O que aconteceu?"**  
Registros textuais de eventos discretos com timestamp. Permitem reconstruir exatamente o que ocorreu em um momento específico, como um erro de banco de dados às 02h14 ou uma requisição que retornou 500.

**2. Métricas — "Como está agora / como estava?"**  
Valores numéricos coletados ao longo do tempo (CPU, memória, requisições/segundo, latência). Permitem identificar tendências, comparar baseline com estado atual e acionar alertas automáticos.

**3. Traces — "Qual foi o caminho?"**  
Rastreamento do fluxo de uma requisição através de múltiplos serviços distribuídos. Permite identificar onde está o gargalo em arquiteturas de microsserviços — por exemplo, descobrir que o atraso de 800ms total acontece no serviço de autenticação.

---

### b) Ferramenta AWS responsável por cada pilar no EKS

| Pilar | Ferramenta AWS |
|---|---|
| **Logs** | Amazon CloudWatch Logs + Fluent Bit (DaemonSet) |
| **Métricas** | Amazon CloudWatch Metrics + Container Insights |
| **Traces** | AWS X-Ray |

---

### c) Diferença entre monitoramento e observabilidade

**Monitoramento** é reativo: você define previamente *o que* quer medir (ex: "me avise se CPU > 80%") e acompanha métricas conhecidas. Funciona bem quando você já sabe quais perguntas fazer.

**Observabilidade** é proativa: o sistema emite dados suficientes (logs, métricas, traces) para que você possa investigar *qualquer* estado interno — mesmo perguntas que você ainda não sabia que precisaria fazer.

Apenas monitorar não é suficiente porque em sistemas distribuídos e dinâmicos (como EKS com dezenas de pods), as falhas são emergentes e imprevisíveis. Um pod pode estar com CPU normal mas com vazamento de memória. Um serviço pode estar respondendo mas com latência degradada. Sem observabilidade, você só descobre o problema quando o usuário reclama.

---

## Questão 2: CloudWatch Logs e Fluent Bit (Teórica)

### a) O que é o Fluent Bit e por que é deployado como DaemonSet

**Fluent Bit** é um coletor de logs leve e eficiente (escrito em C), open source, usado pela AWS como padrão no EKS para capturar a saída `stdout`/`stderr` de cada container e encaminhar para o CloudWatch Logs.

É deployado como **DaemonSet** porque esse tipo de recurso Kubernetes garante que **exatamente um pod rode em cada node do cluster**. Se um novo node for adicionado via auto scaling, o Kubernetes automaticamente agenda um pod Fluent Bit nele. Isso é essencial para coleta de logs: sem um agente em cada node, os logs dos pods naquele node ficariam perdidos.

---

### b) Diferença entre Log Group e Log Stream

| Conceito | O que é | Analogia |
|---|---|---|
| **Log Group** | Agrupamento lógico de logs relacionados — definido por nome, tem política de retenção própria | Pasta |
| **Log Stream** | Sequência contínua de eventos de log de uma fonte específica dentro do Log Group | Arquivo dentro da pasta |

**Exemplo no EKS:**
```
Log Group:  /aws/eks/cluster-eks-ads/containers
└── Log Stream: ads-unifaat_ads-site-7d9f8b_ads-site   (pod 1)
└── Log Stream: ads-unifaat_ads-site-3c2a1e_ads-site   (pod 2)
```

Cada pod gera seu próprio Log Stream dentro do mesmo Log Group.

---

### c) Por que configurar política de retenção nos Log Groups

O CloudWatch Logs cobra por **volume armazenado por GB/mês**. Por padrão, sem política de retenção, os logs ficam armazenados **indefinidamente** — o que significa custo crescente sem controle.

Em um cluster EKS com múltiplos pods gerando logs continuamente, sem retenção configurada, o volume pode crescer para centenas de GB em semanas. Para um lab/ambiente de desenvolvimento, 7 dias é suficiente. Para produção, o comum é 30 a 90 dias dependendo do requisito de compliance.

---

## Questão 3: Container Insights e Métricas (Teórica)

### a) Diferença entre métricas padrão do EKS e Container Insights

**Métricas padrão do EKS** (namespace `AWS/EKS`) são limitadas: cobrem o control plane (erros de API, latência do scheduler) mas não fornecem visibilidade por pod ou container.

**Container Insights** (namespace `ContainerInsights`) coleta métricas granulares por pod, node e cluster:

| Nível | Métricas disponíveis |
|---|---|
| **Cluster** | CPU total, memória total, número de nodes |
| **Node** | CPU por node, memória por node, I/O de rede/disco |
| **Pod** | `pod_cpu_utilization`, `pod_memory_utilization`, `pod_network_rx_bytes` |
| **Container** | CPU e memória por container individual dentro do pod |

Essas informações extras permitem identificar qual pod específico está consumindo recursos excessivos.

---

### b) O namespace `ContainerInsights` no CloudWatch

É o namespace de métricas no CloudWatch onde o Container Insights publica todos os dados coletados dos containers. Armazena métricas estruturadas com dimensões como `ClusterName`, `Namespace`, `PodName`, `NodeName` — o que permite filtrar e agregar por qualquer combinação.

**Exemplo de dados armazenados:**
```
Namespace: ContainerInsights
Métrica:   pod_cpu_utilization
Dimensões: ClusterName=cluster-eks-ads, Namespace=ads-unifaat, PodName=ads-site-7d9f8b
Valor:     23.4 (%)
```

---

### c) O que `kubectl top pods` mostra e por que é útil

O comando `kubectl top pods` exibe o consumo atual de **CPU** (em millicores) e **memória** (em Mi/Gi) de cada pod em tempo real, usando dados do Metrics Server.

```
NAME                        CPU(cores)   MEMORY(bytes)
ads-site-7d9f8b-xk2lp       2m           18Mi
ads-site-3c2a1e-p9qvw        3m           17Mi
```

É útil para monitoramento em tempo real porque permite identificar imediatamente qual pod está sobrecarregado durante um incidente, sem precisar acessar o Console AWS. Em situações de degradação de performance, é o primeiro comando a rodar.

---

## Questão 4: CloudWatch Alarms e Alertas (Teórica)

### a) Evaluation Periods e Threshold

**Threshold** é o valor limite que define a fronteira entre "normal" e "anômalo". Exemplo: CPU > 70% = potencial problema.

**Evaluation Periods** é quantos períodos consecutivos precisam ultrapassar o threshold antes do alarme disparar. Com `period=300s` e `evaluation-periods=2`, o alarme só dispara se a CPU ficar acima de 70% por **10 minutos consecutivos**.

Usar mais de 1 período de avaliação evita **falsos positivos**: um spike momentâneo de CPU (causado por um job pontual, GC, startup de pod) não deve acionar alerta. Ao exigir 2 períodos consecutivos, garantimos que o problema é persistente e não transitório — reduzindo "alert fatigue" da equipe.

---

### b) Os 4 Golden Signals (Google SRE)

| Signal | O que mede | Exemplo no Lab014 |
|---|---|---|
| **Latência** | Tempo de resposta das requisições | Tempo que o Nginx leva para servir a página do site ADS |
| **Tráfego** | Volume de requisições por unidade de tempo | Número de requests/segundo chegando no LoadBalancer |
| **Erros** | Taxa de respostas com falha | Percentual de respostas HTTP 5xx retornadas pelos pods |
| **Saturação** | Quão "cheio" está o sistema | `pod_cpu_utilization` e `pod_memory_utilization` dos pods `ads-site` |

---

### c) Alerta acionável vs alerta genérico

**Alerta genérico** é vago, não indica o que fazer:
> "Algo está diferente no cluster"  
> "Disco em 60%"  
> "Alta utilização detectada"

**Alerta acionável** é específico, contextualizado e indica claramente o que fazer quando disparado:
> "CPU média dos pods `ads-site` no namespace `ads-unifaat` acima de 70% por 10 minutos. Verificar logs com `kubectl logs -n ads-unifaat -l app=ads-site` e considerar escalar para 3 réplicas com `kubectl scale deployment ads-site -n ads-unifaat --replicas=3`"

A diferença está em: **quem disparou**, **qual o valor atual**, **qual o impacto esperado** e **o que fazer**.

---

## Questão 5: Tarefa Prática - Configuração de Monitoramento (Simulação)

**Cenário:** Cluster `producao-cluster` | Namespace `minha-api` | Região `us-east-1`

---

### a) Criar o Log Group com retenção de 14 dias

```bash
# Criar o Log Group
aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --region us-east-1

# Configurar retenção de 14 dias
aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14 \
  --region us-east-1
```

---

### b) CloudWatch Alarm — CPU média > 75% por 2 períodos de 5 minutos

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-producao-HighCPU" \
  --alarm-description "CPU media acima de 75% no cluster producao-cluster" \
  --namespace ContainerInsights \
  --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=producao-cluster \
  --statistic Average \
  --period 300 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region us-east-1
```

`--period 300` = janela de 5 minutos. `--evaluation-periods 2` = 2 períodos consecutivos (10 min total) antes de disparar.

---

### c) Query Logs Insights — contagem de ERRORs na última hora agrupados por 10 minutos

```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as total_erros by bin(10m)
| sort @timestamp asc
```

Esta query:
- `filter` seleciona apenas eventos com "ERROR" na mensagem
- `stats count()` conta as ocorrências
- `bin(10m)` agrupa em intervalos de 10 minutos
- Para executar via CLI na última hora:

```bash
QUERY_ID=$(aws logs start-query \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() as total_erros by bin(10m) | sort @timestamp asc' \
  --query 'queryId' --output text \
  --region us-east-1)

sleep 5
aws logs get-query-results --query-id $QUERY_ID --region us-east-1
```

---

### d) Listar alarmes com prefixo "EKS-" em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold,Metrica:MetricName}' \
  --output table \
  --region us-east-1
```

**Saída esperada:**
```
--------------------------------------------------------------------
|                        DescribeAlarms                           |
+---------------------+---------+------------+-------------------+
|        Metrica      | Nome    |  Threshold |      Estado       |
+---------------------+---------+------------+-------------------+
| pod_cpu_utilization | EKS-... |     75.0   |        OK         |
+---------------------+---------+------------+-------------------+
```

---

### e) Criar Dashboard CloudWatch com widgets de CPU e Memória

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-producao-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_cpu_utilization",
             "ClusterName", "producao-cluster"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "us-east-1",
          "title": "CPU Utilization - Pods"
        }
      },
      {
        "type": "metric",
        "x": 12, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_memory_utilization",
             "ClusterName", "producao-cluster"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Memory Utilization - Pods"
        }
      }
    ]
  }' \
  --region us-east-1
```

O JSON define 2 widgets lado a lado (x=0 e x=12), cada um com 12 colunas de largura, ocupando a linha superior do dashboard.

---

## Questão 6: Evidências Práticas da Execução do Lab014

### Parte 1: Preparação e Logs

**1. Cluster ativo**

```bash
$ aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status' --output text
ACTIVE
```

**2. Log Group criado**

```bash
$ aws logs describe-log-groups --log-group-name-prefix "/aws/eks/cluster-eks-ads" \
    --query 'logGroups[].{Nome:logGroupName,Retencao:retentionInDays}' --output table

-----------------------------------------------------
|                 DescribeLogGroups                 |
+---------------------------------------+-----------+
|                 Nome                  | Retencao  |
+---------------------------------------+-----------+
|  /aws/eks/cluster-eks-ads/containers  |  7        |
+---------------------------------------+-----------+
```

**3. Fluent Bit e CloudWatch Agent rodando**

```bash
$ kubectl get pods -n amazon-cloudwatch

NAME                                                              READY   STATUS    RESTARTS   AGE
amazon-cloudwatch-observability-controller-manager-8f9f964h6j8r   1/1     Running   0          27s
cloudwatch-agent-cwt6x                                            1/1     Running   0          22s
cloudwatch-agent-wwd4v                                            1/1     Running   0          22s
fluent-bit-5n49s                                                  1/1     Running   0          28s
fluent-bit-zdx28                                                  1/1     Running   0          28s
```

Um pod `fluent-bit` e um `cloudwatch-agent` por node (2 nodes = 2 pods cada), mais o controller manager do addon.

**4. Logs no CloudWatch**

O addon `amazon-cloudwatch-observability` (v6.2.0) foi instalado via `aws eks create-addon` e ficou `ACTIVE`. Os logs dos containers são encaminhados ao Log Group `/aws/eks/cluster-eks-ads/containers` pelo Fluent Bit.

---

### Parte 2: Métricas e Container Insights

**1. Container Insights habilitado via addon**

```bash
$ aws eks create-addon \
    --cluster-name cluster-eks-ads \
    --addon-name amazon-cloudwatch-observability \
    --region sa-east-1

{
    "addon": {
        "addonName": "amazon-cloudwatch-observability",
        "clusterName": "cluster-eks-ads",
        "status": "CREATING",
        "addonVersion": "v6.2.0-eksbuild.1",
        "addonArn": "arn:aws:eks:sa-east-1:577638395851:addon/cluster-eks-ads/amazon-cloudwatch-observability/..."
    }
}

$ aws eks wait addon-active --cluster-name cluster-eks-ads --addon-name amazon-cloudwatch-observability
✅ Addon ATIVO
```

**2. Métricas disponíveis no namespace ContainerInsights**

```bash
$ aws cloudwatch list-metrics --namespace ContainerInsights \
    --dimensions Name=ClusterName,Value=cluster-eks-ads \
    --query 'Metrics[].MetricName' --output text | tr '\t' '\n' | sort -u

cluster_failed_node_count
cluster_node_count
cluster_number_of_running_pods
container_cpu_limit
container_cpu_utilization
container_memory_limit
container_memory_utilization
node_cpu_utilization
node_filesystem_utilization
node_memory_utilization
node_network_total_bytes
node_number_of_running_pods
pod_cpu_utilization
pod_cpu_utilization_over_pod_limit
pod_memory_utilization
pod_memory_utilization_over_pod_limit
pod_network_rx_bytes
pod_network_tx_bytes
pod_status_failed
pod_status_running
... (80+ métricas disponíveis)
```

**3. kubectl top — uso de recursos**

```bash
$ kubectl top nodes

NAME                                            CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
ip-192-168-140-215.sa-east-1.compute.internal   47m          2%       597Mi           18%
ip-192-168-68-90.sa-east-1.compute.internal     61m          3%       589Mi           17%

$ kubectl top pods -n ads-unifaat

NAME                        CPU(cores)   MEMORY(bytes)
ads-site-6df8cf7c44-tz4lz   1m           3Mi
ads-site-6df8cf7c44-wnwdf   1m           3Mi
```

---

### Parte 3: Alarmes e Dashboard

**1. 3 alarmes criados e em estado OK**

```bash
$ aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS" \
    --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' \
    --output table

--------------------------------------------------
|                 DescribeAlarms                 |
+--------+-------------------------+-------------+
| Estado |          Nome           |  Threshold  |
+--------+-------------------------+-------------+
|  OK    |  EKS-ADS-HighCPU        |  70.0       |
|  OK    |  EKS-ADS-HighMemory     |  80.0       |
|  OK    |  EKS-ADS-UnhealthyPods  |  1.0        |
+--------+-------------------------+-------------+
```

**2. Dashboard criado via CLI**

```bash
$ aws cloudwatch put-dashboard --dashboard-name "EKS-ADS-Dashboard" --dashboard-body '{...}'

{
    "DashboardValidationMessages": []
}
✅ Dashboard criado
```

Dashboard com 2 widgets: `pod_cpu_utilization` (x=0) e `pod_memory_utilization` (x=12), período de 60s, estatística Average.

---

### Parte 4: Tráfego e Observação

**1. Geração de 50 requisições HTTP**

```bash
$ ENDPOINT="aeee7938233dd44fc8f6f9ad995e3f92-1490837119.sa-east-1.elb.amazonaws.com"
$ for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code}" http://$ENDPOINT; echo " - Request $i"; done

200 - Request 1
200 - Request 2
...
200 - Request 50
✅ 50 requisições enviadas — todas com HTTP 200
```

**2. Métricas após a carga**

```bash
$ kubectl top pods -n ads-unifaat

NAME                        CPU(cores)   MEMORY(bytes)
ads-site-6df8cf7c44-tz4lz   1m           3Mi
ads-site-6df8cf7c44-wnwdf   1m           3Mi
```

Aplicação Nginx estática com consumo mínimo de recursos — CPU <1% e memória 3Mi por pod.

**3. Logs de acesso registrando as requisições**

```bash
$ kubectl logs -n ads-unifaat -l app=ads-site --tail=10

192.168.68.90  - - [22/Jun/2026:23:52:43 +0000] "GET / HTTP/1.1" 200 935 "-" "curl/8.5.0" "-"
192.168.140.215- - [22/Jun/2026:23:52:43 +0000] "GET / HTTP/1.1" 200 935 "-" "curl/8.5.0" "-"
192.168.68.90  - - [22/Jun/2026:23:52:43 +0000] "GET / HTTP/1.1" 200 935 "-" "curl/8.5.0" "-"
192.168.140.215- - [22/Jun/2026:23:52:43 +0000] "GET / HTTP/1.1" 200 935 "-" "curl/8.5.0" "-"
192.168.68.90  - - [22/Jun/2026:23:52:52 +0000] "GET / HTTP/1.1" 200 935 "-" "kube-probe/1.32" "-"
192.168.140.215- - [22/Jun/2026:23:52:52 +0000] "GET / HTTP/1.1" 200 935 "-" "kube-probe/1.32" "-"
```

Requisições distribuídas entre os dois nodes (`192.168.68.90` e `192.168.140.215`). Load Balancer funcionando corretamente.

---

### Parte 5: Limpeza

**1. Alarmes removidos**

```bash
$ aws cloudwatch delete-alarms \
    --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods"
✅ Alarmes removidos
```

**2. Dashboard e Log Group removidos**

```bash
$ aws cloudwatch delete-dashboards --dashboard-names "EKS-ADS-Dashboard"
✅ Dashboard removido

$ aws logs delete-log-group --log-group-name /aws/eks/cluster-eks-ads/containers
✅ Log Group removido
```

**3. Namespace e política IAM removidos**

```bash
$ kubectl delete namespace amazon-cloudwatch
namespace "amazon-cloudwatch" deleted
✅ Namespace amazon-cloudwatch removido

$ aws iam delete-role-policy --role-name EKSNodeRole-ADS --policy-name CloudWatchLogsAccess
✅ Política IAM removida
```

---

## Comandos Executados no Lab014

```bash
# Variáveis
export AWS_ACCOUNT_ID="577638395851"
export AWS_REGION="sa-east-1"
export CLUSTER_NAME="cluster-eks-ads"
export NAMESPACE="ads-unifaat"
export LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"

# Seção 1 - Verificar cluster
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status' --output text
kubectl get pods -n $NAMESPACE
kubectl get nodes

# Seção 2 - CloudWatch Logs
aws logs create-log-group --log-group-name $LOG_GROUP --region $AWS_REGION
aws logs put-retention-policy --log-group-name $LOG_GROUP --retention-in-days 7 --region $AWS_REGION
kubectl create namespace amazon-cloudwatch
kubectl create configmap fluent-bit-cluster-info --namespace amazon-cloudwatch \
  --from-literal=cluster.name=$CLUSTER_NAME --from-literal=http.server=On \
  --from-literal=http.port=2020 --from-literal=logs.region=$AWS_REGION
aws iam put-role-policy --role-name EKSNodeRole-ADS --policy-name CloudWatchLogsAccess \
  --policy-document file:///tmp/cloudwatch-policy.json

# Seção 3 - Container Insights via addon oficial
aws eks create-addon --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability --region $AWS_REGION
aws eks wait addon-active --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability --region $AWS_REGION
kubectl get pods -n amazon-cloudwatch
aws cloudwatch list-metrics --namespace ContainerInsights \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME --query 'Metrics[].MetricName'

# Seção 4 - Alarmes
aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-HighCPU" \
  --namespace ContainerInsights --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average --period 300 --threshold 70 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 2 \
  --treat-missing-data notBreaching --region $AWS_REGION

aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-HighMemory" \
  --namespace ContainerInsights --metric-name pod_memory_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 2 \
  --treat-missing-data notBreaching --region $AWS_REGION

aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-UnhealthyPods" \
  --namespace ContainerInsights --metric-name pod_status_failed \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME Name=Namespace,Value=$NAMESPACE \
  --statistic Sum --period 60 --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 \
  --treat-missing-data notBreaching --region $AWS_REGION

aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' --output table

# Seção 6 - Métricas e tráfego
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl top nodes
kubectl top pods -n $NAMESPACE
kubectl logs -n $NAMESPACE -l app=ads-site --tail=10

ENDPOINT=$(kubectl get svc ads-site-service -n $NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
for i in $(seq 1 50); do
  curl -s -o /dev/null -w "%{http_code}" http://$ENDPOINT; echo " - Request $i"
done

# Seção 7 - Dashboard
aws cloudwatch put-dashboard --dashboard-name "EKS-ADS-Dashboard" \
  --dashboard-body '{"widgets":[...]}'

# Seção 9 - Limpeza
aws cloudwatch delete-alarms \
  --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods"
aws cloudwatch delete-dashboards --dashboard-names "EKS-ADS-Dashboard"
aws logs delete-log-group --log-group-name $LOG_GROUP --region $AWS_REGION
kubectl delete namespace amazon-cloudwatch
aws iam delete-role-policy --role-name EKSNodeRole-ADS --policy-name CloudWatchLogsAccess
```

---

## Observações

- Ambiente recriado via `start.sh` pois o cluster da Aula 13 havia sido encerrado após a aula anterior.
- O PC reiniciou durante a execução do `start.sh`. Como o script é idempotente, foi executado novamente e retomou do ponto onde parou (cluster já estava ACTIVE na AWS).
- O manifesto YAML do Fluent Bit standalone retornou 404 (URL desatualizada). Solução: addon oficial `amazon-cloudwatch-observability` v6.2.0, que instala automaticamente Fluent Bit + CloudWatch Agent como DaemonSets.
- O `kubectl top` exige Metrics Server separado (não incluído no addon CloudWatch). Foi instalado via manifesto oficial.
- Região utilizada: `sa-east-1` (São Paulo). Account ID: `577638395851`.
- Todos os recursos de monitoramento foram removidos ao final conforme exigido pelo TF.

---

**Data de Conclusão:** 22/06/2026  
**Status:** ✅ Completo — Q1-Q5 respondidas | Q6 com evidências reais de execução
