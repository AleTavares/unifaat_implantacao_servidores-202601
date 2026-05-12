## Questão 1: Arquitetura e Componentes (Teórica)
a) ETCD é o responsavel por fazer todo o gerenciamento de nós do Workers, ele gerencia e observa tudo aquilo que esta sendo executado dentro de seus workers, fazendo assim com que se algum falhe ele assuma derrubando o worker e subindo um novo.

b) O principal responsavel é o Kubelet garantindo que os Pods estejam de pé e rodando.

## Questão 2: O Pod (Conceito Fundamental) (Teórica)
a) Pode ter para que em algum momento ele possa trabalhar juntos de forma acoplada, como se fossem um unico serviço um deles pode ser principal e outro secundario.

b) Pois eles nao tem nenhuma defesa de auto recuperaçao, se ele por algum momento esse nó, falhar ele não vai ser recriado como deveria.

## Questão 3: Manifesto YAML (Prática Teórica)
ApiVersion, kind, metadata, spec.
ApiVersion = Versao,
kind = tipo do objeto,
metadata = informcoes do objeto como descricao / idenitificacao do objeto.
spec = estado desejado do objeto 

## Tarefa Prática Integrada (Obrigatória - Conceitual)
Entrada da conexao: 172.20.0.4:30082
A porta é sempre aleatória!

A service: selector web-tf09 faz a mostragem de todos os Pods.

Proxy é responsavel por fazer o balanceamento e distribuiçao de carga. 

Saida será nginx-deploy-tf09 na porta 80 do "navegador" ou local onde estiver fazendo o acesso. 

