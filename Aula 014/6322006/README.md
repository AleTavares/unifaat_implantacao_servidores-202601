# TF014 - Monitoramento e Observabilidade de Containers na AWS

**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aula:** 14 - Monitoramento e Observabilidade de Containers na AWS  
**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Prazo de Entrega:** 23/06/2026 às 23:59

---

## Questão 1: Três Pilares da Observabilidade (Teórica)

### a) Quais são os três pilares da observabilidade e qual é o objetivo específico de cada um?

| Pilar | Objetivo |
|-------|---------|
| **Logs** | Registrar eventos discretos e detalhados que ocorrem no sistema ao longo do tempo. Respondem à pergunta "O que aconteceu e quando?". Permitem reconstruir a sequência exata de eventos que levou a um problema, incluindo mensagens de erro, stack traces e dados contextuais. |
| **Métricas** | Capturar valores numéricos que representam o comportamento do sistema em um determinado instante ou intervalo. Respondem à pergunta "Como o sistema está agora?". São ideais para detectar tendências, anomalias e comparar o estado atual com uma baseline. |
| **Alertas** | Notificar automaticamente as equipes quando um indicador ultrapassa um threshold definido. Respondem à pergunta "Preciso agir agora?". Transformam dados passivos (métricas e logs) em ações proativas, reduzindo o tempo de resposta a incidentes. |

### b) No contexto do EKS na AWS, qual serviço/ferramenta é responsável por cada pilar?

| Pilar | Ferramenta AWS |
|-------|---------------|
| **Logs** | **CloudWatch Logs** + **Fluent Bit** (DaemonSet no EKS que coleta stdout/stderr dos containers e encaminha para o CloudWatch Logs) |
| **Métricas** | **CloudWatch Metrics** + **Container Insights** (addon que coleta métricas detalhadas de CPU, memória, rede e disco por pod, node e cluster) |
| **Alertas** | **CloudWatch Alarms** (monitora métricas e dispara ações via SNS, Auto Scaling ou Lambda quando thresholds são violados) |

### c) Explique a diferença entre monitoramento e observabilidade. Por que apenas monitorar não é suficiente?

**Monitoramento** é o processo de coletar e exibir métricas e estados previamente definidos de um sistema. É reativo: você sabe *que* algo está errado (ex: "CPU está em 95%"), mas não sabe *por quê*.

**Observabilidade** é a capacidade de inferir o estado interno de um sistema a partir dos dados que ele emite — logs, métricas e traces. É proativa: permite descobrir a causa raiz sem precisar ter previsto o problema antecipadamente. Permite responder "A CPU está alta porque o endpoint `/search` executa uma query sem índice no banco de dados."

Apenas monitorar não é suficiente porque sistemas modernos são distribuídos e complexos. Um alarme de CPU alta não explica qual pod, qual container, qual chamada de função ou qual usuário causou o problema. Sem observabilidade, a equipe fica cega na investigação, aumentando o tempo de resolução (MTTR).

---

## Questão 2: CloudWatch Logs e Fluent Bit (Teórica)

### a) O que é o Fluent Bit e por que ele é deployado como DaemonSet no EKS? O que um DaemonSet garante?

**Fluent Bit** é um coletor e encaminhador de logs leve, open-source, escrito em C. Ele captura os logs gerados pelos containers (via stdout/stderr), processa e encaminha para destinos como o CloudWatch Logs. Consome apenas ~450KB de memória, sendo muito mais eficiente que alternativas como o Fluentd (~40MB).

É deployado como **DaemonSet** porque um DaemonSet garante que exatamente **um pod seja executado em cada node do cluster**. Isso é essencial para coleta de logs porque:

- Cada node hospeda múltiplos pods/containers;
- O Fluent Bit lê os arquivos de log diretamente do sistema de arquivos do node (`/var/log/containers/`);
- Se um node for adicionado ao cluster (ex: auto scaling), o DaemonSet automaticamente instancia um novo pod Fluent Bit nele;
- Nenhum node fica sem cobertura de coleta de logs.

### b) Explique a diferença entre Log Group e Log Stream no CloudWatch Logs.

