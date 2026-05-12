# TF Aula 09 - Kubernetes

## Questão 1

### a)
O Control Plane gerencia o cluster Kubernetes e mantém o estado desejado das aplicações.

Componente:
- etcd

### b)
O principal software dos Worker Nodes é o:

- kubelet

---

## Questão 2

### a)
Um Pod pode ter múltiplos containers que trabalham juntos.

Eles compartilham:
- rede
- armazenamento

### b)
Não é recomendado criar Pods diretamente em produção porque:

- não possuem auto recuperação
- não fazem escalabilidade
- se falharem, não voltam automaticamente

Por isso usamos Deployment.

---

## Questão 3

Campos obrigatórios:

- apiVersion
- kind
- metadata
- spec

---

## Fluxo de comunicação

1. Usuário acessa o NodePort
2. O Service usa selector para localizar os Pods
3. kube-proxy roteia o tráfego
4. A requisição chega ao Pod na porta 80

---

## Passo a passo para subir o ambiente

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods
kubectl get services
