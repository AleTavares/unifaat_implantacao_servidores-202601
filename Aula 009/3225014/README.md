# Respostas #

___Como subir o ambiente criado no exercício:___

-> Inicie o minikube: minikube start
-> Aplique o deployment: kubectl apply -f deployment.yaml
-> Aplique o service: kubectl apply -f service.yaml
-> Verifique os recursos criados: kubectl get deployments
kubectl get pods
kubectl get services

-> Após isso, para remover:
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml

-> Pare o minikube:
minikube stop


## Questão 01 ##
A) Explique a função do Control Plane e cite o nome de um componente chave que reside nele (ex: etcd).
R: A função de um control pane é agir como um cérebro para o sistema, mantendo o estado global, tomando decisões de alocação e respondendo os eventos do sistema.

B) Qual é o principal software que reside nos Worker Nodes e é responsável por garantir que o Pod desejado esteja rodando e saudável (mantendo o "estado desejado")?
R: Kubelet.

## Questão 02 ##
A) Explique por que um Pod pode conter múltiplos contêineres e qual é a principal regra que esses contêineres compartilham (ex: rede, storage).
R: Os PODS podem conter múltiplos conteineres para dividir a responsabilidade entre eles, mesmo atuando como uma única unidade.
A regra que eles compartilham são:
- Mesma rede, mesmo IP, mesmo Namespace de rede.
- Mesmo storage, ou seja, mesmo armazenamento.

B) Por que é uma prática inadequada criar Pods diretamente (via manifesto Pod puro) em um ambiente de produção?
É prática inadequada, pois em um ambiente de produção, espera-se que os conteineres se renovem automaticamente, mantendo assim o número desejado de réplicas e a automatização desejada.

## Questão 03 ##

Todo objeto Kubernetes é definido por um manifesto YAML. Quais são os quatro campos obrigatórios que devem estar presentes na raiz de qualquer manifesto YAML de objeto K8s?
- ApiVersion
- Kind
- Metadata
- Spec

## Questão 04 - pratica ##
 - Prática: Arquivo referente a essa questão está nomeado como "deployment.yaml"

## Questão 05 - pratica ##
 - Prática: Arquivo referente a essa questão está nomeado como "service.yaml"

## Tarefa Prática Integrada (Obrigatória - Conceitual) ##

    Na tarefa prática anterior o fluxo funciona da seguinte forma, até onde entendi:

     -> O arquivo 'deployment.yaml' serve para ditar o número de réplicas a serem mantidas pelo cérebro do sistema, também informamos neste arquivos informações como o tipo de imagem a ser utilizada e sua versão desejada.
     -> O arquivo 'service.yaml' serve para filtrar estes conteineres (réplicas citadas anteriormente) e expô-los a conexões exteriores, utilizando de labels (rótulos) para localizar os conteineres para tal.

    1.Entrada: Requisição chega na porta do NodePort (ex: Node IP:30000).
        R: Neste caso, a requisição chega através da porta 30080.

    2.Service: O Service web-service-tf09 intercepta a requisição e usa qual campo para saber quais Pods são elegíveis?
        R: O Service define os Pods corretos com base nas 'labels' definidos no arquivo 'deployments.yaml'.

    3.Proxy: Qual objeto (ou componente) dentro do K8s é responsável por rotear o tráfego do Service para um dos Pods ativos?
        R: As portas 'port' e 'targetport'.

    4.Destino Final: A requisição chega a um dos Pods (gerenciados pelo Deployment) na porta 80.
        R: Aqui é onde a requisição atinge seu destino, caso um dos Pods esteja sobrecarregado ou tenha caído, a requisição será direcionada a outro Pod. E imediatamente outr Pod será levantado para substituir o que caiu.