| Conceito | Definição | Exemplo |
|---------|-----------|---------|
| **Log Group** | Container lógico de alto nível que agrupa streams relacionados. Define políticas como retenção, criptografia e permissões de acesso. É como uma "pasta". | `/aws/eks/cluster-eks-ads/application` |
| **Log Stream** | Sequência ordenada cronologicamente de eventos de log dentro de um Log Group. Representa uma fonte específica de logs. É como um "arquivo dentro da pasta". | `ads-unifaat/ads-site/abc123pod` |

Um Log Group pode conter centenas de Log Streams. No EKS com Fluent Bit, cada container gera seu próprio Log Stream, organizados dentro do Log Group do cluster.

### c) Por que é importante configurar uma política de retenção nos Log Groups? O que acontece se não configurar?

Configurar a política de retenção é importante porque:

- **Custo:** O CloudWatch Logs cobra por GB armazenado. Logs acumulados indefinidamente geram custos crescentes;
- **Compliance:** Regulamentações como LGPD e GDPR podem exigir que certos logs sejam mantidos por períodos específicos e depois descartados;
- **Praticidade:** Logs muito antigos raramente são consultados e dificultam a navegação.

Se **não configurar** a retenção, o padrão é **retenção indefinida (Never Expire)**. Isso significa que os logs acumulam para sempre, o custo de armazenamento cresce continuamente sem limite, e pode levar a surpresas na fatura AWS ao final do mês.

Valores típicos: 7 dias para logs de debug, 30 dias para logs de aplicação, 90-365 dias para logs de auditoria.

---

## Questão 3: Container Insights e Métricas (Teórica)

### a) Qual é a diferença entre as métricas padrão do EKS e as métricas do Container Insights?

| Aspecto | Métricas Padrão EKS | Container Insights |
|---------|--------------------|--------------------|
| **Granularidade** | Nível de cluster e node | Pod, container, node e cluster |
| **Métricas de CPU/Memória** | Apenas por node | Por pod e por container individualmente |
| **Rede** | Não disponível por padrão | Bytes enviados/recebidos por pod |
| **Disco** | Não disponível por padrão | I/O de disco por node |
| **Status de pods** | Não disponível | Pods running, pending, failed |
| **Custo** | Incluído no EKS | Custo adicional do CloudWatch |

O Container Insights permite identificar qual pod específico está consumindo recursos excessivos, algo impossível com as métricas padrão do EKS.

### b) Explique o que é o namespace de métricas ContainerInsights no CloudWatch e que tipo de dados ele armazena.

O **namespace** no CloudWatch é um agrupamento lógico de métricas de uma mesma origem ou serviço. O namespace `ContainerInsights` é criado automaticamente quando o addon Container Insights é habilitado no cluster EKS.

Ele armazena métricas no formato de **dimensões hierárquicas**, permitindo filtrar por:
- `ClusterName` → `NodeName` → `Namespace` → `PodName` → `ContainerName`

Tipos de dados armazenados:
- `pod_cpu_utilization` — utilização de CPU por pod (%)
- `pod_memory_utilization` — uso de memória por pod (%)
- `pod_network_rx_bytes` / `pod_network_tx_bytes` — tráfego de rede
- `node_cpu_utilization` — CPU total do node
- `node_memory_utilization` — memória total do node
- `cluster_node_count` — número de nodes ativos
- `cluster_failed_node_count` — nodes em falha

### c) O que o comando `kubectl top pods` mostra e por que ele é útil para monitoramento em tempo real?

O comando `kubectl top pods` exibe o **uso atual de CPU e memória** de cada pod em execução, em tempo real. Exemplo de saída:

```
NAME                        CPU(cores)   MEMORY(bytes)
ads-site-7d4f9c-abc12       15m          128Mi
ads-site-7d4f9c-def34       22m          135Mi
```

- **CPU(cores):** uso em millicores (1000m = 1 vCPU)
- **MEMORY(bytes):** uso em Mi (mebibytes)

É útil para monitoramento em tempo real porque:
- Permite identificar rapidamente pods com consumo anormal sem precisar acessar o console AWS;
- Ajuda a detectar memory leaks (memória crescendo progressivamente);
- Complementa os alarmes do CloudWatch com visibilidade imediata durante um incidente;
- É essencial durante testes de carga para observar o comportamento dos pods sob pressão.

---

## Questão 4: CloudWatch Alarms e Alertas (Teórica)

### a) Explique o que são Evaluation Periods e Threshold em um CloudWatch Alarm. Por que usar mais de 1 período de avaliação?

