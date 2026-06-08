# TF Aula 009 - Kubernetes

Aluno: Rafael Maruca  
RA: 6322006  

---

## Questão 1

O Control Plane é responsável por gerenciar o cluster Kubernetes, tomando decisões como agendamento de Pods e mantendo o estado desejado. Um componente chave é o etcd.

Nos Worker Nodes, o principal software é o kubelet, responsável por garantir que os Pods estejam rodando corretamente.

---

## Questão 2

Um Pod pode conter múltiplos containers porque eles compartilham o mesmo ambiente, incluindo rede (mesmo IP) e armazenamento (volumes).

Não é recomendado criar Pods diretamente em produção porque eles não possuem controle de escalabilidade, atualização e recuperação automática. Para isso, utiliza-se Deployment.

---

## Questão 3

Os campos obrigatórios são:

- apiVersion  
- kind  
- metadata  
- spec  

---

## Questão 4

Deployment definido no arquivo deployment.yaml.

---

## Questão 5

Service definido no arquivo service.yaml.

---

## Fluxo de Comunicação

1. A requisição chega no Node através da porta NodePort (ex: IP:30007).  
2. O Service web-service-tf09 intercepta a requisição e usa o campo **selector** para identificar os Pods elegíveis.  
3. O **kube-proxy** é responsável por rotear o tráfego para um dos Pods disponíveis.  
4. A requisição chega ao Pod na porta 80, gerenciado pelo Deployment.  

---

## Passo a passo para subir o ambiente

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get pods
kubectl get services