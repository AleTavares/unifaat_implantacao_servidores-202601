# TF - Aula 14 - Monitoramento e Observabilidade de Containers na AWS

**Aluno:** Weslley
**RA:** 6325226

---

# Questão 1 - Três Pilares da Observabilidade

## a) Quais são os três pilares da observabilidade e qual é o objetivo específico de cada um?

### Logs

Registros detalhados de eventos que ocorrem na aplicação e na infraestrutura. Permitem entender o que aconteceu, quando aconteceu e em qual componente. São essenciais para debugging e auditoria.

### Métricas

Dados numéricos que representam o comportamento do sistema ao longo do tempo, como uso de CPU, memória, latência e taxa de requisições. Permitem entender como o sistema está funcionando no momento atual e identificar tendências.

### Alertas

Notificações automáticas disparadas quando métricas ultrapassam limites definidos. Permitem reagir rapidamente a problemas antes que os usuários sejam impactados.

## b) No contexto do EKS na AWS, qual serviço/ferramenta é responsável por cada pilar?

| Pilar | Serviço/Ferramenta AWS |
|-------|------------------------|
| Logs | CloudWatch Logs (coleta via Fluent Bit) |
| Métricas | CloudWatch Metrics + Container Insights |
| Alertas | CloudWatch Alarms |

## c) Explique a diferença entre monitoramento e observabilidade. Por que apenas monitorar não é suficiente?

Monitoramento é saber que algo está errado. Ele fornece dashboards e alertas que indicam o estado do sistema, como por exemplo "CPU está alta".

Observabilidade é a capacidade de entender por que algo está errado, a partir dos dados emitidos pelo próprio sistema. Com observabilidade é possível descobrir, por exemplo, que a CPU está alta porque um endpoint específico está executando queries sem índice no banco de dados.

Apenas monitorar não é suficiente porque o monitoramento mostra sintomas, mas não causas. Sem observabilidade, a equipe precisa adivinhar a origem dos problemas, tornando o diagnóstico mais lento e menos preciso.

---

# Questão 2 - CloudWatch Logs e Fluent Bit

## a) O que é o Fluent Bit e por que ele é deployado como DaemonSet no EKS? O que um DaemonSet garante?

Fluent Bit é um agente leve de coleta e encaminhamento de logs, escrito em C, que consome aproximadamente 450KB de memória. Ele captura os logs dos containers via stdout/stderr e os envia para o CloudWatch Logs.

Ele é deployado como DaemonSet porque esse tipo de recurso Kubernetes garante que um pod rode em todos os nodes do cluster. Dessa forma, independente de quantos nodes existam, cada um terá um pod Fluent Bit coletando os logs dos containers que rodam naquele node.

## b) Explique a diferença entre Log Group e Log Stream no CloudWatch Logs.

### Log Group

Agrupamento lógico de logs no CloudWatch, funciona como uma pasta. Reúne logs relacionados a um mesmo contexto, como por exemplo todos os logs dos containers de um cluster EKS.

### Log Stream

Sequência de eventos de log dentro de um Log Group. Cada pod ou container gera um stream individual com seus próprios registros de log.

## c) Por que é importante configurar uma política de retenção nos Log Groups? O que acontece se não configurar?

A política de retenção define por quanto tempo os logs ficam armazenados antes de serem automaticamente deletados.

Se não configurar, os logs são mantidos indefinidamente. Isso gera custos crescentes de armazenamento no CloudWatch Logs, já que a AWS cobra por volume de dados armazenados. Em um ambiente de produção com muitos containers gerando logs continuamente, o custo pode se tornar significativo.

---

# Questão 3 - Container Insights e Métricas

## a) Qual é a diferença entre as métricas padrão do EKS e as métricas do Container Insights? Que informações extras o Container Insights fornece?

As métricas padrão do EKS fornecem informações básicas sobre o cluster, como status do control plane e dos nodes.

O Container Insights fornece métricas detalhadas e granulares específicas para containers:

* CPU e memória por pod, container, node e cluster.
* Rede: bytes enviados e recebidos por pod.
* Disco: operações de I/O por node.
* Status: quantidade de pods running, pending e failed.

Essas informações extras permitem identificar gargalos em componentes específicos e dimensionar recursos com maior precisão.

## b) Explique o que é o namespace de métricas ContainerInsights no CloudWatch e que tipo de dados ele armazena.

O namespace `ContainerInsights` é uma separação lógica dentro do CloudWatch Metrics que agrupa todas as métricas coletadas de containers no EKS ou ECS.

Ele armazena dados como:

* Utilização de CPU por pod e node.
* Utilização de memória por pod e node.
* Tráfego de rede por pod.
* I/O de disco por node.
* Contagem de pods por status.

As métricas ficam organizadas por dimensões como ClusterName, Namespace, PodName e NodeName.

## c) O que o comando kubectl top pods mostra e por que ele é útil para monitoramento em tempo real?

