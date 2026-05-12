# Resposta TF009 - RA 6325269

## Questão 1: Arquitetura e Componentes (Teórica)

a) O Control Plane gerencia o estado desejado do cluster, mantém a configuração global e toma decisões de orquestração. Um componente chave que reside nele é o `kube-apiserver` (ou `etcd` como repositório de dados do cluster).

b) O principal software nos Worker Nodes é o `kubelet`, que garante que os Pods desejados estejam rodando e saudáveis.

## Questão 2: O Pod (Conceito Fundamental) (Teórica)

a) Um Pod pode conter múltiplos contêineres quando esses contêineres trabalham juntos em uma mesma unidade lógica, como um aplicativo principal e um sidecar de suporte. A principal regra que eles compartilham é o mesmo namespace de rede e os mesmos volumes de armazenamento, permitindo comunicação local por `localhost` e acesso compartilhado a dados.

b) Criar Pods diretamente em produção é inadequado porque eles não são gerenciados por um controlador. Sem um controlador como Deployment, não há auto-recuperação, escalabilidade automática, rollback ou atualizações contínuas.

## Questão 3: Manifesto YAML (Prática Teórica)

Os quatro campos obrigatórios na raiz de qualquer manifesto Kubernetes são:
- `apiVersion`
- `kind`
- `metadata`
- `spec`

## Questão 4: Deployment (Prática)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-tf09
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-tf09
  template:
    metadata:
      labels:
        app: web-tf09
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

## Questão 5: Service (Prática)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-tf09
spec:
  type: NodePort
  selector:
    app: web-tf09
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
```

## Tarefa Prática Integrada (Obrigatória - Conceitual)

Fluxo de comunicação e gerenciamento:

1. O usuário faz a requisição para o Node IP na porta do NodePort exposto pelo Service.
2. O Service `web-service-tf09` intercepta a requisição e usa o campo `selector` para identificar quais Pods são elegíveis.
3. O componente `kube-proxy` no Node é responsável por rotear o tráfego do Service para um dos Pods ativos.
4. A requisição chega a um dos Pods gerenciados pelo Deployment `nginx-deploy-tf09` na porta 80.

### Objetos/componentes envolvidos na ordem correta:
- `NodePort`
- `Service` (`selector`)
- `kube-proxy`
- `Pod` (gerenciado pelo Deployment)
