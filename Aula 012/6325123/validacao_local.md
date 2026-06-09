# Validacao local

## Sintaxe do script

Comando:

```bash
bash -n Aula\ 012/6325123/comandos_lab012.sh
```

Resultado: sem erros de sintaxe.

## Tentativa de build Docker

Comando:

```bash
docker build -t web-app-v1:V1.0 .
```

Resultado obtido no ambiente atual:

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

Observacao: o Docker daemon nao estava acessivel para este usuario/ambiente. O Dockerfile e os comandos foram deixados prontos para execucao em um terminal com acesso ao Docker.
