### Questão 1: Arquitetura e Componentes  
a) Função do Control Plane 

O Control Plane é o “cérebro” do cluster Kubernetes. Ele é responsável por:
-Gerenciar o estado do cluster  
-Tomar decisões (ex: onde rodar Pods)  
-Monitorar e garantir que o estado atual = estado desejado 
    Componente chave:  
etcd → banco de dados distribuído que armazena o estado do cluster  

    b) Software nos Worker Nodes  

O principal software é o: Kubelet   
    Função:
-Executa nos Worker Nodes  
-Garante que os Pods estejam rodando corretamente  
-Segue o estado definido no Control Plane  
---------------------------------
### Questão 2: O Pod (Conceito Fundamental) 
a)  Um Pod pode ter vários contêineres quando eles precisam trabalhar juntos (ex: app + sidecar).  

    Regra principal:  

-Compartilham:  
-Rede (mesmo IP e porta localhost)  
-Armazenamento (volumes)  
Ou seja: funcionam como se estivessem no mesmo “ambiente”.  

b) Porque Pods são:  
-Efêmeros (descartáveis)  
-Não se recuperam sozinhos    
    Problemas:  
-Se cair, não sobe sozinho  
-Não escala automaticamente  

 Em produção usamos:  
-Deployment  
-ReplicaSet  
    Esses garantem:  
-Alta disponibilidade  
-Auto-recuperação  
-Escalabilidade  

### Questão 3: Manifesto YAML

Os 4 campos obrigatórios na raiz são:  
-apiVersion:  
-kind:  
-metadata:  
-spec:  
    Explicação rápida:  
 apiVersion → versão da API do Kubernetes  
 kind → tipo do objeto (Pod, Deployment, Service…)  
 metadata → informações (nome, labels…)  
 spec → configuração desejada do objeto  

 --------------------------
 ### Descrição do Fluxo:  
 Fluxo de comunicação no Kubernetes  
Entrada (NodePort)  
A requisição do usuário chega ao cluster através do endereço do Node:  
NodeIP:30000 (porta NodePort exposta externamente).  
Serviço  
O Kubernetes Service web-service-tf09 intercepta a requisição.  

Ele utiliza o campo:  

selector  

Para identificar os Pods elegíveis com o rótulo:  
app: web-tf09   
Proxy (Roteamento)  
O componente responsável por encaminhar o tráfego é o:  
kube-proxy  

Ele realiza:  

Balanceamento de carga  
Escolha de um dos Pods ativos  
Encaminhamento da requisição  
Destino Final (Pod)  
A requisição chega a um dos Pods gerenciados pelo:  
Kubernetes Deployment  

O container Nginx responde na porta:  
80  