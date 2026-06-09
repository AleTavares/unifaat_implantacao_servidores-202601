# Resumo da Aula 008 - Introducao a Orquestracao com Docker Swarm

## Ideia central da aula

Nesta aula, o foco deixa de ser apenas "subir um container" e passa a ser **gerenciar uma aplicacao com varias instancias**, de forma mais organizada e automatica.

Se um unico container nao for suficiente, precisamos de uma forma de:

- aumentar a capacidade da aplicacao;
- distribuir acessos entre varias instancias;
- recuperar servicos que falharem;
- manter um ambiente consistente sem fazer tudo manualmente.

E exatamente para isso que entra o **Docker Swarm**.

---

## 1. O que e orquestracao

**Orquestracao** e o processo de coordenar varios containers automaticamente.

Em vez de criar, reiniciar, escalar e organizar tudo manualmente, uma ferramenta de orquestracao faz esse trabalho por voce.

### Em linguagem simples

- Um container sozinho resolve um problema pequeno.
- Muitos containers, em um ambiente maior, precisam de coordenacao.
- Essa coordenacao automatica e a orquestracao.

---

## 2. O que e Docker Swarm

**Docker Swarm** e a ferramenta nativa do Docker para orquestrar containers em **cluster**.

Ele permite transformar varias maquinas Docker em um unico ambiente logico de execucao.

### Ideia pratica

- Docker executa containers.
- Docker Swarm gerencia varios containers de forma organizada.

---

## 3. O que e um cluster

**Cluster** e um conjunto de maquinas trabalhando juntas como se fossem um unico ambiente.

Mesmo que no laboratorio seja usado apenas um unico host, o conceito do Swarm foi pensado para multiplos nos.

### Para guardar

- Uma maquina isolada roda containers.
- Varias maquinas coordenadas formam um cluster.
- O Swarm gerencia esse cluster.

---

## 4. Manager e Worker

Dentro de um cluster Swarm, os nos podem ter papeis diferentes.

### Manager

O **Manager** e o no que controla o cluster.

Responsabilidades principais:

- manter o estado do cluster;
- decidir onde os servicos vao rodar;
- gerenciar escalabilidade e recuperacao;
- expor a API de controle do Swarm.

### Worker

O **Worker** e o no que executa o trabalho.

Responsabilidades principais:

- receber tarefas do manager;
- executar containers;
- reportar status de execucao.

### Regra de memorizacao

- Manager decide.
- Worker executa.

---

## 5. O que e um Service

No Swarm, o objeto principal nao e mais o container individual. O mais importante passa a ser o **Service**.

Um **Service** e a definicao de como a aplicacao deve rodar no cluster.

Exemplo de ideia:

"Quero um Nginx com 3 replicas e porta publicada para acesso externo."

Isso e um service.

### Diferenca importante

- **Container**: execucao individual.
- **Service**: declaracao de como a aplicacao deve existir.

---

## 6. Replica

**Replica** e cada copia desejada de um service.

Se um service foi definido com 3 replicas, o Swarm tentara manter 3 instancias ativas.

### Por que isso importa

- aumenta a capacidade de atendimento;
- melhora a disponibilidade;
- reduz impacto de falhas individuais.

---

## 7. Task e Container

O Swarm trabalha com uma hierarquia simples:

**Service -> Task -> Container**

### Como entender isso

- O **Service** diz o que voce quer.
- A **Task** e a unidade de trabalho criada para cumprir esse desejo.
- O **Container** e a execucao real dessa tarefa.

### Exemplo

Se voce cria um service com 3 replicas:

- o Swarm cria 3 tasks;
- cada task vira um container em execucao.

---

## 8. Escalabilidade horizontal

**Escalar horizontalmente** significa aumentar o numero de instancias da aplicacao.

Exemplo:

- antes: 1 replica;
- depois: 3 replicas;
- depois: 5 replicas.

Voce nao deixa um container mais forte. Voce cria mais copias dele para dividir o trabalho.

---

## 9. Load balancing

**Load balancing** significa distribuir as requisicoes entre varias replicas disponiveis.

Quando um service tem varias replicas, o Swarm pode encaminhar o trafego entre elas automaticamente.

### Resultado pratico

- a aplicacao atende mais usuarios;
- nenhuma unica instancia fica tao sobrecarregada;
- o acesso se torna mais equilibrado.

---

## 10. Alta disponibilidade

**Alta disponibilidade** significa manter a aplicacao acessivel mesmo quando algo falha.

Se existe apenas uma instancia e ela cai, o servico para.

Se existem varias replicas, outras podem continuar respondendo.

Em clusters reais com varios nos, isso fica ainda melhor, porque os servicos podem ser redistribuidos entre maquinas saudaveis.

---

## 11. Auto-healing ou autorrecuperacao

**Auto-healing** e a capacidade do Swarm de recriar automaticamente o que esta faltando.

