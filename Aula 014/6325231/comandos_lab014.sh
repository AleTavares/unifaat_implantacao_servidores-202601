#!/usr/bin/env bash

# Comandos auxiliares do TF014.
# Execute por blocos, nao precisa rodar o arquivo inteiro de uma vez.

export AWS_ACCOUNT_ID="SEU_ACCOUNT_ID"
export AWS_REGION="us-east-2"
export CLUSTER_NAME="cluster-eks-ads"
export NAMESPACE="ads-unifaat"
export LOG_GROUP="/aws/eks/$CLUSTER_NAME/containers"

# 1. Verificacoes iniciais
aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.status' --output text --region "$AWS_REGION"
kubectl get pods -n "$NAMESPACE"
kubectl get nodes

# 2. Log Group
aws logs create-log-group --log-group-name "$LOG_GROUP" --region "$AWS_REGION"
aws logs put-retention-policy --log-group-name "$LOG_GROUP" --retention-in-days 7 --region "$AWS_REGION"
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$CLUSTER_NAME" --output table --region "$AWS_REGION"

# 3. Fluent Bit
kubectl create namespace amazon-cloudwatch
kubectl create configmap fluent-bit-cluster-info \
  --namespace amazon-cloudwatch \
  --from-literal=cluster.name="$CLUSTER_NAME" \
  --from-literal=http.server=On \
  --from-literal=http.port=2020 \
  --from-literal=logs.region="$AWS_REGION"

aws iam put-role-policy \
  --role-name EKSNodeRole-ADS \
  --policy-name CloudWatchLogsAccess \
  --policy-document file://cloudwatch-policy.json

aws iam attach-role-policy \
  --role-name EKSNodeRole-ADS \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

aws eks create-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch-observability \
  --resolve-conflicts OVERWRITE \
  --region "$AWS_REGION" 2>/dev/null || \
aws eks update-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch-observability \
  --resolve-conflicts OVERWRITE \
  --region "$AWS_REGION"

sleep 60
kubectl get pods -n amazon-cloudwatch
kubectl logs -n amazon-cloudwatch -l k8s-app=fluent-bit --tail=10

# 4. Logs coletados
aws logs describe-log-streams \
  --log-group-name "$LOG_GROUP" \
  --order-by LastEventTime \
  --descending \
  --limit 5 \
  --query 'logStreams[].logStreamName' \
  --region "$AWS_REGION"

aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --start-time "$(date -d '5 minutes ago' +%s)000" \
  --limit 10 \
  --query 'events[].message' \
  --output text \
  --region "$AWS_REGION"

# 5. Container Insights
aws eks update-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch-observability \
  --region "$AWS_REGION" 2>/dev/null || \
aws eks create-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch-observability \
  --region "$AWS_REGION"

aws eks describe-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch-observability \
  --query 'addon.{Nome:addonName,Status:status,Versao:addonVersion}' \
  --output table \
  --region "$AWS_REGION"

aws cloudwatch list-metrics \
  --namespace ContainerInsights \
  --dimensions Name=ClusterName,Value="$CLUSTER_NAME" \
  --query 'Metrics[].MetricName' \
  --output text \
  --region "$AWS_REGION"

kubectl top pods -n "$NAMESPACE"
kubectl top nodes

# 6. Alarmes
aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-HighCPU" \
  --alarm-description "CPU acima de 70% no cluster ADS" \
  --namespace ContainerInsights \
  --metric-name pod_cpu_utilization \
  --dimensions Name=ClusterName,Value="$CLUSTER_NAME" \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region "$AWS_REGION"

aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-HighMemory" \
  --alarm-description "Memoria acima de 80% no cluster ADS" \
  --namespace ContainerInsights \
  --metric-name pod_memory_utilization \
  --dimensions Name=ClusterName,Value="$CLUSTER_NAME" \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --treat-missing-data notBreaching \
  --region "$AWS_REGION"

aws cloudwatch put-metric-alarm \
  --alarm-name "EKS-ADS-UnhealthyPods" \
  --alarm-description "Pods nao saudaveis no namespace ads-unifaat" \
  --namespace ContainerInsights \
  --metric-name pod_status_failed \
  --dimensions Name=ClusterName,Value="$CLUSTER_NAME" Name=Namespace,Value="$NAMESPACE" \
  --statistic Sum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --treat-missing-data notBreaching \
  --region "$AWS_REGION"

aws cloudwatch describe-alarms \
  --alarm-name-prefix "EKS-ADS" \
  --query 'MetricAlarms[].{Nome:AlarmName,Estado:StateValue,Threshold:Threshold}' \
  --output table \
  --region "$AWS_REGION"

# 7. Dashboard
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
  --region "$AWS_REGION"

# 8. Trafego
ENDPOINT=$(kubectl get svc ads-site-service -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ENDPOINT"

for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}" "http://$ENDPOINT"
  echo " - Request $i"
done

kubectl top pods -n "$NAMESPACE"
kubectl top nodes
kubectl logs -n "$NAMESPACE" -l app=ads-site --tail=10

# 9. Limpeza
aws cloudwatch delete-alarms \
  --alarm-names "EKS-ADS-HighCPU" "EKS-ADS-HighMemory" "EKS-ADS-UnhealthyPods" \
  --region "$AWS_REGION"

aws cloudwatch delete-dashboards \
  --dashboard-names "EKS-ADS-Dashboard" \
  --region "$AWS_REGION"

aws logs delete-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION"

kubectl delete namespace amazon-cloudwatch
