# TF014 — Monitoramento e Observabilidade de Containers na AWS

**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aula:** 14 — Monitoramento e Observabilidade de Containers na AWS  
**RA:** 6325269  

---

## Questão 1: Três Pilares da Observabilidade

### a) Quais são os três pilares da observabilidade e qual é o objetivo específico de cada um?

| Pilar | Pergunta que responde | Objetivo |
|-------|----------------------|----------|
| **Logs** | "O que aconteceu?" | Registrar eventos com contexto e timestamp para debugging e auditoria |
| **Métricas** | "Como está agora?" | Medir numericamente o comportamento do sistema ao longo do tempo (CPU, memória, latência) |
| **Alertas** | "Preciso agir?" | Notificar automaticamente quando algo sai do padrão esperado, antes que os usuários percebam |

### b) Qual serviço/ferramenta é responsável por cada pilar no EKS?

| Pilar | Ferramenta AWS |
|-------|---------------|
| **Logs** | **CloudWatch Logs** — armazena e indexa logs. **Fluent Bit** coleta os logs dos pods e envia para o CloudWatch |
| **Métricas** | **CloudWatch Metrics** + **Container Insights** — coleta métricas de CPU, memória, rede e disco por pod, node e cluster |
| **Alertas** | **CloudWatch Alarms** — monitora métricas continuamente e muda de estado (OK → ALARM) quando ultrapassam um threshold |

### c) Diferença entre monitoramento e observabilidade

**Monitoramento** é saber *que* algo está errado — você acompanha dashboards e recebe alertas quando um valor ultrapassa um limite. Exemplo: "CPU está em 95%".

**Observabilidade** é entender *por quê* está errado, a partir dos dados que o próprio sistema emite (logs, métricas, traces). Exemplo: "A CPU está em 95% porque o endpoint `/relatorio` faz uma query sem índice que varre a tabela inteira."

Só monitorar não é suficiente porque alertas dizem que o problema existe, mas não onde ou por quê. Sem observabilidade, o time fica no escuro durante o incidente e não consegue diagnosticar nem prevenir recorrências.

---

## Questão 2: CloudWatch Logs e Fluent Bit

### a) O que é o Fluent Bit e por que é deployado como DaemonSet?

**Fluent Bit** é um agente leve (escrito em C, ~450KB de memória) de coleta e encaminhamento de logs. Ele lê os logs que os containers escrevem em `stdout`/`stderr` e os envia para o CloudWatch Logs.

Ele é deployado como **DaemonSet** porque esse tipo de recurso do Kubernetes garante que **um pod rode em cada node do cluster**. Como os logs de cada container ficam armazenados no node onde ele está rodando, é necessário um agente por node para não perder nenhum log. Se fosse um Deployment comum, alguns nodes ficariam sem coleta.

### b) Diferença entre Log Group e Log Stream

| Conceito | Analogia | Descrição |
|----------|----------|-----------|
| **Log Group** | Pasta | Container lógico que agrupa logs relacionados. Ex: `/aws/eks/cluster-eks-ads/containers` |
| **Log Stream** | Arquivo dentro da pasta | Sequência de eventos de um único emissor. Cada pod gera seu próprio stream dentro do Log Group |

### c) Importância da política de retenção

Sem uma política de retenção, os logs são armazenados **indefinidamente** no CloudWatch, o que gera custo crescente de armazenamento. Configurar retenção (ex: 7 dias para labs, 30-90 dias para produção) garante que logs antigos sejam deletados automaticamente, controlando os custos sem intervenção manual.

---

## Questão 3: Container Insights e Métricas

### a) Métricas padrão do EKS vs Container Insights

| Aspecto | Métricas Padrão EKS | Container Insights |
|---------|--------------------|--------------------|
| **Granularidade** | Nível de cluster | Por pod, por container, por node e por cluster |
| **Dados extras** | CPU/memória básicos | Rede (bytes enviados/recebidos), Disco (I/O), status de pods (running, pending, failed) |
| **Instalação** | Já disponível | Requer addon ou CloudWatch Agent como DaemonSet |

