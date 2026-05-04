# Respostas

1.
O Docker Swarm permite a orquestração de containers em um cluster distribuído, utilizando nós do tipo manager e worker para dividir tarefas e garantir escalabilidade e alta disponibilidade. Já o Docker Compose é voltado para a definição e execução de múltiplos containers em um único host, sendo mais utilizado em ambientes de desenvolvimento.

2.
Em um cluster Docker Swarm, os nós do tipo Manager são responsáveis por gerenciar o cluster, distribuindo tarefas, mantendo o estado desejado e monitorando os serviços. Já os nós Worker executam as tarefas atribuídas, rodando os containers e reportando seu status aos managers.

3.
A) docker swarm init
B) O driver de rede padrão é o overlay, que permite a comunicação entre serviços distribuídos em diferentes nós do cluster.

4.
A) docker service create --name web-escalavel --replicas 3 nginx:alpine
B) docker service ps web-escalavel

5.
A) docker service scale web-escalavel=5
B) Essa capacidade é chamada de alta disponibilidade, pois o Swarm garante que os serviços continuem rodando mesmo em caso de falhas de nós.

# Tarefa Prática

Inicialização do Cluster

Primeiramente, utilizei o comando abaixo para garantir que não havia nenhum cluster ativo:

docker swarm leave --force

Em seguida, inicializei um novo cluster com o comando:

docker swarm init

Isso fez com que a máquina se tornasse um nó manager dentro do Docker Swarm.

2. Criação do Serviço

Para criar o serviço, utilizei o seguinte comando:

docker service create \
--name app-stack-tf9 \
--publish 8001:80 \
--replicas 4 \
nginx:alpine

Saída obtida:

overall progress: 4 out of 4 tasks
1/4: running
2/4: running
3/4: running
4/4: running
verify: Service converged

Essa saída indica que as 4 réplicas foram criadas com sucesso e o estado desejado foi atingido.

3. Verificação do Serviço (Evidência 1)

Para verificar o status das réplicas, utilizei:

docker service ps app-stack-tf9

Resultado:

(app-stack-tf9.1 ... Running)
(app-stack-tf9.2 ... Running)
(app-stack-tf9.3 ... Running)
(app-stack-tf9.4 ... Running)

Isso confirma que todas as 4 instâncias do serviço estão em execução.

4. Acesso Externo (Evidência 2)

Para testar o acesso ao serviço, utilizei:

curl localhost:8001

Saída:

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
<h1>Welcome to nginx!</h1>
...
</html>

Essa resposta confirma que o servidor web Nginx está funcionando corretamente e acessível pela porta 8001.

5. Escalabilidade

Para reduzir o número de réplicas do serviço, utilizei:

docker service scale app-stack-tf9=1

Com isso, o serviço passou a ter apenas 1 instância ativa.

6. Limpeza Final

Para remover o serviço e encerrar o cluster, utilizei:

docker service rm app-stack-tf9
docker swarm leave --force

Esses comandos removeram o serviço criado e finalizaram o uso do cluster.