Se voce definiu 5 replicas e uma falha, o Swarm percebe que o estado atual ficou diferente do estado desejado e tenta restaurar a quantidade correta.

### Exemplo

- desejado: 5 replicas;
- atual apos falha: 4 replicas;
- acao do Swarm: criar mais 1 replica.

---

## 12. Estado desejado

O Swarm trabalha com o conceito de **estado desejado**.

Isso significa que voce informa como o ambiente deve ficar, e o Swarm tenta manter essa definicao.

O estado desejado pode incluir:

- nome do service;
- imagem usada;
- quantidade de replicas;
- portas publicadas.

Essa ideia e chamada de abordagem **declarativa**.

---

## 13. Rede Overlay

A rede **overlay** permite a comunicacao entre servicos distribuidos em diferentes nos do cluster.

### Guarde assim

- bridge: comum em Docker local;
- overlay: pensada para ambiente em cluster.

---

## 14. Rede Ingress

A rede **ingress** esta ligada ao recebimento de trafego externo quando uma porta do service e publicada.

Ela ajuda o Swarm a encaminhar acessos para replicas saudaveis do servico.

### Forma simples de lembrar

- overlay: comunica internamente no cluster;
- ingress: ajuda na entrada do trafego publicado.

---

## 15. Rolling update

**Rolling update** e a atualizacao gradual de um servico, sem precisar derrubar tudo de uma vez.

Em vez de parar todas as replicas ao mesmo tempo, o Swarm atualiza aos poucos.

### Vantagem

- reduz indisponibilidade;
- torna a atualizacao mais segura.

---

## 16. Rollback

**Rollback** e o retorno para a versao anterior quando uma atualizacao apresenta problema.

### Resumo

- update: avanca para nova versao;
- rollback: volta para a versao anterior.

---

## 17. Docker Stack

**Docker Stack** e a forma de aplicar uma definicao parecida com Compose em ambiente Swarm.

### Comparacao simples

- Docker Compose: ambiente multi-container em host unico;
- Docker Stack: ambiente multi-container em cluster Swarm.

---

## 18. Secrets e Configs

### Secrets

Servem para armazenar dados sensiveis, como:

- senhas;
- tokens;
- chaves.

### Configs

Servem para fornecer configuracoes aos servicos de forma gerenciada.

### Diferenca basica

- secret: informacao sensivel;
- config: configuracao nao necessariamente sensivel.

---

## 19. Placement constraints

**Placement constraints** sao regras que definem onde um service pode rodar.

Exemplos:

- apenas em manager;
- apenas em worker;
- apenas em nos com determinada label.

Isso ajuda a organizar melhor cargas especificas no cluster.

---

## 20. Diferenca entre Docker Compose e Docker Swarm

### Docker Compose

- organiza varios containers;
- normalmente em uma unica maquina;
- muito usado para desenvolvimento e laboratorio.

### Docker Swarm

- orquestra servicos em cluster;
- permite escala, balanceamento e autorrecuperacao;
- se aproxima mais de cenarios de producao.

### Frase-resumo

Compose monta o ambiente.
Swarm administra o ambiente em escala.

---

## 21. Comandos mais importantes da aula

### Inicializar o cluster

```bash
docker swarm init
```

### Ver os nos do cluster

```bash
docker node ls
```

### Criar um service com replicas

```bash
docker service create --name web-escalavel --replicas 3 -p 8005:80 nginx:alpine
```

### Ver o estado das replicas

```bash
docker service ps web-escalavel
```

### Escalar o service

```bash
docker service scale web-escalavel=5
```

### Remover o service

```bash
docker service rm web-escalavel
```

### Sair do swarm

```bash
docker swarm leave --force
```

---

## 22. O que o laboratorio quer provar

O laboratorio da aula quer mostrar, na pratica, que voce sabe:

1. inicializar um cluster Swarm;
2. criar um service;
3. trabalhar com replicas;
4. testar acesso externo;
5. aumentar ou reduzir escala;
6. observar o load balancing;
7. comprovar a autorrecuperacao;
8. limpar o ambiente ao final.

---

## 23. Resumo final para memorizar

Se voce quiser guardar apenas o essencial da Aula 008, memorize isto:

1. Docker Swarm e a ferramenta de orquestracao nativa do Docker.
2. Cluster e um conjunto de maquinas trabalhando juntas.
3. Manager controla o cluster; Worker executa tarefas.
4. Service define como a aplicacao deve rodar.
5. Replicas sao copias do service para escala e disponibilidade.
6. O Swarm faz load balancing automaticamente.
7. O Swarm tenta manter o estado desejado.
8. Se uma replica falhar, o Swarm pode recria-la automaticamente.
9. Overlay e a rede para comunicacao no cluster.
10. Compose e local; Swarm e cluster.

---

## 24. Frase final de estudo

**Docker Swarm e a tecnologia que transforma varios containers em uma aplicacao organizada, escalavel e mais resistente a falhas.**