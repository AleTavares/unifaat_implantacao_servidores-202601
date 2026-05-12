# TF09 - Kubernetes
**RA:** 6325101  
**Aluno:** Claudio

---

## Questão 1: Arquitetura e Componentes

### a)
O Control Plane é responsável por gerenciar o cluster Kubernetes, controlar os recursos, manter o estado desejado e coordenar a comunicação entre os nós.

Componente chave: **etcd**

O etcd armazena todas as configurações e o estado do cluster.

### b)
O principal software que reside nos Worker Nodes é o **kubelet**.

Ele garante que os Pods definidos estejam rodando corretamente e mantém o estado desejado.

---

## Questão 2: O Pod

### a)
Um Pod pode conter múltiplos contêineres quando eles precisam trabalhar juntos.

Esses contêineres compartilham:

- Rede (mesmo IP)
- Storage
- Namespace

### b)
Criar Pods diretamente em produção é inadequado porque eles não possuem gerenciamento automático.

Se falharem, não serão recriados automaticamente.

O ideal é usar Deployment.

---

## Questão 3: Manifesto YAML

Os quatro campos obrigatórios são:

- apiVersion
- kind
- metadata
- spec

---

## Questão 4: Deployment

Arquivo: `deployment.yaml`

Deployment criado com:

- Nome: nginx-deploy-tf09
- Imagem: nginx:latest
- Réplicas: 3
- Label: app: web-tf09

---

## Questão 5: Service

Arquivo: `service.yaml`

Service criado com:

- Nome: web-service-tf09
- Tipo: NodePort
- Porta: 80
- TargetPort: 80

---

## Tarefa Prática Integrada

Fluxo da comunicação:

### 1. Entrada
A requisição chega ao Node através da porta NodePort.

Exemplo:

NodeIP:30000

### 2. Service
O Service intercepta a requisição.

Ele usa o campo:

**selector**

Para identificar os Pods elegíveis.

### 3. Proxy
O **kube-proxy** roteia o tráfego para um dos Pods disponíveis.

### 4. Destino Final
A requisição chega a um Pod gerenciado pelo Deployment na porta 80.

---

## Passo a passo para subir o ambiente

### Criar Deployment

```bash
kubectl apply -f deployment.yaml
