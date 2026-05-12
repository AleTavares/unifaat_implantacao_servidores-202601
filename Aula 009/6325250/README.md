# Tarefa Final - Aula 09: Kubernetes (K8s)

## RA: 6325250

---

## Questão 1: Arquitetura e Componentes (Teórica)

### a) Função do Control Plane (Master):
O **Control Plane** é responsável por gerenciar o estado desejado do cluster. Ele coordena todas as atividades dentro do cluster, como agendamento de Pods, manutenção do estado desejado e tomada de decisões sobre o cluster.

**Componente chave:** **etcd** - é um banco de dados distribuído que armazena todo o estado do cluster de forma persistente.

Outros componentes do Control Plane incluem:
- **kube-apiserver** - expõe a API do Kubernetes
- **kube-controller-manager** - executa controladores que regulam o estado do cluster
- **kube-scheduler** - responsável por agendar Pods nos Worker Nodes

### b) Principal software nos Worker Nodes:
O **kubelet** é o agente principal que reside em cada Worker Node. Ele é responsável por garantir que os Pods desejados estejam rodando e saudáveis no nó, mantendo a comunicação com o Control Plane e executando as ações necessárias para atingir o "estado desejado".

---

## Questão 2: O Pod (Conceito Fundamental) (Teórica)

### a) Por que um Pod pode conter múltiplos contêineres:
Um **Pod** é a unidade fundamental de deployment no Kubernetes e pode conter múltiplos contêineres porque eles precisam trabalhar juntos de forma muito acoplada. Os contêineres dentro de um Pod compartilham:
- **Rede:** Mesmo endereço IP e namespace de rede (comunicação via localhost)
- **Storage:** Volumes compartilhados (storage volumes)
- **Recursos:** Podem compartilhar CPU e memória do Pod

A principal regra é que todos os contêineres em um Pod compartilham o **namespace de rede**, permitindo comunicação rápida entre eles via localhost.

### b) Por que é inadequado criar Pods diretamente em produção:
É uma prática inadequada porque:
- **Falta de Replicação:** Pods criados diretamente não são replicados automaticamente
- **Sem Recuperação Automática:** Se um Pod falhar, não é recriado automaticamente
- **Sem Rolling Updates:** Não é possível fazer atualizações de imagem de forma controlada
- **Sem Escalabilidade:** Não é possível escalar a aplicação dinamicamente

Por isso, se usa **Deployments**, que gerenciam Pods automaticamente.

---

## Questão 3: Manifesto YAML (Prática Teórica)

Os **quatro campos obrigatórios** que devem estar presentes na raiz de qualquer manifesto YAML de objeto Kubernetes são:

1. **apiVersion** - Define a versão da API do Kubernetes (ex: `apps/v1`, `v1`)
2. **kind** - Define o tipo de objeto (ex: `Pod`, `Deployment`, `Service`)
3. **metadata** - Contém informações sobre o objeto, como `name` (obrigatório) e `labels`
4. **spec** - Define a especificação/configuração do objeto (variam conforme o tipo)

---

## Questão 4: Deployment (Prática)

Manifesto YAML completo para o Deployment `nginx-deploy-tf09` foi criado no arquivo `deployment.yaml`.

**Requisitos atendidos:**
- ✅ Nome: `nginx-deploy-tf09`
- ✅ Imagem: `nginx:latest`
- ✅ Réplicas: 3 instâncias do Pod
- ✅ Label: Pod com `app: web-tf09`

---

## Questão 5: Service (Prática)

Manifesto YAML completo para o Service `web-service-tf09` foi criado no arquivo `service.yaml`.

**Requisitos atendidos:**
- ✅ Nome: `web-service-tf09`
- ✅ Seletor: `app: web-tf09` (seleciona Pods do Deployment)
- ✅ Tipo: `NodePort` (acesso externo)
- ✅ Port: 80 (Service Port) e targetPort: 80 (Porta do contêiner)

---

## Tarefa Prática Integrada: Fluxo de Comunicação

### Cenário:
Um usuário final tenta acessar a aplicação Nginx através de um NodePort em um dos Nodes do Cluster K8s.

### Descrição do Fluxo (4 componentes envolvidos):

1. **Entrada - NodePort:**
   A requisição chega na porta do **NodePort** (ex: IP_do_Node:30000).
   O sistema operacional do Node recebe a requisição na porta especificada.

2. **Service (web-service-tf09):**
   O Service `web-service-tf09` intercepta a requisição. Ele usa o campo **selector** (que contém as labels `app: web-tf09`) para saber quais Pods são elegíveis para receber a requisição. O Service mantém uma lista de Pods que correspondem às labels especificadas no seletor.

3. **Proxy (kube-proxy):**
   O **kube-proxy** é o componente dentro do K8s responsável por rotear o tráfego do Service para um dos Pods ativos. Ele implementa as regras de roteamento no kernel do Node (através de iptables ou ipvs) para encaminhar o tráfego da porta do Service para os Pods.

4. **Destino Final - Pod (nginx):**
   A requisição é roteada para um dos 3 Pods gerenciados pelo Deployment na porta 80 (containerPort). O contêiner nginx dentro do Pod processa a requisição e retorna a resposta.

### Resumo do Fluxo:
```
Usuário → NodeIP:NodePort → Service (selector) → kube-proxy → Pod (nginx:80)
```

---

## Passo a Passo para Subir o Ambiente

### Pré-requisitos:
- Cluster Kubernetes funcionando (Minikube, KinD, ou cluster real)
- `kubectl` instalado e configurado

### Passos:

1. **Entrar na pasta do projeto:**
   ```bash
   cd /home/fabio/Área\ de\ trabalho/repositorios/unifaat_implantacao_servidores-202601/Aula\ 009/6325250
   ```

2. **Aplicar o Deployment:**
   ```bash
   kubectl apply -f deployment.yaml
   ```
   Verifique que o Deployment foi criado:
   ```bash
   kubectl get deployments
   kubectl get pods
   ```

3. **Aplicar o Service:**
   ```bash
   kubectl apply -f service.yaml
   ```
   Verifique que o Service foi criado:
   ```bash
   kubectl get services
   ```

4. **Obter a porta NodePort:**
   ```bash
   kubectl get service web-service-tf09
   ```
   Anote a porta NODE-PORT (ex: 30000+).

5. **Acessar a aplicação Nginx:**
   
   Se estiver usando **Minikube:**
   ```bash
   minikube service web-service-tf09
   ```
   Ou acesse manualmente:
   ```bash
   curl http://$(minikube ip):PORT
   ```

   Se estiver em um cluster real:
   ```bash
   curl http://IP_DO_NODE:PORTA_NODEPORT
   ```

6. **Verificar os Pods:**
   ```bash
   kubectl get pods -l app=web-tf09
   kubectl describe pod <nome_do_pod>
   ```

7. **Deletar recursos (quando terminar):**
   ```bash
   kubectl delete -f deployment.yaml
   kubectl delete -f service.yaml
   ```
   Ou simplesmente:
   ```bash
   kubectl delete service web-service-tf09
   kubectl delete deployment nginx-deploy-tf09
   ```

---

## Evidências:
- `deployment.yaml` - Manifesto do Deployment
- `service.yaml` - Manifesto do Service
- Este arquivo `README.md` com as respostas teóricas e procedimento de implantação
