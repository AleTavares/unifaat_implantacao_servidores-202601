# TF014 - Monitoramento e Observabilidade de Containers na AWS

Aluno: **Andreyh Rodrigues de Souza**  
RA: **6325231**  
Disciplina: Implementacao de servidor e nuvem (cloud)  
Aula: 14 - Monitoramento e Observabilidade de Containers na AWS

## Questoes teoricas

### Questao 1 - Tres pilares da observabilidade

**a) Tres pilares e objetivos**

Os tres pilares da observabilidade sao:

- **Logs:** registram eventos detalhados gerados pela aplicacao, containers e infraestrutura. O objetivo e responder "o que aconteceu?", facilitando auditoria, investigacao de erros e debugging.
- **Metricas:** representam valores numericos coletados ao longo do tempo, como CPU, memoria, rede, quantidade de pods e requisicoes. O objetivo e responder "como o sistema esta se comportando agora e historicamente?".
- **Traces/Rastreamento ou Alertas, no contexto da aula:** em observabilidade moderna, traces mostram o caminho de uma requisicao entre servicos. Na Aula 14, o terceiro pilar trabalhado de forma pratica foi **alertas**, cujo objetivo e avisar automaticamente quando uma metrica ou condicao indica problema.

**b) Servicos/ferramentas no EKS/AWS**

- Logs: **CloudWatch Logs** com coleta via **Fluent Bit**.
- Metricas: **CloudWatch Metrics** e **Container Insights**.
- Alertas: **CloudWatch Alarms**. Para traces, em arquiteturas mais completas, poderia ser usado AWS X-Ray/OpenTelemetry.

**c) Monitoramento vs observabilidade**

Monitoramento mostra que algo esta errado, por exemplo "CPU acima de 80%" ou "pod caiu". Observabilidade permite entender por que o problema aconteceu, correlacionando logs, metricas e outros sinais. Apenas monitorar nao e suficiente porque um alarme isolado nao explica causa raiz; ele so indica o sintoma. Com observabilidade, e possivel investigar se o problema veio de aumento de trafego, erro de aplicacao, falta de recursos, falha de rede ou comportamento anormal de algum pod.

### Questao 2 - CloudWatch Logs e Fluent Bit

**a) Fluent Bit e DaemonSet**

O **Fluent Bit** e um agente leve de coleta e encaminhamento de logs. No EKS, ele coleta os logs emitidos pelos containers em `stdout` e `stderr` e envia para o CloudWatch Logs. Ele e implantado como **DaemonSet** porque esse tipo de recurso do Kubernetes garante que exista um pod do agente em cada node do cluster. Assim, todos os containers executados em todos os nodes podem ter seus logs coletados.

**b) Log Group vs Log Stream**

Um **Log Group** e um agrupamento logico de logs no CloudWatch, semelhante a uma pasta. Exemplo: `/aws/eks/cluster-eks-ads/containers`. Um **Log Stream** e uma sequencia especifica de eventos dentro de um Log Group, normalmente associada a um pod, container, node ou origem especifica.

**c) Politica de retencao**

A politica de retencao define por quanto tempo os logs ficam armazenados. Ela e importante para controlar custo, evitar acumulo desnecessario e atender requisitos de auditoria. Se nao configurar retencao, os logs podem ficar armazenados indefinidamente, aumentando custo no CloudWatch e dificultando a organizacao dos dados.

### Questao 3 - Container Insights e metricas

**a) Metricas padrao do EKS vs Container Insights**

As metricas padrao do EKS mostram informacoes mais gerais sobre o cluster e plano de controle. O **Container Insights** amplia essa visibilidade com metricas detalhadas de containers, pods, nodes e namespaces, como uso de CPU e memoria por pod, rede, disco, status de pods e consumo por componente. Isso facilita identificar gargalos dentro do cluster, nao apenas saber que o cluster existe.

**b) Namespace `ContainerInsights`**

O namespace `ContainerInsights` no CloudWatch e o agrupamento onde ficam armazenadas as metricas coletadas dos ambientes conteinerizados. Ele guarda dados como `pod_cpu_utilization`, `pod_memory_utilization`, status de pods, uso por node, uso por namespace e outras metricas relacionadas ao EKS/ECS.

**c) `kubectl top pods`**

O comando `kubectl top pods` mostra o consumo atual de CPU e memoria dos pods. Ele e util para monitoramento em tempo real porque permite verificar rapidamente quais pods estao consumindo mais recursos, especialmente durante testes de carga ou investigacao de lentidao.

### Questao 4 - CloudWatch Alarms e alertas

**a) Evaluation Periods e Threshold**

**Threshold** e o valor limite que dispara uma condicao de alarme, por exemplo CPU maior que 75%. **Evaluation Periods** define quantos periodos precisam ser avaliados antes de o alarme mudar de estado. Usar mais de um periodo reduz falsos positivos, porque evita disparar alerta por picos muito curtos ou momentaneos.

