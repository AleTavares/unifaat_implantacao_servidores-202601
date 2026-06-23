# 1A
Logs: detalham o que aconteceu.
Métricas: mostram como o sistema está se comportando.
Traces: revelam onde e como uma requisição percorreu o sistema.

# B

Logs → CloudWatch Logs
Métricas → CloudWatch / Prometheus
Traces → AWS X-Ray (ou OpenTelemetry integrado ao X-Ray)

# C 
Monitoramento: detecta que algo está errado.
Observabilidade: ajuda a entender por que está errado e como corrigir.
Por isso, apenas monitorar não é suficiente para diagnosticar rapidamente problemas complexos em ambientes modernos.

# 2 A
Fluent Bit: coleta, processa e envia logs.
DaemonSet: garante a execução de um Pod em cada nó do cluster.
Benefício: todos os logs dos containers do EKS são coletados automaticamente, inclusive quando novos nós são adicionados ao cluster.

# B
Conceito	Função
Log Group	Agrupa logs relacionados a uma aplicação, serviço ou ambiente.
Log Stream	Contém os eventos de log de uma fonte específica (pod, container, instância etc.).

# C
Política de retenção: define por quanto tempo os logs serão mantidos.
Benefícios: redução de custos, conformidade e melhor gerenciamento dos dados.
Sem configuração: os logs ficam armazenados indefinidamente, aumentando o uso de armazenamento e os gastos no CloudWatch.

# 3A
Métricas Padrão do EKS	Container Insights
Visão geral do cluster	Visão detalhada de pods, containers e nodes
Monitoramento básico	Observabilidade aprofundada
Menos granularidade	Métricas detalhadas por workload
Saúde do cluster	Saúde do cluster + aplicações

Conclusão: o Container Insights complementa as métricas padrão do EKS ao fornecer visibilidade detalhada do ambiente Kubernetes, facilitando a identificação de gargalos, falhas e problemas de desempenho nas aplicações.

# B
O namespace ContainerInsights é o local onde o CloudWatch armazena métricas detalhadas de observabilidade de ambientes Kubernetes/EKS, incluindo dados de clusters, nodes, pods, containers e workloads, fornecendo uma visão muito mais granular do que as métricas padrão do EKS.

# C

O comando kubectl top pods exibe o consumo atual de CPU e memória de cada Pod do cluster. Ele é útil para monitoramento em tempo real porque permite identificar rapidamente pods com alto consumo de recursos e auxiliar no diagnóstico e resolução de problemas de desempenho.

# 4 A
Threshold: valor limite da métrica (ex.: CPU > 80%).
Evaluation Periods: quantidade de períodos analisados antes de disparar o alarme.
Usar mais de 1 período: ajuda a evitar falsos alarmes e garante que o problema seja consistente antes de gerar uma notificação.

# B
Golden Signal	O que mede	Exemplo prático
Latência	Tempo de resposta	API respondendo em 3 segundos
Tráfego	Volume de requisições	1.000 requisições/minuto
Erros	Taxa de falhas	HTTP 500 ou falha no banco
Saturação	Uso de recursos	CPU acima de 90% nos Pods

Esses quatro sinais ajudam a identificar rapidamente problemas de desempenho, disponibilidade e capacidade da aplicação executando no EKS.

# C
✅ Acionável:

"Taxa de erros HTTP 500 acima de 5% nos últimos 10 minutos no serviço API."

❌ Genérico:

"Aplicação apresentando problemas."

Conclusão: Um alerta deve ser acionável, ou seja, fornecer contexto suficiente para que a equipe saiba rapidamente o que está acontecendo e qual ação tomar. Isso reduz o tempo de diagnóstico e melhora a confiabilidade operacional.

# 5 A

aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --region us-east-1

aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14 \
  --region us-east-1

# B
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPU-Producao-Cluster" \
  --alarm-description "Alerta quando CPU media exceder 75% por 10 minutos" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ClusterName,Value=producao-cluster \
  --region us-east-1

# C

fields @timestamp, @message
| filter @message like /ERROR/
| stats count(*) as total_erros by bin(10m)
| sort bin(10m) asc

# D

aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --region us-east-1 \
  --query 'MetricAlarms[*].[AlarmName,StateValue,MetricName,Namespace,Threshold]' \
  --output table

# E

aws cloudwatch put-dashboard \
  --dashboard-name "EKS-Producao-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title": "CPU Utilization - Cluster producao-cluster",
          "view": "timeSeries",
          "region": "us-east-1",
          "metrics": [
            [
              "ContainerInsights",
              "cluster_cpu_utilization",
              "ClusterName",
              "producao-cluster"
            ]
          ],
          "stat": "Average",
          "period": 300
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title": "Memory Utilization - Cluster producao-cluster",
          "view": "timeSeries",
          "region": "us-east-1",
          "metrics": [
            [
              "ContainerInsights",
              "cluster_memory_utilization",
              "ClusterName",
              "producao-cluster"
            ]
          ],
          "stat": "Average",
          "period": 300
        }
      }
    ]
  }'