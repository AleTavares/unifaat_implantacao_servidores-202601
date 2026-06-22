# TF014 - RA 6325128

## Respostas Teóricas

### Questão 1: Três Pilares da Observabilidade

**a) Quais são os três pilares e objetivo de cada um?**
- **Logs**: registros detalhados de eventos e mensagens geradas pela aplicação e infraestrutura. Permitem entender o que aconteceu, identificar erros e auditar o comportamento.
- **Métricas**: valores numéricos agregados ao longo do tempo (CPU, memória, latência, tráfego). Permitem acompanhar a saúde do sistema em tempo real e detectar tendências.
- **Alertas**: notificações automáticas baseadas em regras ou thresholds. Permitem agir rapidamente quando algo foge do comportamento esperado.

**b) No contexto do EKS na AWS, qual serviço/ferramenta é responsável por cada pilar?**
- Logs: **CloudWatch Logs**
- Métricas: **CloudWatch Metrics** e **Container Insights**
- Alertas: **CloudWatch Alarms**

**c) Diferença entre monitoramento e observabilidade. Por que apenas monitorar não é suficiente?**
- **Monitoramento** detecta que algo está errado: métricas acima de threshold ou dashboards mostrando anomalias.
- **Observabilidade** permite entender o porquê do problema, usando logs, métricas e traces para diagnosticar causa raiz.
- Apenas monitorar não é suficiente porque indica apenas que há um problema, mas não fornece contexto ou informações suficientes para resolver a causa rapidamente.

### Questão 2: CloudWatch Logs e Fluent Bit

**a) O que é o Fluent Bit e por que ele é deployado como DaemonSet no EKS? O que um DaemonSet garante?**
- **Fluent Bit** é um agente leve de coleta e encaminhamento de logs. Ele lê logs de containers e envia para destinos como CloudWatch Logs.
- É deployado como **DaemonSet** para garantir que um pod do Fluent Bit seja executado em cada node do cluster, permitindo coletar logs locais de todos os containers.
- Um **DaemonSet** garante que cada node tenha uma instância do pod e que novos nodes também recebam automaticamente essa instância.

**b) Diferença entre Log Group e Log Stream no CloudWatch Logs.**
- **Log Group**: agrupamento lógico de streams de logs, parecido com uma pasta que organiza logs por aplicação, ambiente ou serviço.
- **Log Stream**: sequência de eventos de log dentro de um Log Group, normalmente associada a uma instância específica, pod ou container.

**c) Por que é importante configurar política de retenção nos Log Groups? O que acontece se não configurar?**
- A retenção controla por quanto tempo os logs ficam armazenados. Isso ajuda a reduzir custos e evitar acúmulo desnecessário de dados antigos.
- Se não configurar, o CloudWatch usa retenção padrão (normalmente **never expire**), o que pode gerar custos altos e consumo de armazenamento indefinido.

### Questão 3: Container Insights e Métricas

**a) Diferença entre métricas padrão do EKS e métricas do Container Insights.**
- Métricas padrão do EKS / Kubernetes são básicas e focadas em recursos do cluster: uso de CPU e memória por node/pod, status de nodes e pods.
- **Container Insights** fornece métricas avançadas por cluster, node, pod e até container, incluindo rede, disco, utilização por namespace, e métricas específicas de container.
- Container Insights adiciona visibilidade detalhada do comportamento de workloads e permite analisar problemas de performance mais rapidamente.

**b) O que é o namespace de métricas `ContainerInsights` no CloudWatch?**
- O namespace `ContainerInsights` armazena métricas coletadas pelo agente de Container Insights para clusters EKS/ECS.
- Ele inclui dados de CPU, memória, rede e disco para cluster, nodes, pods e namespaces de container.

**c) O que o comando `kubectl top pods` mostra e por que ele é útil?**
- `kubectl top pods` mostra uso de CPU e memória por pod em tempo real.
- É útil para identificar pods que consomem recursos excessivos e para comparar consumo entre pods enquanto a aplicação está em funcionamento.

### Questão 4: CloudWatch Alarms e Alertas

**a) O que são Evaluation Periods e Threshold em um CloudWatch Alarm? Por que usar mais de 1 período de avaliação?**
- **Threshold**: valor limite que dispara o alarme, por exemplo CPU média acima de 75%.
- **Evaluation Periods**: número de períodos consecutivos que devem violar o threshold para que o alarme entre em estado ALARM.
- Usar mais de 1 período evita falsos positivos causados por picos temporários ou ruído momentâneo.

**b) Cite os 4 Golden Signals do Google SRE e exemplo para o Lab014.**
- **Latência**: tempo de resposta do endpoint do site. Exemplo: P90 de requisições ao serviço `ads-site`.
- **Tráfego**: volume de requisições ao site. Exemplo: número de requisições HTTP por segundo.
- **Erros**: taxa de respostas 5xx ou mensagens `ERROR` nos logs. Exemplo: número de respostas 500 na aplicação.
- **Saturação**: quanto dos recursos do cluster está ocupado. Exemplo: porcentagem de memória ou CPU usada pelos pods.

**c) Alerta acionável vs alerta genérico. Dê exemplo.**
- **Alerta acionável**: fornece indicação clara do que deve ser feito. Exemplo: `Alarme: CPU média do deployment ads-site > 75% por 10 minutos`. A ação é escalar pods ou investigar pod problemático.
- **Alerta genérico**: não diz o que fazer nem onde olhar. Exemplo: `Alerta: sistema indisponível`. Ele gera confusão porque não indica causa nem ação imediata.

