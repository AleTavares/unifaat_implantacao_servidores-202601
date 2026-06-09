QUESTOES
1
A) O Control Plane é a parte central de gerenciamento de um cluster Kubernetes. Ele é responsável por tomar decisões globais,Um componente chave que reside nele é o etcd, que é um banco de dados distribuído onde ficam armazenadas todas as informações do cluster

B)Ele é responsável por:

garantir que os Pods definidos pelo Control Plane estejam rodando no nó,
verificar se os containers estão saudáveis,
iniciar, parar ou reiniciar containers quando necessário,
comunicar o status do nó e dos pods para o Control Plane.

Ou seja, o kubelet é quem realmente faz o estado desejado acontecer na prática dentro de cada máquina do cluster.

2

A)Um Pod pode conter múltiplos contêineres porque eles podem trabalhar juntos como uma única unidade lógica. Isso é comum quando você usa o padrão sidecar, por exemplo:


um contêiner principal (sua aplicação),


outro contêiner auxiliar (logs, proxy, monitoramento, etc.).


Esses contêineres ficam no mesmo Pod porque precisam estar fortemente acoplados, com comunicação rápida e direta.
A principal regra é que eles compartilham o mesmo ambiente, especialmente:


rede: todos usam o mesmo IP e porta localhost (um contêiner pode acessar o outro via localhost),


armazenamento (volumes): podem montar e acessar os mesmos volumes,


namespace: compartilham contexto dentro do Pod.


Ou seja, apesar de serem contêineres separados, eles se comportam como se estivessem rodando na mesma máquina, facilitando a integração entre eles.

B)Criar Pods diretamente (usando um manifesto de Pod puro) em produção é uma má prática porque você perde as garantias de resiliência e gerenciamento automático que o Kubernetes oferece.

O problema principal é que o Pod, sozinho, é descartável e não se auto-recupera:

3
Todo manifesto YAML de um objeto no Kubernetes precisa ter quatro campos obrigatórios na raiz:

apiVersion → define a versão da API do Kubernetes usada (ex: v1, apps/v1)
kind → especifica o tipo de objeto (ex: Pod, Deployment, Service)
metadata → contém informações de identificação, como nome, labels, etc.
spec → descreve o estado desejado do objeto (como ele deve funcionar)

5

Entrada: Requisição chega na porta do NodePort (ex: Node IP:30080)

O Service web-service-tf09 recebe a requisição e usa o campo selector para identificar quais Pods são elegíveis (comparando com as labels app: web-tf09).

Proxy (roteamento)

O componente responsável por encaminhar o tráfego para um dos Pods é o kube-proxy, que faz o balanceamento entre os Pods disponíveis.

Destino Final (Pod)

A requisição chega a um dos Pods (criados pelo Deployment) na porta 80, onde o container Nginx responde.