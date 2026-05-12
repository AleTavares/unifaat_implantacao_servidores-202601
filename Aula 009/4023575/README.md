# TF - Aula 09 - Kubernetes

## Questão 1

**a)**
O Control Plane é responsável por gerenciar o cluster Kubernetes, tomando decisões sobre onde os Pods serão executados e garantindo o estado desejado.

Componente: **etcd**, responsável por armazenar o estado do cluster.

**b)**
O principal software nos Worker Nodes é o **kubelet**, responsável por garantir que os Pods estejam rodando corretamente.

---

## Questão 2

**a)**
Um Pod pode conter múltiplos contêineres que trabalham juntos. Eles compartilham:

* Rede (mesmo IP)
* Storage (volumes)

**b)**
Não é recomendado criar Pods diretamente em produção porque:

* Não há auto-recuperação
* Não há escalabilidade automática
* Não suporta atualizações rolling

---

## Questão 3

Campos obrigatórios de um manifesto Kubernetes:

* apiVersion
* kind
* metadata
* spec

---

## Questão 4 - Deployment

Arquivo: deployment.yaml

---

## Questão 5 - Service

Arquivo: service.yaml

---

## Fluxo de Comunicação

1. O usuário acessa a aplicação via NodeIP:30000
2. O Service web-service-tf09 recebe a requisição
3. O Service usa o selector **app: web-tf09** para identificar os Pods
4. O **kube-proxy** roteia a requisição para um dos Pods
5. O Pod recebe a requisição na porta 80

---

## Passo a Passo

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get pods
kubectl get svc

# acessar via navegador
http://<IP_DO_NODE>:30000
```
