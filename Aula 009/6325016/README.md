# TF - Aula 09

## Questão 1

a) O Control Plane é responsável por gerenciar todo o cluster Kubernetes, garantindo que o estado desejado das aplicações seja mantido. Um dos seus principais componentes é o etcd, que armazena os dados do cluster.

b) O principal software nos Worker Nodes é o kubelet, responsável por garantir que o estado desejado dos Pods seja mantido, verificando se eles estão em execução e saudáveis.

---

## Questão 2

a) Um Pod pode conter múltiplos contêineres para que trabalhem juntos como uma única unidade. Esses contêineres compartilham o mesmo namespace de rede (IP e portas) e podem compartilhar volumes de armazenamento.

b) Não é recomendado criar Pods diretamente em produção porque eles não são gerenciados automaticamente. Caso falhem, não serão recriados. O ideal é usar Deployments.

---

## Questão 3

Os quatro campos obrigatórios são:

* apiVersion
* kind
* metadata
* spec

---

## Questão 4 - Deployment

O manifesto foi criado no arquivo deployment.yaml conforme solicitado, contendo:

- Nome: nginx-deploy-tf09
- Imagem: nginx:latest
- Réplicas: 3
- Label: app: web-tf09

---

## Questão 5 - Service

O manifesto foi criado no arquivo service.yaml com as seguintes configurações:

- Nome: web-service-tf09
- Tipo: NodePort
- Porta: 80
- TargetPort: 80
- Selector: app: web-tf09

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
