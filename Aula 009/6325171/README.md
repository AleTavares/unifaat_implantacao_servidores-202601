# Tarefa Final - Aula 09 (Kubernetes)

## Aluno
RA: 6325171

---

## 1. Arquitetura Kubernetes

### a) Control Plane
O Control Plane é responsável por gerenciar todo o cluster Kubernetes, tomando decisões como agendamento de Pods, manutenção do estado desejado e controle geral do sistema.

Componentes principais:
- kube-apiserver
- etcd
- kube-scheduler
- controller-manager

---

### b) Worker Node
O principal componente dos Worker Nodes é o kubelet, responsável por garantir que os Pods estejam rodando corretamente e mantendo o estado desejado definido pelo Control Plane.

---

## 2. Conceito de Pod

### a)
Um Pod pode conter múltiplos containers porque eles compartilham rede (IP), armazenamento e ciclo de vida, permitindo que trabalhem juntos como uma unidade.

### b)
Não é recomendado criar Pods diretamente porque eles não possuem auto-recuperação, escalabilidade ou gerenciamento de estado. Por isso utilizamos Deployments.

---

## 3. Estrutura YAML Kubernetes

Todo objeto Kubernetes possui os seguintes campos obrigatórios:
- apiVersion
- kind
- metadata
- spec

---

## 4. Deployment

O Deployment abaixo cria 3 réplicas da aplicação Nginx:

(ver arquivo deployment.yaml)

---

## 5. Service

O Service abaixo expõe a aplicação via NodePort:

(ver arquivo service.yaml)

---

## 6. Fluxo da Aplicação

O fluxo de acesso é:

1. Usuário acessa NodeIP:30080
2. O Service (web-service-tf09) recebe a requisição
3. O Service usa o selector app: web-tf09
4. O kube-proxy realiza o balanceamento de carga
5. A requisição chega em um Pod gerenciado pelo Deployment
6. O container Nginx responde na porta 80

---

## 7. Conclusão

O Kubernetes permite escalabilidade, alta disponibilidade e gerenciamento automático de containers através de Deployments e Services.