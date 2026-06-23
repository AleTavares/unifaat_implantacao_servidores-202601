# TF Final — Sala 14 — RA 3225002

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Disciplina:** Implementação de servidor e nuvem (cloud)
**Aula:** 14 — Monitoramento e Observabilidade de Containers na AWS
**Data de entrega:** 23/06/2026

---

## Sumário

1. [Questão 1 — Três Pilares da Observabilidade](#questão-1--três-pilares-da-observabilidade-teórica)
2. [Questão 2 — CloudWatch Logs e Fluent Bit](#questão-2--cloudwatch-logs-e-fluent-bit-teórica)
3. [Questão 3 — Container Insights e Métricas](#questão-3--container-insights-e-métricas-teórica)
4. [Questão 4 — CloudWatch Alarms e Alertas](#questão-4--cloudwatch-alarms-e-alertas-teórica)
5. [Questão 5 — Tarefa Prática (Simulação)](#questão-5--tarefa-prática-simulação)
6. [Questão 6 — Evidências Práticas](#questão-6--evidências-práticas-da-execução-do-lab014)
7. [Comandos executados no Lab014](#comandos-executados-no-lab014)
8. [Observações sobre erros encontrados](#observações-sobre-erros-e-diferenças-encontradas)

---

## Questão 1 — Três Pilares da Observabilidade (Teórica)

### a) Quais são os três pilares da observabilidade e qual o objetivo específico de cada um?

Os três pilares da observabilidade são **Logs**, **Métricas** e **Traces**.

- **Logs**: registros textuais detalhados de eventos discretos que aconteceram no sistema. Cada linha de log descreve um momento específico — quando uma requisição chegou, quando deu erro, qual usuário acessou o quê. Servem principalmente para **depuração reativa** (descobrir o que aconteceu depois de um problema) e para **auditoria** (rastrear quem fez o quê e quando).

- **Métricas**: valores numéricos agregados ao longo do tempo, como uso de CPU, quantidade de requisições por segundo, latência média. São otimizadas para serem armazenadas em volume e consultadas rapidamente, alimentando dashboards e gatilhos de alertas. Servem para **detecção proativa** de anomalias e para entender tendências.

- **Traces** (rastreamento distribuído): registram o caminho completo de uma requisição passando por múltiplos serviços, com tempos de cada etapa. São essenciais em arquiteturas de microsserviços para identificar **onde exatamente a latência está acontecendo** em uma cadeia de chamadas.

### b) No contexto do EKS na AWS, qual serviço/ferramenta é responsável por cada pilar?

| Pilar | Ferramenta AWS |
|-------|---------------|
| Logs | **Amazon CloudWatch Logs** (com Fluent Bit coletando dos pods) |
| Métricas | **CloudWatch Metrics + Container Insights** (métricas detalhadas de containers) |
| Traces | **AWS X-Ray** (rastreamento distribuído, integra com aplicações via SDK ou via OpenTelemetry) |

Complementarmente, alertas são responsabilidade do **CloudWatch Alarms** e a visualização integrada acontece em **CloudWatch Dashboards** ou **Amazon Managed Grafana**.

### c) Explique a diferença entre monitoramento e observabilidade. Por que apenas monitorar não é suficiente?

**Monitoramento** é uma prática mais antiga e mais limitada: você define *previamente* quais métricas e checks vai acompanhar (CPU acima de 80%, ping no endpoint X, etc.) e o sistema te avisa quando essas regras conhecidas são violadas. Funciona bem para problemas que você já antecipou.

**Observabilidade** é a capacidade de entender o estado interno de um sistema a partir dos dados que ele emite, **mesmo para problemas que você não previu**. Em vez de só responder "isso que eu já sei pode estar quebrando?", a observabilidade permite responder "o que está acontecendo aqui que nunca aconteceu antes?".

Apenas monitorar não basta porque sistemas distribuídos modernos têm um espaço de possíveis falhas tão grande que é impraticável prever cada combinação. Quando algo inesperado acontece — uma combinação rara de carga, um bug sutil entre dois serviços, uma degradação gradual — o monitoramento tradicional não dispara porque nenhuma regra pré-definida foi violada. A observabilidade, com logs estruturados, métricas de alta cardinalidade e traces, permite **explorar** o comportamento do sistema e descobrir a causa raiz mesmo sem saber de antemão o que procurar.

---

## Questão 2 — CloudWatch Logs e Fluent Bit (Teórica)

### a) O que é o Fluent Bit e por que ele é implantado como DaemonSet no EKS? O que um DaemonSet garante?

**Fluent Bit** é um agente leve de coleta, processamento e encaminhamento de logs, escrito em C, com uso mínimo de memória (~450 KB) e suporte nativo a diversos destinos, incluindo o CloudWatch Logs. No EKS é o agente padrão recomendado pela AWS para encaminhar logs dos containers.

Ele é implantado como **DaemonSet** porque um DaemonSet é um recurso do Kubernetes que **garante que um pod (e apenas um) rode em cada nó do cluster**. Conforme novos nós entram no cluster (autoscaling), o DaemonSet automaticamente cria o pod do Fluent Bit naquele nó; conforme nós saem, o pod é encerrado junto. Isso assegura que **nenhum log de nenhum container fique sem ser coletado**, independente de onde o pod da aplicação for agendado.

A alternativa (rodar Fluent Bit como Deployment com N réplicas) não funciona bem porque cada agente precisa ter acesso ao runtime de containers local (`/var/log/containers/` no host) — ou seja, precisa estar fisicamente no nó cujos logs ele coleta.

### b) Explique a diferença entre Log Group e Log Stream no CloudWatch Logs.

- **Log Group** é um agrupamento lógico de logs com configuração compartilhada. Toda política de retenção, criptografia, métricas filtradas e controle de acesso é definida no nível do Log Group. Funciona como uma "pasta" ou um "namespace" para um conjunto relacionado de logs (ex: todos os logs de um cluster EKS, ou todos os logs de uma função Lambda).

- **Log Stream** é uma sequência ordenada de eventos de log dentro de um Log Group, geralmente associada a uma **fonte única e contínua**. No EKS, cada container de cada pod gera tipicamente seu próprio Log Stream. Os eventos dentro de um Log Stream são imutáveis e ordenados por timestamp.

Em resumo: **Log Group = configuração compartilhada; Log Stream = sequência temporal por fonte**.

### c) Por que é importante configurar uma política de retenção nos Grupos de Log? O que acontece se não configurar?

Configurar retenção é importante por dois motivos principais:

1. **Custo**: o CloudWatch Logs cobra por GB armazenado por mês. Sem retenção, os logs são mantidos **indefinidamente** e a fatura cresce continuamente. Para ambientes com alto volume de logs (tipico em produção), isso pode rapidamente superar centenas ou milhares de dólares por mês.

2. **Conformidade e LGPD/GDPR**: muitas regulações exigem que dados pessoais não sejam mantidos além do necessário. Manter logs indefinidamente pode caracterizar violação dessas normas.

Se a retenção não for configurada, o padrão do CloudWatch é **"Never Expire"** — os logs ficam para sempre, gerando custo crescente e risco de conformidade. A retenção recomendada varia por caso: 7 dias para ambiente de lab/dev, 30 dias para staging, 90 dias ou mais para produção (ou conforme política de auditoria da empresa).

---

## Questão 3 — Container Insights e Métricas (Teórica)

### a) Qual a diferença entre as métricas padrão do EKS e as métricas do Container Insights? Que informações extras o Container Insights fornece?

As **métricas padrão do EKS** (publicadas automaticamente no namespace `AWS/EKS` do CloudWatch) cobrem o nível do plano de controle: chamadas à API do Kubernetes, latência do API server, número de requests por código de status. São métricas de "saúde do cluster como serviço gerenciado AWS" — não dizem nada sobre o que está rodando dentro dele.

O **Container Insights** vai muito além. Coleta métricas detalhadas em vários níveis hierárquicos:

- **Nível Cluster**: número de nós, número de pods rodando/pendentes/falhando, uso agregado de CPU/memória/rede/disco.
- **Nível Node**: CPU, memória, rede, disco, número de pods por nó, uso de file descriptors.
- **Nível Namespace**: agregações de uso por namespace (útil para multi-tenancy ou para custos por equipe).
- **Nível Pod**: CPU, memória, rede, restarts, status atual.
- **Nível Container**: o uso específico de cada container dentro de um pod (importante para pods multi-container como sidecars).
- **Nível Service**: agregações de uso por Service do Kubernetes.

Essas métricas chegam com **alta granularidade** (intervalo de 1 minuto por padrão) e ficam disponíveis tanto via CloudWatch Metrics quanto via dashboards pré-prontos no console.

### b) Explique o que é o namespace de métricas `ContainerInsights` no CloudWatch e que tipo de dados ele armazena.

No CloudWatch, **namespace** é um agrupamento lógico de métricas relacionadas (similar ao conceito de schema em banco de dados). Os namespaces padrão da AWS começam com `AWS/` (ex: `AWS/EC2`, `AWS/EKS`, `AWS/Lambda`). O namespace **`ContainerInsights`** é onde o CloudWatch Agent (instalado via Container Insights) publica todas as métricas detalhadas de containers.

Os dados armazenados nesse namespace incluem:

- Métricas com dimensões hierárquicas: `ClusterName`, `Namespace`, `PodName`, `ContainerName`, `NodeName`, `ServiceName`.
- Indicadores de uso: `pod_cpu_utilization`, `pod_memory_utilization`, `node_cpu_utilization`, `node_memory_utilization`, `node_network_total_bytes`, `container_cpu_usage_total`.
- Indicadores de estado: `cluster_failed_node_count`, `pod_number_of_container_restarts`, `service_number_of_running_pods`.
- Indicadores de capacidade: `node_filesystem_utilization`, `node_status_capacity_pods`.

A combinação de métricas + dimensões permite criar filtros poderosos (ex: "uso médio de CPU dos pods do namespace `ads-unifaat`") e dashboards segmentados.

### c) O que o comando `kubectl top pods` mostra e por que ele é útil para monitoramento em tempo real?

`kubectl top pods` consulta o **Metrics Server** do Kubernetes (que precisa estar instalado no cluster) e exibe, para cada pod, o **uso atual de CPU e memória**. A saída típica é algo como:

```
NAME                       CPU(cores)   MEMORY(bytes)
ads-site-58d49b8b9c-x9z2k  15m          85Mi
ads-site-58d49b8b9c-p7q4j  12m          82Mi
```

É útil em monitoramento em tempo real por três razões:

1. **Imediato**: não precisa abrir o console AWS, esperar métricas serem agregadas no CloudWatch (que tem delay de ~1 minuto) ou logar em sistema externo. Roda direto no terminal.
2. **Diagnóstico de campo**: durante uma incidente, você consegue rapidamente identificar qual pod está consumindo mais recursos e correlacionar com a degradação do serviço.
3. **Verificação de configurações**: ajuda a validar se os limits e requests de recursos definidos no manifest estão coerentes com o uso real (importante para autoscaling e gestão de capacidade).

A limitação é que mostra um snapshot do momento atual — não tem histórico nem alertas. Para isso é necessário o CloudWatch / Container Insights.

---

## Questão 4 — CloudWatch Alarms e Alertas (Teórica)

### a) Explique o que são Evaluation Periods e Threshold em um CloudWatch Alarm. Por que usar mais de 1 período de avaliação?

- **Threshold** é o valor de comparação contra o qual a métrica é medida. Exemplo: "CPU acima de 80%" — aqui 80% é o threshold.
- **Evaluation Period** é a janela de tempo (em períodos do alarme, que tipicamente são 1 ou 5 minutos cada) em que a métrica precisa violar o threshold para que o alarme dispare.

Usar **mais de 1 período** de avaliação é uma boa prática porque evita **alarmes falsos disparados por picos isolados**. Imagine: a CPU pulou para 90% por 30 segundos durante um garbage collection e depois voltou ao normal. Se o alarme estivesse configurado com 1 período de 1 minuto, ele dispararia. Mas isso não é realmente um problema — foi um pico transiente.

Usando, por exemplo, 3 períodos consecutivos de 1 minuto, o alarme só dispara se a CPU ficar acima de 80% por 3 minutos seguidos — o que sim caracteriza um problema sustentado que merece atenção. Isso reduz drasticamente os falsos positivos e aumenta a confiança do time nos alertas (evita "alarm fatigue").

A configuração também aceita a sintaxe "M de N períodos" (ex: "dispara se em 3 dos últimos 5 períodos a métrica violou o threshold") para casos onde se quer tolerar alguma flutuação mas detectar tendência persistente.

### b) Cite os 4 Golden Signals definidos pelo Google SRE e dê um exemplo prático de cada um para a aplicação do Lab014.

Os **4 Golden Signals** definidos pelo Google SRE (livro Site Reliability Engineering) são:

| Sinal | Definição | Exemplo prático para a aplicação do Lab014 |
|-------|-----------|--------------------------------------------|
| **Latency** (Latência) | Tempo que uma requisição leva para ser servida — separando requisições bem-sucedidas das que falham | Tempo médio (P50) e P99 de resposta da página `ads-site` em milissegundos, medido no ALB do EKS |
| **Traffic** (Tráfego) | Quantidade de demanda sobre o sistema, na unidade que faz sentido para o domínio | Requisições por segundo recebidas pelo Service `ads-site-service` |
| **Errors** (Erros) | Taxa de requisições que falham — explicitamente (HTTP 500) ou implicitamente (resposta correta porém com conteúdo errado) | Quantidade de respostas HTTP 5xx por minuto, ou contagem de logs com nível ERROR no CloudWatch Logs Insights |
| **Saturation** (Saturação) | Quão "cheio" está o serviço — quanto da capacidade já está em uso | Uso de CPU e memória dos pods do `ads-site` em relação ao `limit` definido no manifest, via Container Insights |

Esses 4 sinais cobrem com poucos indicadores a maior parte dos problemas que afetam um serviço. Monitorando bem esses quatro, você pega 80% dos incidentes antes que se tornem grandes.

### c) O que é um alerta acionável vs um alerta genérico? Dê um exemplo de cada.

- **Alerta acionável**: aquele que descreve **um problema concreto, com impacto claro e com uma ação que o operador deve tomar agora**. Quando o alerta dispara, o destinatário sabe imediatamente o que precisa fazer (ou pelo menos onde começar a investigar). Bons alertas acionáveis indicam o serviço afetado, a severidade, o sintoma e idealmente apontam para um runbook.

  **Exemplo**: *"[CRÍTICO] Endpoint /api/login do `ads-site` retornou >5% de HTTP 500 nos últimos 5 minutos. Login está quebrado para usuários. Runbook: https://wiki/runbook/login-failures."*

- **Alerta genérico**: aquele que indica que algo está "diferente do normal" mas não comunica **o que isso significa em termos de impacto** nem **o que fazer a respeito**. Tipicamente vem de uma métrica de infraestrutura sem contexto de serviço.

  **Exemplo ruim**: *"CPU do nó node-2 acima de 80%."* — Quem recebe esse alerta às 2h da manhã não sabe se isso é grave (algum serviço está degradado?) ou normal (talvez só esteja processando um batch). Não há ação clara.

A boa prática moderna (SRE) é alertar em **sintomas que afetam o usuário** (Golden Signals + SLOs), não em causas hipotéticas de infraestrutura. CPU alta não é um problema em si — só vira problema se causar latência alta ou erros.

---

## Questão 5 — Tarefa Prática (Simulação)

**Cenário:**
- Cluster: `producao-cluster`
- Namespace: `minha-api`
- Log Group: `/aws/eks/producao-cluster/api-logs`
- Região: `us-east-1`

### a) Criar o Log Group com retenção de 14 dias

```bash
# Cria o Log Group
aws logs create-log-group \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --region us-east-1

# Define retenção de 14 dias
aws logs put-retention-policy \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --retention-in-days 14 \
  --region us-east-1
```

**Por que dois comandos?** O `create-log-group` não aceita o parâmetro de retenção diretamente — é uma decisão de design da AWS para manter os comandos atômicos. A retenção é aplicada depois com `put-retention-policy`.

### b) Alarme de CPU > 75% por 2 períodos consecutivos de 5 minutos

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-producao-cluster-CPUHigh" \
  --alarm-description "CPU media do cluster acima de 75% por 10 minutos" \
  --metric-name "node_cpu_utilization" \
  --namespace "ContainerInsights" \
  --statistic "Average" \
  --dimensions Name=ClusterName,Value=producao-cluster \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 75 \
  --comparison-operator "GreaterThanThreshold" \
  --treat-missing-data "notBreaching" \
  --region us-east-1
```

**Notas:**
- `--period 300` = 5 minutos (em segundos).
- `--evaluation-periods 2` = exige 2 períodos consecutivos acima do threshold para disparar (total 10 minutos).
- `--treat-missing-data notBreaching` evita que dados ausentes disparem o alarme indevidamente.

### c) Query do CloudWatch Logs Insights — erros agrupados em intervalos de 10 minutos na última hora

```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as total_erros by bin(10m)
| sort @timestamp desc
```

Executando via AWS CLI:

```bash
QUERY_ID=$(aws logs start-query \
  --log-group-name "/aws/eks/producao-cluster/api-logs" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() as total_erros by bin(10m) | sort @timestamp desc' \
  --query 'queryId' \
  --output text \
  --region us-east-1)

# Aguardar resultado (queries são assíncronas)
sleep 5
aws logs get-query-results --query-id $QUERY_ID --region us-east-1
```

### d) Listar todos os alarmes com prefixo "EKS-" em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[*].[AlarmName,StateValue,MetricName,Threshold]' \
  --output table \
  --region us-east-1
```

A saída fica em formato visual de tabela, mostrando o nome, estado atual (OK/ALARM/INSUFFICIENT_DATA), métrica monitorada e threshold.

### e) Dashboard CloudWatch com 2 widgets (CPU e Memória do cluster)

```bash
cat > dashboard-producao.json << 'EOF'
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "ContainerInsights", "node_cpu_utilization", "ClusterName", "producao-cluster" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "period": 300,
        "stat": "Average",
        "title": "CPU do Cluster (% medio)"
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
          [ "ContainerInsights", "node_memory_utilization", "ClusterName", "producao-cluster" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "period": 300,
        "stat": "Average",
        "title": "Memoria do Cluster (% medio)"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard \
  --dashboard-name "EKS-producao-cluster" \
  --dashboard-body file://dashboard-producao.json \
  --region us-east-1
```

**Estrutura do JSON:**
- `widgets`: array de blocos visuais na ordem que aparecem no dashboard.
- `x` e `y`: posição em grid (24 colunas no total). O widget de CPU fica na coluna 0 e o de Memória na coluna 12 (lado a lado).
- `width: 12, height: 6`: cada widget ocupa metade da largura.
- `metrics`: define a métrica (namespace, nome, dimensões).
- `stat`: estatística de agregação (`Average`, `Sum`, `Maximum`, etc.).

---

## Questão 6 — Evidências Práticas da Execução do Lab014

Esta seção descreve o resultado de cada uma das etapas do Lab014 executadas no cluster `cluster-eks-ads`, namespace `ads-unifaat`. As capturas estão organizadas na pasta `evidencias/` deste diretório.

### Parte 1 — Preparação e Logs

| Arquivo | Conteúdo |
|---------|----------|
| `evidencias/01_cluster_ativo.txt` | Saída de `aws eks describe-cluster` confirmando status `ACTIVE` |
| `evidencias/02_log_group_criado.txt` | Saída de `aws logs describe-log-groups` mostrando o log group `/aws/eks/cluster-eks-ads/containers` criado com retenção de 7 dias |
| `evidencias/03_fluentbit_running.txt` | Saída de `kubectl get pods -n amazon-cloudwatch` com 2 pods Fluent Bit em estado Running (um por nó) |
| `evidencias/04_logs_cloudwatch.txt` | Saída de `aws logs filter-log-events` mostrando eventos sendo recebidos do cluster |

### Parte 2 — Métricas e Container Insights

| Arquivo | Conteúdo |
|---------|----------|
| `evidencias/05_container_insights_habilitado.txt` | Confirmação de instalação do CloudWatch Agent como DaemonSet (3 pods Running) |
| `evidencias/06_metricas_disponiveis.txt` | Saída de `aws cloudwatch list-metrics --namespace ContainerInsights` listando métricas do cluster |
| `evidencias/07_kubectl_top.txt` | Saída de `kubectl top pods` e `kubectl top nodes` mostrando uso de CPU e memória em tempo real |

### Parte 3 — Alarmes e Dashboard

| Arquivo | Conteúdo |
|---------|----------|
| `evidencias/08_alarmes_criados.txt` | Saída de `aws cloudwatch describe-alarms` com os 3 alarmes (EKS-ADS-CPU-Alta, EKS-ADS-Memoria-Alta, EKS-ADS-Pods-NaoSaudaveis) em estado OK |
| `evidencias/09_dashboard.txt` | Confirmação da criação do dashboard `EKS-ADS-Monitoring` via `aws cloudwatch put-dashboard` |

### Parte 4 — Tráfego e Observação

| Arquivo | Conteúdo |
|---------|----------|
| `evidencias/10_geracao_trafego.txt` | Execução do script de carga gerando 100 requisições paralelas |
| `evidencias/11_metricas_reagindo.txt` | Saída de `kubectl top pods` durante a carga mostrando aumento de CPU |
| `evidencias/12_logs_acesso.txt` | Saída de `kubectl logs -n ads-unifaat -l app=ads-site --tail=10` mostrando requisições processadas |

### Parte 5 — Limpeza

| Arquivo | Conteúdo |
|---------|----------|
| `evidencias/13_alarmes_removidos.txt` | Confirmação de `aws cloudwatch delete-alarms` |
| `evidencias/14_loggroup_removido.txt` | Confirmação de `aws logs delete-log-group` |
| `evidencias/15_namespace_removido.txt` | Confirmação de `kubectl delete namespace amazon-cloudwatch` |

---

## Comandos executados no Lab014

### Variáveis de ambiente
```bash
export AWS_ACCOUNT_ID="123123123123"
export AWS_REGION="us-east-2"
export CLUSTER_NAME="cluster-eks-ads"
export NAMESPACE="ads-unifaat"
export LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"
```

### Seção 1 — Verificação do cluster
```bash
aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.status' --output text
kubectl get pods -n $NAMESPACE
kubectl get nodes
```

### Seção 2 — CloudWatch Logs + Fluent Bit
```bash
# Log Group
aws logs create-log-group --log-group-name $LOG_GROUP --region $AWS_REGION
aws logs put-retention-policy --log-group-name $LOG_GROUP --retention-in-days 7

# Namespace e ConfigMap
kubectl create namespace amazon-cloudwatch
kubectl create configmap fluent-bit-cluster-info \
  --namespace amazon-cloudwatch \
  --from-literal=cluster.name=$CLUSTER_NAME \
  --from-literal=http.server=On \
  --from-literal=http.port=2020 \
  --from-literal=logs.region=$AWS_REGION

# IAM Policy + Service Account
aws iam create-policy --policy-name CloudWatchLogsPolicy --policy-document file://cloudwatch-policy.json
eksctl create iamserviceaccount \
  --name fluent-bit \
  --namespace amazon-cloudwatch \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/CloudWatchLogsPolicy \
  --override-existing-serviceaccounts \
  --approve

# Deploy do Fluent Bit
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit-compatible.yaml

# Verificação
kubectl get pods -n amazon-cloudwatch
aws logs filter-log-events --log-group-name $LOG_GROUP --max-items 5
```

### Seção 3 — Container Insights
```bash
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml \
  | sed "s|{{cluster_name}}|$CLUSTER_NAME|g" \
  | kubectl apply -f -

aws cloudwatch list-metrics --namespace ContainerInsights --max-items 10
kubectl top pods -n $NAMESPACE
kubectl top nodes
```

### Seção 4 — Alarmes
```bash
# CPU
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-CPU-Alta" \
  --metric-name node_cpu_utilization \
  --namespace ContainerInsights \
  --statistic Average \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold

# Memória
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-Memoria-Alta" \
  --metric-name node_memory_utilization \
  --namespace ContainerInsights \
  --statistic Average \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 85 \
  --comparison-operator GreaterThanThreshold

# Pods não saudáveis
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-Pods-NaoSaudaveis" \
  --metric-name pod_number_of_container_restarts \
  --namespace ContainerInsights \
  --statistic Sum \
  --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold

# Verificação
aws cloudwatch describe-alarms --alarm-name-prefix "EKS-ADS"
```

### Seção 5 — Logs Insights
```bash
aws logs start-query \
  --log-group-name $LOG_GROUP \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 10'

aws logs get-query-results --query-id <QUERY_ID>
```

### Seção 6 — Geração de tráfego
```bash
ENDPOINT=$(kubectl get svc ads-site-service -n $NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Loop de carga
for i in $(seq 1 100); do
  curl -s -o /dev/null "http://$ENDPOINT" &
done
wait

kubectl top pods -n $NAMESPACE
kubectl logs -n $NAMESPACE -l app=ads-site --tail=10
```

### Seção 7 — Limpeza
```bash
aws cloudwatch delete-alarms --alarm-names \
  "EKS-ADS-CPU-Alta" "EKS-ADS-Memoria-Alta" "EKS-ADS-Pods-NaoSaudaveis"
aws logs delete-log-group --log-group-name $LOG_GROUP
kubectl delete namespace amazon-cloudwatch
```

---

## Observações sobre erros e diferenças encontradas

Durante a execução do Lab014, alguns pontos merecem registro:

1. **Tempo de propagação das métricas**: o Container Insights leva alguns minutos (3 a 5) entre o deploy do CloudWatch Agent e as primeiras métricas aparecerem no console. Tentei consultar `aws cloudwatch list-metrics --namespace ContainerInsights` logo após o deploy e a resposta veio vazia. Aguardando ~5 minutos, as métricas começaram a aparecer.

2. **DaemonSet vs número de pods**: como o cluster do Lab013 foi configurado com 2 nodes, observei exatamente 2 pods do Fluent Bit (`kubectl get pods -n amazon-cloudwatch`). Isso confirma o comportamento esperado de um DaemonSet — um pod por nó.

3. **Custos do CloudWatch Logs**: notei que mesmo com pouco tráfego o volume de logs cresceu rápido (poucos MB por hora). Configurar a retenção de 7 dias logo de início é essencial para evitar acúmulo. Em produção real, conviria também filtrar logs no Fluent Bit para enviar apenas níveis WARN e ERROR ao CloudWatch, deixando os DEBUG e INFO apenas em arquivos locais.

4. **kubectl top vs CloudWatch**: o `kubectl top` (via Metrics Server) e as métricas do Container Insights nem sempre batem exatamente — o Metrics Server agrega via cAdvisor a cada 15 segundos, enquanto o Container Insights agrega a cada minuto. Diferenças de até 10% são normais.

5. **Limpeza obrigatória**: respeitando a orientação do TF, executei `cleanup.sh` ao final para evitar custos contínuos. Confirmei que cluster, log groups, alarmes e roles IAM foram removidos via `aws eks list-clusters`, `aws logs describe-log-groups` e `aws cloudwatch describe-alarms` (todos retornando vazio para o cluster).

---

**Repositório:** https://github.com/zzin742/unifaat_implantacao_servidores-202601
**Branch:** main
**Pasta:** `Aula 014/3225002/`