**Threshold** é o valor limite que define quando uma métrica está em estado anormal. Por exemplo: "CPU > 70%" significa que qualquer valor acima de 70% viola o threshold.

**Evaluation Periods** é o número de períodos consecutivos (ou não) que o CloudWatch avalia antes de mudar o estado do alarme. Cada período tem uma duração definida (ex: 5 minutos).

**Por que usar mais de 1 período?** Para evitar **falsos positivos**. Um pico momentâneo de CPU (ex: uma requisição pesada isolada) não deve disparar um alarme de produção. Se o alarme exige 2 períodos consecutivos de 5 minutos acima do threshold, ele só dispara se a CPU ficar alta por pelo menos 10 minutos — indicando um problema real, não um spike passageiro. Isso reduz o "alarme fatigue" nas equipes de operação.

### b) Cite os 4 Golden Signals definidos pelo Google SRE e dê um exemplo prático de cada um para a aplicação do Lab014.

Os **4 Golden Signals** são definidos no livro "Site Reliability Engineering" do Google como as métricas mais importantes para qualquer serviço:

| Signal | O que mede | Exemplo para o Lab014 (ads-site no EKS) |
|--------|-----------|----------------------------------------|
| **Latência** | Tempo de resposta das requisições (incluindo requisições com erro) | Tempo médio de resposta do endpoint principal do ads-site (P99 > 2s indica problema) |
| **Tráfego** | Volume de demanda no sistema | Número de requisições por segundo recebidas pelo LoadBalancer do cluster EKS |
| **Erros** | Taxa de requisições que falham | Percentual de respostas HTTP 5xx retornadas pelo ads-site (> 1% dispara alerta) |
| **Saturação** | Quanto dos recursos limitantes estão sendo usados | CPU e memória dos pods `ads-site` — quando CPU > 80% por 10 min, escalar horizontalmente |

### c) O que é um alerta acionável vs um alerta genérico? Dê um exemplo de cada.

**Alerta genérico:** Notifica que algo está errado, mas não indica o que fazer.

> Exemplo: "CPU alta no cluster EKS" — não diz qual pod, qual namespace, qual ação tomar.

**Alerta acionável:** Contém contexto suficiente (quem, o quê, onde, como resolver) para que o responsável de plantão tome uma ação imediata sem investigação adicional.

> Exemplo: "ALARME: Pod `ads-site` no namespace `ads-unifaat` (cluster `cluster-eks-ads`, região `us-east-2`) com CPU em 92% por 10 minutos consecutivos. Ação: verificar `kubectl describe pod` e considerar `kubectl scale deployment ads-site --replicas=3`. Runbook: [link]"

Um bom alerta acionável reduz o MTTR (Mean Time To Resolution) e evita que a equipe acorde às 3h da manhã sem saber o que fazer.

---

## Questão 5: Tarefa Prática - Configuração de Monitoramento (Simulação)

**Cenário:**
- Cluster: `producao-cluster`
- Namespace: `minha-api`
- Log Group: `/aws/eks/producao-cluster/api-logs`
- Região: `us-east-1`

### a) Criar o Log Group com retenção de 14 dias

```bash
# Criar o Log Group
aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --region us-east-1

# Definir política de retenção de 14 dias
aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14 \
  --region us-east-1

# Verificar se foi criado corretamente
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/eks/producao-cluster" \
  --region us-east-1
```

### b) Criar um CloudWatch Alarm de CPU que dispare quando exceder 75% por 2 períodos consecutivos de 5 minutos

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-producao-cluster-CPU-Alta" \
  --alarm-description "CPU média do cluster producao-cluster excedeu 75% por 10 minutos" \
  --namespace "ContainerInsights" \
  --metric-name "pod_cpu_utilization" \
  --dimensions Name=ClusterName,Value=producao-cluster \
               Name=Namespace,Value=minha-api \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --datapoints-to-alarm 2 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching \
  --region us-east-1
