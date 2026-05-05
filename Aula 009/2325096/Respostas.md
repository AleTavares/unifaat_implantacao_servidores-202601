# TF - Aula 09 Kubernetes

## Questão 1
a) O Control Plane é responsável por gerenciar o cluster Kubernetes, garantindo o estado desejado, agendamento de workloads e controle geral. Um componente importante é o etcd, que armazena o estado do cluster.

b) O kubelet é o agente nos Worker Nodes responsável por garantir que os Pods estejam rodando corretamente e no estado desejado.

---

## Questão 2
a) Um Pod pode conter múltiplos containers quando precisam trabalhar juntos. Eles compartilham rede (mesmo IP), armazenamento e namespace.

b) Criar Pods diretamente não é recomendado pois não há auto-recuperação ou escalabilidade. Deployments fazem esse controle.

---

## Questão 3
Os campos obrigatórios são:
- apiVersion
- kind
- metadata
- spec

---

## Questão 4 - Deployment YAML
Arquivo: deployment.yaml (já implementado no projeto)

---

## Questão 5 - Service YAML
Arquivo: service.yaml (já implementado no projeto)

---

## Fluxo de comunicação

1. Usuário acessa NodeIP:30080
2. Service web-service-tf09 recebe a requisição
3. O Service usa o selector (app: web-tf09) para localizar Pods
4. kube-proxy roteia o tráfego para um Pod disponível
5. O Pod recebe a requisição na porta 80