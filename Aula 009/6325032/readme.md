✅ Questão 1: Arquitetura e Componentes
a)

O Control Plane é responsável por gerenciar o cluster Kubernetes, tomando decisões como:

agendamento de Pods
manutenção do estado desejado
controle geral do cluster

Um componente chave é o etcd, que armazena todos os dados do cluster.

b)

O principal software nos Worker Nodes é o:

👉 kubelet

Ele garante que os Pods estejam rodando corretamente, mantendo o estado desejado.

✅ Questão 2: O Pod
a)

Um Pod pode ter múltiplos containers quando eles precisam trabalhar juntos (ex: app + sidecar).

Eles compartilham:

🌐 mesma rede (IP/porta)
💾 volumes (storage)
b)

Criar Pods diretamente é inadequado porque:

❌ não possuem auto-recuperação
❌ não escalam automaticamente
❌ não fazem rolling update

👉 Em produção, usamos Deployment.

![alt text](image.png)