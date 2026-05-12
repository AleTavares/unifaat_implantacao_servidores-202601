## Questão 1

a) O Control Plane gerencia o cluster e mantém o estado desejado. Ex: etcd
b) kubelet

## Questão 2

a) Para containers que trabalham juntos compartilhando rede e armazenamento
b) Porque não são escaláveis nem resilientes (não se auto recuperam)

## Questão 3
apiVersion
kind
metadata
spec
_____________________________________________________

## Como executar
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods
kubectl get svc

____________________________________________________

### Descrição do Fluxo

1. **Entrada:** A requisição chega ao Node do cluster através da porta NodePort (ex: Node IP:30000).

2. **Service:** O Service web-service-tf09 intercepta a requisição e utiliza o campo **selector (label app: web-tf09)** para identificar quais Pods são elegíveis.

3. **Proxy:** O **kube-proxy** é o componente responsável por rotear o tráfego do Service para um dos Pods ativos, realizando o balanceamento de carga.

4. **Destino Final:** A requisição chega a um dos Pods gerenciados pelo Deployment nginx-deploy-tf09, na porta 80 do container.