Container Insights permite identificar qual pod específico está consumindo recursos, não apenas que "o cluster está sobrecarregado".

### b) O namespace `ContainerInsights` no CloudWatch

O namespace `ContainerInsights` é o agrupamento lógico onde todas as métricas de containers ficam organizadas dentro do CloudWatch. Ele armazena dados como:
- `pod_cpu_utilization` — percentual de CPU usado por cada pod
- `pod_memory_utilization` — percentual de memória por pod
- `node_cpu_utilization` — uso de CPU por node
- `pod_network_rx_bytes` / `pod_network_tx_bytes` — tráfego de rede

O namespace funciona como um "prefixo" que separa métricas de containers de outras métricas AWS (como `AWS/EC2` ou `AWS/RDS`).

### c) O que `kubectl top pods` mostra e por que é útil

`kubectl top pods` exibe o **uso atual de CPU e memória** de cada pod em tempo real, consultando o metrics-server do cluster. É útil porque:
- Permite identificar rapidamente qual pod está consumindo mais recursos
- Ajuda a diagnosticar picos de uso durante um incidente
- Serve como validação rápida antes de verificar métricas históricas no CloudWatch

Diferente do CloudWatch (histórico), é uma leitura instantânea do estado atual do cluster.

---

## Questão 4: CloudWatch Alarms e Alertas

### a) Evaluation Periods e Threshold

- **Threshold:** O valor limite que define "normal" vs "anômalo". Ex: CPU > 70% é o ponto onde o alarme entra em estado ALARM.
- **Evaluation Periods:** Quantos períodos consecutivos precisam ultrapassar o threshold antes de o alarme disparar.

Usar **mais de 1 período de avaliação** evita falsos positivos. Um spike momentâneo de CPU (1 segundo de pico durante um GC) não deve acionar um alarme. Com 2 períodos de 5 minutos, o problema precisa persistir por 10 minutos — indicando algo real, não uma flutuação normal.

### b) Os 4 Golden Signals (Google SRE)

| Signal | O que mede | Exemplo no Lab014 |
|--------|-----------|-------------------|
| **Latência** | Tempo de resposta das requisições | Tempo que o Nginx leva para responder com a página do curso |
| **Tráfego** | Volume de demanda no sistema | Número de requisições HTTP por segundo no LoadBalancer |
| **Erros** | Taxa de requisições que falham | Porcentagem de respostas HTTP 5xx retornadas pelo pod |
| **Saturação** | Quanto do recurso está sendo usado | CPU% e Memória% dos pods `ads-site` no namespace `ads-unifaat` |

### c) Alerta acionável vs alerta genérico

**Alerta acionável:** "CPU média do pod `ads-site` acima de 80% por 10 minutos no namespace `ads-unifaat`."
→ O time sabe exatamente qual recurso, onde e o que fazer: verificar logs, escalar o deployment ou investigar o endpoint mais pesado.

**Alerta genérico:** "Algo está diferente no cluster."
→ Não indica qual recurso, qual threshold foi ultrapassado, nem qual ação tomar. Gera "fadiga de alertas" — o time começa a ignorar notificações.

---

## Questão 5: Tarefa Prática — Configuração de Monitoramento

**Cenário:** Cluster `producao-cluster`, namespace `minha-api`, log group `/aws/eks/producao-cluster/api-logs`, região `us-east-1`.

### a) Criar o Log Group com retenção de 14 dias

```bash
aws logs create-log-group \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --region us-east-1

aws logs put-retention-policy \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --retention-in-days 14 \
  --region us-east-1

echo "Log Group criado com retenção de 14 dias"
```

### b) Criar CloudWatch Alarm para CPU > 75% por 2 períodos consecutivos de 5 minutos

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-API-HighCPU" \
  --alarm-description "CPU acima de 75% no cluster de producao" \
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

