# TF - Aula 09 Kubernetes

## Questão 1
a) O Control Plane gerencia o cluster e mantém o estado desejado. Ex: etcd  
b) kubelet

## Questão 2
a) Containers compartilham rede e storage dentro do Pod  
b) Não é recomendado porque não escala nem se recupera sozinho

## Questão 3
apiVersion, kind, metadata, spec

## Fluxo
1. Requisição chega no NodePort (Node IP:30007)
2. Service usa selector (app: web-tf09)
3. kube-proxy roteia
4. Chega no Pod (porta 80)

## Como executar
kubectl apply -f deployment.yaml  
kubectl apply -f service.yaml  
kubectl get pods  
kubectl get svc  