```

> **Explicação dos parâmetros:**
> - `--period 300` → período de 300 segundos (5 minutos)
> - `--evaluation-periods 2` → avalia 2 períodos consecutivos
> - `--datapoints-to-alarm 2` → ambos os períodos devem violar o threshold
> - `--threshold 75` → dispara quando CPU > 75%

### c) Query do CloudWatch Logs Insights para contar erros da última hora agrupados por intervalos de 10 minutos

```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count(*) as total_erros by bin(10m)
| sort @timestamp asc
```

> **Como executar via CLI:**
> ```bash
> aws logs start-query \
>   --log-group-name "/aws/eks/producao-cluster/api-logs" \
>   --start-time $(date -d '1 hour ago' +%s) \
>   --end-time $(date +%s) \
>   --query-string "fields @timestamp, @message | filter @message like /ERROR/ | stats count(*) as total_erros by bin(10m) | sort @timestamp asc" \
>   --region us-east-1
> ```

### d) Listar todos os alarmes com prefixo "EKS-" em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[*].{Nome:AlarmName, Estado:StateValue, Metrica:MetricName, Threshold:Threshold}' \
  --output table \
  --region us-east-1
```

> Saída esperada:
> ```
> -----------------------------------------------------------------------
> |                         DescribeAlarms                              |
> +---------------------------------+--------+-------------+-----------+
> |              Nome               | Estado |   Metrica   | Threshold |
> +---------------------------------+--------+-------------+-----------+
> |  EKS-producao-cluster-CPU-Alta  | OK     | pod_cpu_... |  75.0     |
> +---------------------------------+--------+-------------+-----------+
> ```

### e) Criar um Dashboard CloudWatch com 2 widgets: CPU e Memória do cluster

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-producao-cluster-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title": "CPU do Cluster - producao-cluster",
          "metrics": [
            ["ContainerInsights", "pod_cpu_utilization",
             "ClusterName", "producao-cluster",
             "Namespace", "minha-api"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "view": "timeSeries",
          "yAxis": {"left": {"min": 0, "max": 100}},
          "annotations": {
            "horizontal": [{"value": 75, "label": "Threshold 75%", "color": "#ff0000"}]
          }
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title": "Memória do Cluster - producao-cluster",
          "metrics": [
            ["ContainerInsights", "pod_memory_utilization",
             "ClusterName", "producao-cluster",
             "Namespace", "minha-api"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "view": "timeSeries",
          "yAxis": {"left": {"min": 0, "max": 100}},
          "annotations": {
            "horizontal": [{"value": 80, "label": "Threshold 80%", "color": "#ff6600"}]
          }
        }
      }
    ]
  }' \
  --region us-east-1
```

> **Estrutura do Dashboard:**
> - Widget 1 (esquerda): Gráfico de série temporal da métrica `pod_cpu_utilization` com linha de threshold em 75%
> - Widget 2 (direita): Gráfico de série temporal da métrica `pod_memory_utilization` com linha de threshold em 80%
> - Ambos com período de agregação de 5 minutos e estatística de média

---

## Questão 6: Evidências Práticas da Execução do Lab014

> **Nota:** As evidências abaixo foram coletadas durante a execução do Lab014 seguindo os passos do arquivo `Lab014.md`. Os prints/capturas de terminal estão organizados por parte conforme solicitado.

### Parte 1: Preparação e Logs

**1. Cluster ativo:**
```bash
aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'
```
*Print: [evidencia-01-cluster-ativo.png]*

**2. Log Group criado:**
```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/cluster-eks-ads"
```
*Print: [evidencia-02-log-group.png]*

**3. Fluent Bit rodando:**
```bash
kubectl get pods -n amazon-cloudwatch
```
*Print: [evidencia-03-fluent-bit-running.png]*

**4. Logs no CloudWatch:**
```bash
aws logs filter-log-events \
  --log-group-name "/aws/eks/cluster-eks-ads/application" \
  --limit 10
```
*Print: [evidencia-04-logs-cloudwatch.png]*

### Parte 2: Métricas e Container Insights

**1. Container Insights habilitado:**
```bash
kubectl get daemonset -n amazon-cloudwatch
```
*Print: [evidencia-05-container-insights.png]*

**2. Métricas disponíveis:**
```bash
aws cloudwatch list-metrics --namespace ContainerInsights \
  --dimensions Name=ClusterName,Value=cluster-eks-ads
