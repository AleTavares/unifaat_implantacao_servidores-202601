1. Um ambiente Docker rodando em **Docker Compose** é limitado a somente os containeres definidos dentro do arquivo "**docker-compose.yml**", não sendo possível aplicar **auto scaling** de forma automatica, sendo necessário ser manual.
O **Docker Swarm** permite a criação e definição de mais de um node/workers que trabalharam juntos para a determinada tarefa. Em caso de um ou mais **nodes/workes** cairem, o **Docker Swarm** de forma automatica excluirá o container e iniciará um novo com os processos do antigo, sendo possível também através do terminal definir mais ou menos nodes/works para a tarefa.

2. O **Manager** é o cabeça, ele quem recebe as requisições e redireciona aos **Works**, os quais são os responsáveis pela execução das tarefas solicitadas. Além de redirecionar, o Manager é o responsável pela vida dos **works**, coletando os dados do node que caiu e atribuindo as informações do node antigo ao novo node, seguindo a tarefa da forma correta.

3. 
    a. docker swarm init
    ![print do comando docker swarm init](image.png)
    b. Driver Overlay

4. 
    a. docker service create --name web-escalavel --replicas 3 -p 3000:80 nginx:alpine
        ![print do comando docker service create](image-1.png)
    b. docker service ps web-escalavel
        ![print do comando docker service ps](image-2.png)

5. 
    a. docker service scale web-escalavel=5
        ![print do comando docker service scale](image-3.png)
    Teórica. Alta Disponibilidade / Self-Healing

## Tarefa Prática Integrada (Obrigatória)
1. 
    1. docker service rm web-escalavel
    ![print do comando docker service rm](image-5.png)
    
    2. docker service create --name web-escalavel --replicas 1 -p 3000:80 nginx:alpine
    ![print do comando docker service create](image-6.png)

2. docker service create --name app-stack-tf9 --replicas 4 -p 8001:80 nginx:alpine
    ![print do comando docker service create](image-7.png)

3. 
    1. docker service ps app-stack-tf9
    ![print do comando docker service ps](image-8.png)
    
    2. curl localhost:8001
    ![print do comando curl](image-9.png)

4. docker service scale app-stack-tf9=1
    ![print do comando docker service scale](image-10.png)

5. 
    1. docker service rm app-stack-tf9
    ![print do comando docker service rm](image-11.png)

    2. docker swarm leave --force
    ![print do comando docker swarm leave](image-12.png)