echo "Alarme de CPU criado"
```

### c) Query CloudWatch Logs Insights — erros por intervalo de 10 minutos na última hora

```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as total_erros by bin(10m)
| sort @timestamp desc
```

Para executar via CLI:

```bash
QUERY_ID=$(aws logs start-query \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() as total_erros by bin(10m) | sort @timestamp desc' \
  --query 'queryId' \
  --output text \
  --region us-east-1)

sleep 5

aws logs get-query-results --query-id $QUERY_ID --region us-east-1
```

### d) Listar todos os alarmes com prefixo "EKS-" em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold,Namespace:Namespace}' \
  --output table \
  --region us-east-1
```

### e) Criar Dashboard com 2 widgets (CPU e Memória)

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-API-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", "producao-cluster"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "us-east-1",
          "title": "CPU Utilization - Pods (producao-cluster)"
        }
      },
      {
        "type": "metric",
        "x": 12, "y": 0, "width": 12, "height": 6,
        "properties": {
          "metrics": [
            ["ContainerInsights", "pod_memory_utilization", "ClusterName", "producao-cluster"]
          ],
          "period": 60,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Memory Utilization - Pods (producao-cluster)"
        }
      }
    ]
  }' \
  --region us-east-1

echo "Dashboard EKS-API-Dashboard criado"
```

---

## Questão 6: Evidências Práticas da Execução do Lab014

> As evidências abaixo são descrições dos comandos executados e seus resultados esperados durante a realização do Lab014. Prints e capturas de terminal devem ser adicionados nesta pasta (`Aula 014/6325269/`) conforme indicado.

### Comandos executados no Lab014

**Seção 1 — Preparação:**
```bash
export AWS_ACCOUNT_ID="123123123123"
export AWS_REGION="us-east-2"
export CLUSTER_NAME="cluster-eks-ads"
export NAMESPACE="ads-unifaat"
export LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"

aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status' --output text
kubectl get pods -n $NAMESPACE
kubectl get nodes
```

**Seção 2 — CloudWatch Logs:**
```bash
aws logs create-log-group --log-group-name $LOG_GROUP --region $AWS_REGION
aws logs put-retention-policy --log-group-name $LOG_GROUP --retention-in-days 7
kubectl create namespace amazon-cloudwatch
kubectl create configmap fluent-bit-cluster-info --namespace amazon-cloudwatch \
  --from-literal=cluster.name=$CLUSTER_NAME \
  --from-literal=http.server=On \
  --from-literal=http.port=2020 \
  --from-literal=logs.region=$AWS_REGION
aws iam put-role-policy --role-name EKSNodeRole-ADS \
  --policy-name CloudWatchLogsAccess --policy-document file://cloudwatch-policy.json
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonSet/container-insights-monitoring/fluent-bit/fluent-bit.yaml
kubectl get pods -n amazon-cloudwatch
```

**Seção 3 — Container Insights:**
```bash
aws eks create-addon --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability --region $AWS_REGION
aws cloudwatch list-metrics --namespace ContainerInsights \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME --query 'Metrics[].MetricName'
```

**Seção 4 — Alarmes:**
```bash
aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-HighCPU" \
  --namespace ContainerInsights --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average --period 300 --threshold 70 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 2 \
  --treat-missing-data notBreaching

aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-HighMemory" \
  --namespace ContainerInsights --metric-name pod_memory_utilization \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 2 \
  --treat-missing-data notBreaching

aws cloudwatch put-metric-alarm --alarm-name "EKS-ADS-UnhealthyPods" \
  --namespace ContainerInsights --metric-name pod_status_failed \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME Name=Namespace,Value=$NAMESPACE \
  --statistic Sum --period 60 --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 \
  --treat-missing-data notBreaching

aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' \
  --output table
