# TF - Tarefa Final - Aula 13
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aluno:** [Seu Nome Completo]  
**RA:** [Seu RA Aqui]  

---

## 📝 Partes Teóricas e Simulação (Questões 1 a 5)

### Questão 1: Conceitos de Kubernetes e EKS
* **a) Control Plane vs Worker Nodes:**
  * **Control Plane:** É o "cérebro" do cluster. Ele toma decisões globais (como agendamento de pods) e detecta/responde a eventos. No Amazon EKS, ele é totalmente gerenciado e mantido pela AWS.
  * **Worker Nodes:** São as instâncias EC2 que efetivamente executam os containers (Pods). Eles fornecem o poder de computação e memória, sendo gerenciados pelo usuário via Node Groups.
* **b) Self-Healing:**
  * É a capacidade do Kubernetes de monitorar a saúde do cluster e recuperar aplicações automaticamente. Se um Pod falhar ou travar, o Kubernetes detecta a falha, destrói o container problemático e cria um novo pod saudável instantaneamente para substituí-lo.

### Questão 2: Objetos Kubernetes
* **a) Deployment vs Service:**
  * **Deployment:** Define o estado desejado da aplicação (imagem do ECR, quantidade de réplicas, estratégia de update) e gerencia o ciclo de vida dos Pods.
  * **Service:** Fornece um IP fixo e um nome DNS estável para os Pods. Como os Pods são efêmeros e mudam de IP ao morrer, o Service garante que a comunicação não se perca.
* **b) Labels e Selectors:**
  * **Labels:** São etiquetas de chave/valor (ex: `app: minha-app`) anexadas aos Pods.
  * **Selectors:** São os filtros definidos no Service para encontrar e direcionar o tráfego de rede exatamente para os Pods que possuem as Labels correspondentes.
* **c) Probes:**
  * **livenessProbe:** Verifica se o container está vivo. *Exemplo prático:* Se um servidor web travar em loop infinito, ela falha e o Kubernetes reinicia o container.
  * **readinessProbe:** Verifica se o container está pronto para receber tráfego. *Exemplo prático:* Impede que o Service envie usuários para uma aplicação Java que ainda está carregando o banco de dados durante o boot.

### Questão 3: IAM e Permissões
* **a) EKSClusterRole:**
  * Permite que o Control Plane do EKS converse com a API da AWS para gerenciar recursos em nome do usuário, como criar Security Groups, anexar interfaces de rede (ENIs) e provisionar Load Balancers.
* **b) AmazonEC2ContainerRegistryReadOnly:**
  * Dá permissão para os Worker Nodes (EC2) fazerem o download (`pull`) das imagens de container guardadas no AWS ECR. Sem ela, os Pods falham com o erro `ImagePullBackOff`.

### Questão 4: Networking e Exposição
* **a) ClusterIP vs NodePort vs LoadBalancer:**
  * **ClusterIP:** Expõe o serviço apenas internamente no cluster (padrão).
  * **NodePort:** Expõe o serviço em uma porta fixa em cada nó do cluster, acessível de fora.
  * **LoadBalancer:** Cria um balanceador de carga na nuvem (AWS) e expõe a aplicação diretamente para a internet.
* **b) Provisionamento na AWS:**
  * O EKS cria automaticamente um Classic Load Balancer (CLB) ou Network Load Balancer (NLB) na infraestrutura da AWS, gerando um link de DNS público.
* **c) Ordem de Deleção:**
  * O LoadBalancer deve ser deletado antes do cluster porque ele é criado dinamicamente. Se o cluster sumir primeiro, o LoadBalancer vira um recurso "órfão", gerando cobranças desnecessárias na conta AWS.

### Questão 5: Tarefa Prática - Comandos EKS (Simulação)
```bash
# a) Criar o namespace
kubectl create namespace minha-app

# b) Criar o Deployment com 3 réplicas
kubectl create deployment web-app --image=[111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0](https://111222333444.dkr.ecr.us-east-1.amazonaws.com/web-app:v2.0) --replicas=3 -n minha-app

# c) Expor a aplicação com LoadBalancer
kubectl expose deployment web-app --type=LoadBalancer --port=80 --target-port=80 -n minha-app

# d) Escalar para 5 réplicas
kubectl scale deployment web-app --replicas=5 -n minha-app

# e) Verificar status e endpoint
kubectl get pods -n minha-app
kubectl get svc web-app -n minha-app

## 📸 Evidências Práticas da Execução (Lab013)

### Parte 1: Construção e Teste Local
Abaixo estão as evidências da aplicação web construída e testada localmente via Docker Desktop no ambiente WSL2.

#### 1. Build da Imagem Docker!
<img width="1180" height="117" alt="print2" src="https://github.com/user-attachments/assets/6cc3a54a-8f8f-4717-bab4-5b1e3db3e830" />

#### 2. Teste Local (Curl ou Navegador)
<img width="1536" height="690" alt="print-ads" src="https://github.com/user-attachments/assets/189d22ef-da08-4ebd-b7eb-fca195cbc3a9" />


## ⚠️ Observações
A estrutura lógica e a sintaxe de todos os arquivos de configuração (Dockerfile, index.html, styles.css) e os comandos imperativos foram validados localmente com sucesso, conforme as evidências da Parte 1.