O comando `kubectl top pods` mostra o consumo atual de CPU e memória de cada pod em execução.

Ele é útil para monitoramento em tempo real porque permite verificar rapidamente quais pods estão consumindo mais recursos, identificar pods com uso anômalo e validar se os limites de recursos definidos nos deployments estão adequados. É uma forma rápida de diagnosticar problemas de performance sem precisar acessar o Console AWS.

---

# Questão 4 - CloudWatch Alarms e Alertas

## a) Explique o que são Evaluation Periods e Threshold em um CloudWatch Alarm. Por que usar mais de 1 período de avaliação?

### Threshold

Valor limite que define a fronteira entre o estado normal e o estado de alerta. Por exemplo, CPU > 70% significa que qualquer valor acima de 70% é considerado uma violação.

### Evaluation Periods

Quantidade de períodos consecutivos de coleta que precisam ultrapassar o threshold antes do alarme disparar. Cada período tem uma duração definida (por exemplo, 5 minutos).

Usar mais de 1 período de avaliação evita falsos positivos. Um pico momentâneo de CPU de poucos segundos não deve gerar um alerta, pois pode ser uma operação normal e temporária. Exigir que o threshold seja violado por 2 ou mais períodos consecutivos garante que o alarme só dispare quando há um problema real e persistente.

## b) Cite os 4 Golden Signals definidos pelo Google SRE e dê um exemplo prático de cada um para a aplicação do Lab014.

| Golden Signal | O que mede | Exemplo no Lab014 |
|---------------|------------|-------------------|
| Latência | Tempo de resposta das requisições | Tempo que o Nginx leva para responder uma requisição HTTP da página do curso |
| Tráfego | Volume de demanda no sistema | Quantidade de requisições por segundo chegando no LoadBalancer da aplicação |
| Erros | Taxa de requisições que falham | Porcentagem de respostas HTTP 5xx retornadas pelo Nginx |
| Saturação | Quanto do recurso está sendo utilizado | Porcentagem de CPU e memória consumida pelos pods ads-site |

## c) O que é um alerta acionável vs um alerta genérico? Dê um exemplo de cada.

### Alerta Acionável

Um alerta que é específico, indica claramente o problema e permite que a equipe saiba exatamente o que fazer ao recebê-lo.

Exemplo: "CPU acima de 80% por 5 minutos no pod ads-site no namespace ads-unifaat. Verificar se há necessidade de escalar réplicas."

### Alerta Genérico

Um alerta vago que não indica claramente o que está errado nem o que deve ser feito, gerando fadiga de alertas na equipe.

Exemplo: "Algo está diferente no cluster."

---

# Questão 5 - Tarefa Prática - Configuração de Monitoramento

## a) Criar o Log Group com retenção de 14 dias

```bash
aws logs create-log-group \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --region us-east-1

aws logs put-retention-policy \
  --log-group-name /aws/eks/producao-cluster/api-logs \
  --retention-in-days 14
```

## b) Criar um CloudWatch Alarm de CPU > 75% por 2 períodos de 5 minutos

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-Producao-HighCPU" \
  --alarm-description "CPU acima de 75% no cluster producao-cluster" \
  --namespace ContainerInsights \
  --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value=producao-cluster \
  --statistic Average \
  --period 300 \
  --threshold 75 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching
```

## c) Query do Logs Insights para contar erros agrupados por intervalos de 10 minutos

```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as total_erros by bin(10m)
| sort @timestamp desc
```

## d) Listar todos os alarmes com prefixo "EKS-" em formato de tabela

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' \
  --output table
```

## e) Criar um Dashboard com 2 widgets: CPU e Memória do cluster

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "EKS-Producao-Dashboard" \
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
          "title": "CPU Utilization - Pods"
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
          "title": "Memory Utilization - Pods"
        }
      }
    ]
  }'