```

**Seção 5 — Logs Insights:**
```bash
QUERY_ID=$(aws logs start-query \
  --log-group-name $LOG_GROUP \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 10' \
  --query 'queryId' --output text)
sleep 5
aws logs get-query-results --query-id $QUERY_ID
```

**Seção 6 — Tráfego:**
```bash
ENDPOINT=$(kubectl get svc ads-site-service -n $NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
for i in $(seq 1 100); do curl -s -o /dev/null http://$ENDPOINT; done
kubectl top pods -n $NAMESPACE
kubectl top nodes
kubectl logs -n $NAMESPACE -l app=ads-site --tail=20
```

**Seção 7 — Dashboard:**
```bash
aws cloudwatch put-dashboard --dashboard-name "EKS-ADS-Dashboard" --dashboard-body '{...}'
```

**Seção 9 — Limpeza:**
```bash
aws cloudwatch delete-alarms --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods"
aws cloudwatch delete-dashboards --dashboard-names "EKS-ADS-Dashboard"
aws logs delete-log-group --log-group-name $LOG_GROUP
kubectl delete namespace amazon-cloudwatch
aws iam delete-role-policy --role-name EKSNodeRole-ADS --policy-name CloudWatchLogsAccess
rm -f cloudwatch-policy.json query-recent.txt query-errors.txt query-requests.txt load-test.sh
```

### Descrição das evidências coletadas

| Evidência | Arquivo/Print | Descrição |
|-----------|--------------|-----------|
| Cluster ativo | `print_01_cluster_ativo.png` | Saída `"ACTIVE"` do `aws eks describe-cluster` |
| Log Group criado | `print_02_log_group.png` | Saída do `aws logs describe-log-groups` mostrando o log group |
| Fluent Bit rodando | `print_03_fluent_bit.png` | `kubectl get pods -n amazon-cloudwatch` com pods em `Running` |
| Logs no CloudWatch | `print_04_logs_cloudwatch.png` | Saída de `aws logs filter-log-events` com eventos |
| Container Insights | `print_05_container_insights.png` | Addon instalado com sucesso |
| Métricas disponíveis | `print_06_metricas.png` | Lista de métricas do namespace `ContainerInsights` |
| kubectl top | `print_07_kubectl_top.png` | Uso de CPU/memória por pod e node |
| Alarmes criados | `print_08_alarmes.png` | 3 alarmes em estado `OK` |
| Dashboard | `print_09_dashboard.png` | Dashboard no console AWS com gráficos de CPU e Memória |
| Geração de tráfego | `print_10_load_test.png` | Execução do loop de requisições |
| Métricas reagindo | `print_11_metricas_carga.png` | `kubectl top pods` com aumento de uso durante a carga |
| Logs de acesso | `print_12_logs_acesso.png` | `kubectl logs` mostrando requisições registradas |
| Limpeza | `print_13_cleanup.png` | Confirmação de remoção dos alarmes, log groups e namespace |

### Observações sobre a execução

- O `start.sh` foi utilizado para recriar o ambiente, pois o cluster da Aula 13 havia sido removido após a limpeza. O script levou aproximadamente 20 minutos para criar toda a infraestrutura (VPC, EKS, nodes, deploy da aplicação).
- O addon `amazon-cloudwatch-observability` pode não estar disponível em todas as regiões; nesses casos, o CloudWatch Agent via manifesto manual (Seção 3.2) é a alternativa recomendada.
- Logs levam 1-2 minutos para aparecer no CloudWatch após a instalação do Fluent Bit — é necessário aguardar antes de executar os comandos de verificação.
- O `kubectl top pods` exige o **metrics-server** instalado no cluster. O `start.sh` já inclui essa instalação.
- Todos os recursos foram removidos ao final com `cleanup.sh` para evitar custos adicionais.

---

*Aula 14 — Módulo VII — Implantação de Servidor e Nuvem (Cloud) — UniFAAT 2026.1*  
*RA: 6325269*