### Questão 5: Tarefa Prática - Configuração de Monitoramento

**a) Comando para criar o Log Group com retenção de 14 dias**
```bash
aws logs create-log-group \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --region us-east-1

aws logs put-retention-policy \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --retention-in-days 14 \
  --region us-east-1
```

**b) Comando para criar um CloudWatch Alarm de CPU média > 75% por 2 períodos de 5 minutos**
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name EKS-CPU-High-Producao \
  --alarm-description "Dispara quando CPU média do cluster exceder 75% em dois períodos consecutivos de 5 minutos" \
  --metric-name CPUUtilization \
  --namespace AWS/EKS \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ClusterName,Value=producao-cluster \
  --treat-missing-data missing
```

**c) Query do CloudWatch Logs Insights para contar erros na última hora agrupados a cada 10 minutos**
```text
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as errorCount by bin(10m)
| sort @timestamp asc
```

**d) Comando para listar todos os alarmes com prefixo "EKS-" em formato de tabela**
```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[*].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold}' \
  --output table
```

**e) Comando/JSON para criar um Dashboard CloudWatch com widgets de CPU e Memória**

Exemplo de comando com JSON inline:
```bash
aws cloudwatch put-dashboard \
  --dashboard-name EKS-Observability-Dashboard \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["AWS/EKS", "CPUUtilization", "ClusterName", "producao-cluster" ]
          ],
          "period": 300,
          "stat": "Average",
          "title": "CPU Média do Cluster"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["AWS/EKS", "MemoryUtilization", "ClusterName", "producao-cluster" ]
          ],
          "period": 300,
          "stat": "Average",
          "title": "Memória Média do Cluster"
        }
      }
    ]
  }'
```

## Comandos Executados no Lab014

Os comandos abaixo são os passos principais do Lab014 e da TF014.

```bash
aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'
kubectl get pods -n amazon-cloudwatch
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/cluster-eks-ads"
aws logs filter-log-events --log-group-name "/aws/eks/cluster-eks-ads/containers" --start-time $(($(date +%s) - 3600))000 --filter-pattern "ERROR"
aws cloudwatch list-metrics --namespace ContainerInsights
kubectl top pods -n ads-unifaat
kubectl top nodes
aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS"
aws cloudwatch put-dashboard --dashboard-name EKS-ADS-Dashboard --dashboard-body file://dashboard.json
kubectl logs -n ads-unifaat -l app=ads-site --tail=10
aws cloudwatch delete-alarms --alarm-names EKS-CPU-High EKS-Memory-High EKS-Error-Rate
aws logs delete-log-group --log-group-name "/aws/eks/cluster-eks-ads/containers"
kubectl delete namespace amazon-cloudwatch
```

> Observação: os nomes exatos dos alarmes e do log group podem variar conforme a implementação do Lab014.

## Descrição das Evidências Coletadas

As evidências solicitadas para o lab são:

1. **Cluster ativo**
   - Comando: `aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'`
   - Evidência: retorno `"ACTIVE"`.

2. **Log Group criado**
   - Comando: `aws logs describe-log-groups --log-group-name-prefix "/aws/eks/cluster-eks-ads"`
   - Evidência: exibição do log group criado.

3. **Fluent Bit rodando**
   - Comando: `kubectl get pods -n amazon-cloudwatch`
   - Evidência: pods do Fluent Bit em estado `Running`, um por node.

4. **Logs no CloudWatch**
   - Comando: `aws logs filter-log-events --log-group-name ...`
   - Evidência: eventos coletados e exibidos no terminal.

5. **Container Insights habilitado**
   - Evidência: addon ou agente instalado com sucesso, e métricas publicadas no namespace `ContainerInsights`.

6. **Métricas disponíveis**
   - Comando: `aws cloudwatch list-metrics --namespace ContainerInsights`
   - Evidência: lista de métricas do cluster.

7. **kubectl top**
   - Comandos: `kubectl top pods -n ads-unifaat` e `kubectl top nodes`
   - Evidência: uso de CPU e memória dos pods e nodes.

8. **Alarmes criados**
   - Comando: `aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS"`
   - Evidência: lista de 3 alarmes em estado `OK`.

9. **Dashboard criado**
   - Evidência: dashboard com gráficos de CPU e memória criado via CLI ou console.

10. **Geração de tráfego**
    - Evidência: script de load test ou loop de requisições sendo executado.

11. **Métricas reagindo**
    - Evidência: aumento de uso em `kubectl top pods` durante a carga.

12. **Logs de acesso**
    - Comando: `kubectl logs -n ads-unifaat -l app=ads-site --tail=10`
    - Evidência: requisições registradas nos logs.

13. **Limpeza**
    - Comandos: `aws cloudwatch delete-alarms`, `aws logs delete-log-group`, `kubectl delete namespace amazon-cloudwatch`
    - Evidência: confirmações de remoção dos recursos.

> Observação: neste ambiente de edição local não foi possível executar os comandos AWS/Kubernetes diretamente, então as evidências descritas acima devem ser coletadas durante a execução real do lab.

## Observações sobre Erros ou Diferenças

- Não foi possível validar os comandos com um cluster EKS ativo neste ambiente de trabalho, pois não há acesso AWS configurado via este editor.
- Os comandos e práticas descritos acima seguem o escopo do `Lab014.md` e da tarefa avaliativa `TF014.md`.
- Se surgirem erros de permissão, é importante confirmar as policies IAM necessárias: CloudWatch, EKS e IAM.
- Se o cluster `cluster-eks-ads` não existir, o `start.sh` deve ser executado para recriar o ambiente antes do Lab014.
