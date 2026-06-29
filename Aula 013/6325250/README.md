# TF Aula 013 - RA 6325250

## Respostas

### Questão 1 — Conceitos de Kubernetes e EKS

- **Control Plane vs Worker Nodes:** O Control Plane agrega componentes responsáveis pelo gerenciamento do cluster (kube-apiserver, kube-scheduler, controller-manager, etcd). No Amazon EKS o Control Plane é fornecido e gerenciado pela AWS como serviço gerenciado. Os Worker Nodes são as instâncias que executam os containers (Pods) — normalmente EC2 ou Fargate — e sua configuração e manutenção (NodeGroups, policies, atualizações) ficam a cargo do usuário/administrador do cluster.
- **Self-healing:** Kubernetes mantém o estado desejado definido pelos objetos (Deployment/ReplicaSet). Se um Pod falha ou entra em CrashLoop, o controlador (ReplicaSet/Deployment) detecta a divergência e cria novos Pods para restaurar o número de réplicas; `livenessProbe` pode forçar restart de containers; se um node sair do cluster, o scheduler reagenda os Pods em outros nodes disponíveis.

### Questão 2 — Objetos Kubernetes

- **Deployment vs Service:** Um `Deployment` descreve o estado desejado de um conjunto de Pods (imagem, réplicas, estratégia de atualização, rollout/rollback) e garante que o número de réplicas esteja conforme. Um `Service` fornece um endpoint de rede estável (virtual IP/hostname) para acessar Pods que satisfaçam um selector, abstraindo a instabilidade de Pods individuais.
- **Labels e Selectors:** `Labels` são pares chave/valor atribuídos a objetos (pods, deployments). `Selectors` são consultas usadas por controllers e Services para identificar o conjunto de objetos alvo com base nas labels. Um `Service` usa um selector para rotear tráfego apenas para os Pods que tiverem as labels correspondentes.
- **Probes (liveness/readiness):** `livenessProbe` verifica se o processo dentro do container está vivo; se falhar, o kubelet reinicia o container. `readinessProbe` indica se o Pod está pronto para receber tráfego; se falso, o Pod é removido do balanceamento até voltar a estar pronto. Exemplo prático: um serviço que precisa carregar caches ao iniciar usa `readinessProbe` para evitar receber tráfego antes do warm-up; um deadlock detectado por `livenessProbe` força restart do processo.

### Questão 3 — IAM e Permissões

- **EKSClusterRole:** O cluster EKS precisa de uma IAM Role (assumida pelo serviço EKS) para executar ações na conta AWS em nome do cluster — por exemplo criar e gerenciar ENIs, configurar logs/CloudWatch, provisionar recursos relacionados a networking e integração com serviços AWS. Sem permissões adequadas o control plane não consegue integrar recursos necessários.
- **AmazonEC2ContainerRegistryReadOnly nos nodes:** Nodes precisam dessa permissão para autenticar e puxar imagens privadas hospedadas no ECR. Sem essa política os nodes não conseguirão fazer pull das imagens do repositório ECR, causando falhas de pull (ErrImagePull / ImagePullBackOff) e impedindo que os Pods iniciem.

### Questão 4 — Networking e Exposição

- **ClusterIP / NodePort / LoadBalancer:** `ClusterIP` expõe o serviço apenas internamente dentro do cluster; `NodePort` abre uma porta estática em cada node permitindo acesso externo via IP_do_node:NodePort; `LoadBalancer` solicita a criação de um balanceador externo pela cloud para expor o serviço publicamente.
- **O que a AWS provisiona para `LoadBalancer`:** Ao criar um Service do tipo `LoadBalancer`, o EKS/AWS provisiona automaticamente um recurso de balanceamento (ELB — ALB/NLB/CLB conforme controller e anotações) além dos recursos auxiliares (security groups, target groups, listeners), e vincula o tráfego ao conjunto de endpoints do cluster.
- **Por que deletar o Service antes do cluster:** Deletar o `Service` do tipo `LoadBalancer` garante que o balanceador e recursos associados sejam removidos corretamente pelo provedor e evita recursos órfãos (custos residuais) ou bloqueios causados por finalizers que podem impedir a destruição limpa do cluster.
