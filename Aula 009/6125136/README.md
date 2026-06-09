# TF - Aula 009 - Kubernetes
**Aluno:** Hector Marcelo Pedroso Dos Santos  
**RA:** 6125136

## Questão 1
**a)** O Control Plane é o cérebro do cluster Kubernetes — ele gerencia o estado desejado, toma decisões de agendamento e monitora todos os recursos. Um componente chave é o **etcd**, banco de dados distribuído que armazena todo o estado do cluster.

**b)** O **Kubelet** — roda em cada Worker Node e garante que os containers dos Pods estejam rodando e saudáveis conforme o estado desejado.

## Questão 2
**a)** Um Pod pode conter múltiplos containers quando precisam trabalhar de forma acoplada. Eles compartilham a mesma **rede** (mesmo IP e portas) e o mesmo **armazenamento** (volumes).

**b)** É uma prática inadequada pois Pods criados diretamente não possuem **auto-recuperação** — se um Pod morrer, ninguém o recria automaticamente. O Deployment garante que o estado desejado seja sempre mantido.

## Questão 3
Os quatro campos obrigatórios em qualquer manifesto YAML do K8s são:
- `apiVersion`
- `kind`
- `metadata`
- `spec`

## Questão 4
Ver arquivo `deployment.yaml`

## Questão 5
Ver arquivo `service.yaml`

## Tarefa Prática Integrada
1. **Entrada:** A requisição chega no Node na porta `30000` (NodePort)
2. **Service:** O `web-service-tf09` intercepta e usa o campo **selector** (`app: web-tf09`) para identificar quais Pods são elegíveis
3. **Proxy:** O **kube-proxy** roteia o tráfego do Service para um dos Pods ativos fazendo load balancing
4. **Destino Final:** A requisição chega em um dos 3 Pods gerenciados pelo `nginx-deploy-tf09` na porta `80`

## Passo a Passo para Subir o Ambiente

### 1. Iniciar o Minikube
```bash
minikube start --driver=docker
```

### 2. Aplicar os manifestos
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 3. Verificar os recursos
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

### 4. Acessar a aplicação
```bash
minikube service web-service-tf09 --url
```

### 5. Escalar o Deployment
```bash
kubectl scale deployment nginx-deploy-tf09 --replicas=5
kubectl get pods
```

### 6. Limpeza do ambiente
```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
minikube stop
```