```
*Print: [evidencia-06-metricas-container-insights.png]*

**3. kubectl top:**
```bash
kubectl top pods -n ads-unifaat
kubectl top nodes
```
*Print: [evidencia-07-kubectl-top.png]*

### Parte 3: Alarmes e Dashboard

**1. Alarmes criados:**
```bash
aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS"
```
*Print: [evidencia-08-alarmes.png]*

**2. Dashboard criado:**
```bash
aws cloudwatch list-dashboards
```
*Print: [evidencia-09-dashboard.png]*

### Parte 4: Tráfego e Observação

**1. Geração de tráfego:**
```bash
# Loop de requisições para gerar carga
for i in $(seq 1 100); do
  curl -s http://<LOAD_BALANCER_URL>/ > /dev/null
  echo "Requisição $i enviada"
done
```
*Print: [evidencia-10-load-test.png]*

**2. Métricas reagindo:**
```bash
kubectl top pods -n ads-unifaat
```
*Print: [evidencia-11-metricas-durante-carga.png]*

**3. Logs de acesso:**
```bash
kubectl logs -n ads-unifaat -l app=ads-site --tail=10
```
*Print: [evidencia-12-logs-acesso.png]*

### Parte 5: Limpeza

**1. Alarmes removidos:**
```bash
aws cloudwatch delete-alarms \
  --alarm-names "EKS-ADS-CPU-Alta" "EKS-ADS-Memoria-Alta" "EKS-ADS-Erros"
```
*Print: [evidencia-13-alarmes-removidos.png]*

**2. Log Groups removidos:**
```bash
aws logs delete-log-group \
  --log-group-name "/aws/eks/cluster-eks-ads/application"
aws logs delete-log-group \
  --log-group-name "/aws/eks/cluster-eks-ads/dataplane"
```
*Print: [evidencia-14-log-groups-removidos.png]*

**3. Namespace removido:**
```bash
kubectl delete namespace amazon-cloudwatch
```
*Print: [evidencia-15-namespace-removido.png]*

---

## Comandos Executados no Lab014

Sequência completa de comandos executados durante o laboratório:

```bash
# 1. Verificar cluster ativo
aws eks describe-cluster --name cluster-eks-ads --query 'cluster.status'
kubectl get pods -n ads-unifaat

# 2. Criar Log Group e definir retenção
aws logs create-log-group --log-group-name "/aws/eks/cluster-eks-ads/application"
aws logs put-retention-policy \
  --log-group-name "/aws/eks/cluster-eks-ads/application" \
  --retention-in-days 7

# 3. Instalar Fluent Bit como DaemonSet
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
kubectl get pods -n amazon-cloudwatch

# 4. Habilitar Container Insights
aws eks create-addon \
  --cluster-name cluster-eks-ads \
  --addon-name amazon-cloudwatch-observability

# 5. Verificar métricas
aws cloudwatch list-metrics --namespace ContainerInsights
kubectl top pods -n ads-unifaat
kubectl top nodes

# 6. Criar alarmes
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-CPU-Alta" \
  --namespace "ContainerInsights" \
  --metric-name "pod_cpu_utilization" \
  --dimensions Name=ClusterName,Value=cluster-eks-ads \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold

# 7. Criar Dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-ADS-Dashboard" \
  --dashboard-body file://dashboard.json

# 8. Gerar tráfego e observar
for i in $(seq 1 100); do curl -s http://<LB_URL>/; done
kubectl top pods -n ads-unifaat
kubectl logs -n ads-unifaat -l app=ads-site --tail=10

# 9. Limpeza
aws cloudwatch delete-alarms --alarm-names "EKS-ADS-CPU-Alta" "EKS-ADS-Memoria-Alta"
aws logs delete-log-group --log-group-name "/aws/eks/cluster-eks-ads/application"
kubectl delete namespace amazon-cloudwatch
```

---

## Observações sobre a Execução

- O ambiente foi preparado utilizando o `start.sh` para recriar a infraestrutura EKS após a limpeza da Aula 13.
- O comando `kubectl top` requer que o Metrics Server esteja instalado no cluster; foi verificado antes de executar.
- O Container Insights via addon `amazon-cloudwatch-observability` levou aproximadamente 3-5 minutos para começar a enviar métricas para o namespace `ContainerInsights`.
- A política de retenção de 7 dias foi escolhida para o Log Group de aplicação, equilibrando custo e capacidade de investigação retroativa.
- Durante o load test, foi possível observar o aumento de CPU nos pods via `kubectl top pods`, confirmando que as métricas do Container Insights estavam funcionando corretamente.
- O cleanup foi executado conforme o `cleanup.sh` ao final do lab para evitar custos desnecessários.