```

---

# Evidências Coletadas

Todas as evidências foram coletadas em ambiente Kubernetes local (Kind) com cluster `tf-kubernetes` rodando Kubernetes v1.34.0. Os arquivos .txt estão na pasta `evidencias/`.

## Parte 1: Preparação e Cluster

- **[01-cluster-ativo.txt](evidencias/01-cluster-ativo.txt)** — Cluster info e node em status Ready (Kubernetes control plane ativo).
- **[02-namespace-criado.txt](evidencias/02-namespace-criado.txt)** — Namespace `ads-unifaat` criado com todos os recursos (pods, service, deployment, replicaset).
- **[03-pods-running.txt](evidencias/03-pods-running.txt)** — 2 pods `ads-site` em status Running com describe detalhado (probes, resources, events).
- **[04-deployment-details.txt](evidencias/04-deployment-details.txt)** — Deployment com 2/2 réplicas disponíveis, strategy RollingUpdate.
- **[05-service-details.txt](evidencias/05-service-details.txt)** — Service NodePort com endpoints apontando para os 2 pods.

## Parte 2: Métricas e Monitoramento

- **[06-top-nodes.txt](evidencias/06-top-nodes.txt)** — Uso de CPU (336m, 2%) e memória (1011Mi, 27%) do node.
- **[07-top-pods.txt](evidencias/07-top-pods.txt)** — Uso de CPU (1m) e memória (13Mi) por pod ads-site.
- **[08-metrics-server.txt](evidencias/08-metrics-server.txt)** — Metrics-server rodando no kube-system (equivalente local do Container Insights).

## Parte 3: Tráfego e Observação

- **[09-logs-acesso.txt](evidencias/09-logs-acesso.txt)** — Logs do Nginx mostrando requisições Wget (load test) e kube-probe (health checks).
- **[10-load-test.txt](evidencias/10-load-test.txt)** — Pod de load test (busybox) com status Completed após 100 requisições.
- **[11-top-pods-apos-carga.txt](evidencias/11-top-pods-apos-carga.txt)** — Métricas de CPU e memória dos pods e node após geração de tráfego.
- **[12-docker-image.txt](evidencias/12-docker-image.txt)** — Imagem Docker `ads-unifaat-site:v1.0` construída localmente.
- **[13-kubectl-config.txt](evidencias/13-kubectl-config.txt)** — Configuração do kubectl apontando para o cluster Kind `tf-kubernetes`.

## Parte 4: Limpeza

- **[14-limpeza-loadtest.txt](evidencias/14-limpeza-loadtest.txt)** — Remoção do pod de load test.
- **[15-limpeza-deploy.txt](evidencias/15-limpeza-deploy.txt)** — Remoção do deployment e service da aplicação.
- **[16-limpeza-namespace.txt](evidencias/16-limpeza-namespace.txt)** — Remoção do namespace `ads-unifaat`.
- **[17-limpeza-metrics.txt](evidencias/17-limpeza-metrics.txt)** — Remoção do metrics-server.
- **[18-verificacao-limpeza.txt](evidencias/18-verificacao-limpeza.txt)** — Verificação final: namespace removido, sem recursos remanescentes.

---

# Lista dos Comandos Executados no Lab014

Ambiente utilizado: Kubernetes local via Kind (cluster `tf-kubernetes`, Kubernetes v1.34.0).

```bash
# Seção 1 - Preparação do ambiente
docker start tf-kubernetes-control-plane
kubectl cluster-info
kubectl get nodes

# Seção 2 - Build e carga da imagem
docker build --no-cache -t ads-unifaat-site:v1.0 .
kind load docker-image ads-unifaat-site:v1.0 --name tf-kubernetes

# Seção 3 - Deploy da aplicação
kubectl create namespace ads-unifaat
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl wait --for=condition=ready pod -l app=ads-site -n ads-unifaat --timeout=120s
kubectl get all -n ads-unifaat
kubectl get pods -n ads-unifaat -o wide
kubectl describe deployment ads-site -n ads-unifaat
kubectl describe service ads-site-service -n ads-unifaat

# Seção 4 - Métricas (metrics-server como equivalente local do Container Insights)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl get pods -n kube-system -l k8s-app=metrics-server
kubectl top nodes
kubectl top pods -n ads-unifaat

# Seção 5 - Geração de tráfego e observação
kubectl run load-test --image=busybox --restart=Never -n ads-unifaat \
  -- /bin/sh -c "for i in \$(seq 1 100); do wget -q -O /dev/null http://ads-site-service.ads-unifaat.svc.cluster.local; done"
kubectl logs -n ads-unifaat -l app=ads-site --tail=20
kubectl top pods -n ads-unifaat
kubectl top nodes

# Seção 6 - Limpeza
kubectl delete pod load-test -n ads-unifaat
kubectl delete deployment ads-site -n ads-unifaat
kubectl delete service ads-site-service -n ads-unifaat
kubectl delete namespace ads-unifaat
kubectl delete deployment metrics-server -n kube-system
kubectl get namespaces
```

---

# Observações

O laboratório foi executado em ambiente Kubernetes local utilizando Kind (Kubernetes in Docker) com cluster `tf-kubernetes` rodando Kubernetes v1.34.0, em vez do EKS na AWS. Essa abordagem foi adotada devido a indisponibilidade temporária das credenciais AWS.

Os conceitos de observabilidade foram aplicados da seguinte forma no ambiente local:

- **Métricas:** O metrics-server foi instalado como equivalente local do Container Insights, permitindo monitorar CPU e memória dos pods e nodes via `kubectl top`.
- **Logs:** Os logs do Nginx foram coletados diretamente via `kubectl logs`, demonstrando o mesmo princípio de coleta que o Fluent Bit faria no EKS enviando para o CloudWatch Logs.
- **Tráfego e carga:** Um pod busybox executou 100 requisições ao service da aplicação, simulando tráfego real e gerando logs de acesso no Nginx.

Todos os recursos criados (deployment, service, namespace, metrics-server, pod de load test) foram removidos ao final da atividade, conforme evidenciado nos arquivos de limpeza (prints 14 a 18).
