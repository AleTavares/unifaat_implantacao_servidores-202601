# TF - Tarefa Final - Aula 09

## Questão 1

a) O Control Plane é responsável por gerenciar todo o cluster Kubernetes, garantindo que o estado desejado das aplicações seja mantido. Um dos seus principais componentes é o etcd, que armazena os dados do cluster.

b) Nos Worker Nodes, o kubelet é o software central. Ele cuida para que os Pods fiquem no estado que foi definido, checando se estão rodando e sem problemas.

---

## Questão 2

a) Pods podem ter múltiplos contêineres quando eles precisam trabalhar juntos como uma unidade. A principal regra é que compartilham a mesma rede com IP único e podem compartilhar volumes de armazenamento.

b) Não é recomendado criar Pods diretamente em produção porque eles não são gerenciados automaticamente. Caso falhem, não serão recriados. O ideal é usar Deployments.

---

## Questão 3

Os quatro campos obrigatórios são:

* spec
* kind
* apiVersion
* metadata

---

## Questão 4 - Deployment

Arquivo: deployment.yaml

---

## Questão 5 - Service

Arquivo: service.yaml

---

## Fluxo de Comunicação

1. A requisição chega na porta NodePort do Node.
2. O Service web-service-tf09 usa o campo selector para identificar os Pods com label app: web-tf09.
3. O kube-proxy é responsável por rotear o tráfego para um dos Pods disponíveis.
4. A requisição chega ao Pod na porta 80, onde o container Nginx responde.

## Execução do projeto

1. Iniciar o cluster Kubernetes:
   minikube start

2. Aplicar os manifestos:
   minikube kubectl -- apply -f deployment.yaml
   minikube kubectl -- apply -f service.yaml

3. Verificar os pods:
   minikube kubectl -- get pods

4. Verificar o service:
   minikube kubectl -- get services

5. Acessar a aplicação:
   minikube service web-service-tf09