**b) 4 Golden Signals do Google SRE**

- **Latencia:** tempo de resposta da aplicacao. Exemplo no Lab014: tempo que o site `ads-site` leva para responder via LoadBalancer.
- **Trafego:** volume de requisicoes. Exemplo: quantidade de requests geradas pelo loop de `curl` ou pelo `load-test.sh`.
- **Erros:** taxa ou quantidade de falhas. Exemplo: mensagens com `ERROR`, HTTP 500 ou HTTP 503 nos logs do CloudWatch.
- **Saturacao:** uso dos recursos disponiveis. Exemplo: CPU e memoria dos pods vistas por `kubectl top pods` e Container Insights.

**c) Alerta acionavel vs generico**

Um **alerta acionavel** indica um problema claro e sugere uma acao. Exemplo: `EKS-ADS-HighCPU`: "CPU acima de 70% por 2 periodos de 5 minutos no cluster ADS". A acao pode ser investigar pods com maior consumo, gerar escala ou revisar limites.

Um **alerta generico** informa algo vago e nao orienta resposta. Exemplo: "Algo mudou no cluster". Esse tipo de alerta gera ruido, fadiga de alertas e nao ajuda a resolver incidentes.

## Questao 5 - Tarefa pratica de configuracao

Cenario:

- Cluster: `producao-cluster`
- Namespace: `minha-api`
- Log Group: `/aws/eks/producao-cluster/api-logs`
- Regiao: `us-east-1`

### a) Criar Log Group com retencao de 14 dias

```bash
aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --region us-east-1

aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14 \
  --region us-east-1
```

### b) Criar CloudWatch Alarm para CPU media acima de 75%

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-producao-cluster-HighCPU" \
  --alarm-description "CPU media acima de 75% por 2 periodos de 5 minutos no cluster producao-cluster" \
  --namespace ContainerInsights \
  --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=producao-cluster Name=Namespace,Value=minha-api \
  --statistic Average \
  --period 300 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region us-east-1
```

### c) Query CloudWatch Logs Insights para contar erros na ultima hora

Executar no CloudWatch Logs Insights selecionando o Log Group `/aws/eks/producao-cluster/api-logs` e intervalo "Last 1 hour":

```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as total_erros by bin(10m)
| sort @timestamp desc
```

### d) Listar alarmes com prefixo `EKS-` em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Metrica:MetricName,Threshold:Threshold}' \
  --output table \
  --region us-east-1
```

### e) Criar Dashboard com widgets de CPU e Memoria

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-producao-cluster-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", "producao-cluster", "Namespace", "minha-api"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "CPU media - minha-api"
        }
      },
      {
        "type": "metric",
        "x": 12, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_memory_utilization", "ClusterName", "producao-cluster", "Namespace", "minha-api"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Memoria media - minha-api"
        }
      }
    ]
  }' \
  --region us-east-1
```

## Comandos executados no Lab014

### Preparacao

```bash
export AWS_ACCOUNT_ID="SEU_ACCOUNT_ID"
export AWS_REGION="us-east-2"
export CLUSTER_NAME="cluster-eks-ads"
export NAMESPACE="ads-unifaat"
export LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"

aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status' --output text --region $AWS_REGION
kubectl get pods -n $NAMESPACE
kubectl get nodes
```

Caso o cluster nao exista:

```bash
cd "Aula 014"
chmod +x start.sh
./start.sh
```

### CloudWatch Logs e Fluent Bit

```bash
aws logs create-log-group --log-group-name $LOG_GROUP --region $AWS_REGION
aws logs put-retention-policy --log-group-name $LOG_GROUP --retention-in-days 7 --region $AWS_REGION

kubectl create namespace amazon-cloudwatch
kubectl create configmap fluent-bit-cluster-info \
  --namespace amazon-cloudwatch \
  --from-literal=cluster.name=$CLUSTER_NAME \
  --from-literal=http.server=On \
  --from-literal=http.port=2020 \
  --from-literal=logs.region=$AWS_REGION
```

```bash
aws iam put-role-policy \
  --role-name EKSNodeRole-ADS \
  --policy-name CloudWatchLogsAccess \
  --policy-document file://cloudwatch-policy.json

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonSet/container-insights-monitoring/fluent-bit/fluent-bit.yaml

kubectl get pods -n amazon-cloudwatch
kubectl logs -n amazon-cloudwatch -l k8s-app=fluent-bit --tail=10

aws logs describe-log-streams \
  --log-group-name $LOG_GROUP \
  --order-by LastEventTime \
  --descending \
  --limit 5 \
  --query 'logStreams[].logStreamName' \
  --region $AWS_REGION

aws logs filter-log-events \
  --log-group-name $LOG_GROUP \
  --start-time $(date -d '5 minutes ago' +%s)000 \
  --limit 10 \
  --query 'events[].message' \
  --output text \
  --region $AWS_REGION
```

### Container Insights e metricas

```bash
aws eks update-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability \
  --region $AWS_REGION 2>/dev/null || \
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability \
  --region $AWS_REGION

kubectl get pods -n amazon-cloudwatch

aws cloudwatch list-metrics \
  --namespace ContainerInsights \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --query 'Metrics[].MetricName' \
  --output text \
  --region $AWS_REGION

kubectl top pods -n $NAMESPACE
kubectl top nodes
```

### Alarmes

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-HighCPU" \
  --alarm-description "CPU acima de 70% no cluster ADS" \
  --namespace ContainerInsights \
  --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region $AWS_REGION

aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-HighMemory" \
  --alarm-description "Memoria acima de 80% no cluster ADS" \
  --namespace ContainerInsights \
  --metric-name pod_memory_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region $AWS_REGION

aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-UnhealthyPods" \
  --alarm-description "Pods nao saudaveis no namespace ads-unifaat" \
  --namespace ContainerInsights \
  --metric-name pod_status_failed \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME Name=Namespace,Value=$NAMESPACE \
  --statistic Sum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --treat-missing-data notBreaching \
  --region $AWS_REGION

aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-ADS" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' \
  --output table \
  --region $AWS_REGION
```

### Logs Insights

```sql
fields @timestamp, @message
| filter @message like /error|ERROR|Error|500|503/
| sort @timestamp desc
| limit 50
```

```sql
fields @timestamp, @message
| filter @message like /GET|POST|PUT|DELETE/
| stats count() as total_requests by bin(5m)
| sort @timestamp desc
```

### Trafego e observacao

```bash
ENDPOINT=$(kubectl get svc ads-site-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ENDPOINT"

for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}" http://$ENDPOINT
  echo " - Request $i"
done

kubectl top pods -n $NAMESPACE
kubectl top nodes
kubectl logs -n $NAMESPACE -l app=ads-site --tail=10
```

### Dashboard

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-ADS-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", "'$CLUSTER_NAME'"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "'$AWS_REGION'",
          "title": "CPU Utilization - Pods"
        }
      },
      {
        "type": "metric",
        "x": 12, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_memory_utilization", "ClusterName", "'$CLUSTER_NAME'"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "'$AWS_REGION'",
          "title": "Memory Utilization - Pods"
        }
      }
    ]
  }' \
  --region $AWS_REGION
```

### Limpeza

```bash
aws cloudwatch delete-alarms \
  --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods" \
  --region $AWS_REGION

aws cloudwatch delete-dashboards \
  --dashboard-names "EKS-ADS-Dashboard" \
  --region $AWS_REGION

aws logs delete-log-group \
  --log-group-name $LOG_GROUP \
  --region $AWS_REGION

kubectl delete namespace amazon-cloudwatch

aws iam delete-role-policy \
  --role-name EKSNodeRole-ADS \
  --policy-name CloudWatchLogsAccess
```

## Evidencias coletadas

As evidencias foram salvas na pasta `evidencias/`.

| Arquivo | Descricao |
|---|---|
| `01-cluster-active.png` | Cluster `cluster-eks-ads` retornando `ACTIVE`. |
| `02-log-group-criado.png` | Log Group `/aws/eks/cluster-eks-ads/containers` criado no CloudWatch. |
| `03-fluent-bit-running.png` | Pods do Fluent Bit em `Running` no namespace `amazon-cloudwatch`. |
| `04-cloudwatch-log-events.png` | Eventos coletados no CloudWatch Logs via `filter-log-events`. |
| `05-container-insights-addon.png` | Addon/agent do Container Insights instalado. |
| `06-container-insights-metricas.png` | Metricas listadas no namespace `ContainerInsights`. |
| `07-kubectl-top-pods-nodes.png` | Uso de CPU/memoria dos pods e nodes. |
| `08-alarmes-ok.png` | Alarmes `EKS-ADS-*` criados e em estado `OK`. |
| `09-dashboard.png` | Dashboard CloudWatch com CPU e memoria. |
| `10-load-test.png` | Geracao de trafego com loop de requisicoes ou `load-test.sh`. |
| `11-metricas-reagindo.png` | `kubectl top pods` durante/apos carga mostrando variacao de uso. |
| `12-logs-acesso.png` | Logs recentes da aplicacao com requisicoes. |
| `13-cleanup-alarmes.png` | Confirmacao da remocao dos alarmes. |
| `14-cleanup-log-groups.png` | Confirmacao da remocao dos Log Groups. |
| `15-cleanup-namespace.png` | Namespace `amazon-cloudwatch` removido. |

## Observacoes

- A regiao utilizada no Lab014 foi `us-east-2`, conforme variaveis do laboratorio.
- A tarefa pratica da Questao 5 usa o cenario solicitado no enunciado: `us-east-1`, `producao-cluster` e namespace `minha-api`.
- A limpeza dos recursos AWS e obrigatoria para evitar custos com EKS, EC2, LoadBalancer, CloudWatch Logs, alarmes e dashboard.
