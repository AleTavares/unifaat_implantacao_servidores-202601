# Implementação de Servidor e Nuvem (Cloud) - 2026.1

**Instituição:** UniFAAT - Centro Universitário  
**Curso:** Análise e Desenvolvimento de Sistemas (ADS)  
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Semestre:** 2026.1  
**Professor:** Alexandre Tavares  

## Sobre este Repositório

Este repositório contém todo o material didático, laboratórios práticos e tarefas da disciplina de **Implementação de Servidor e Nuvem**. Aqui você encontra desde os fundamentos de containers até deploy completo em produção na AWS.

O objetivo é proporcionar uma experiência prática e progressiva: cada aula constrói sobre a anterior, formando um caminho completo do desenvolvimento local ao deploy em nuvem.


## Por que este repositório é importante?

- **Material centralizado:** Labs, tarefas e referências em um só lugar
- **Histórico de aprendizado:** Acompanhe sua evolução ao longo do semestre
- **Prática com Git:** O fluxo de entrega (fork + PR) simula o dia a dia profissional
- **Portfólio:** Suas entregas ficam registradas no GitHub como evidência de competência

## Ambiente de Trabalho

| Ferramenta | Função |
|------------|--------|
| **WSL2 (Ubuntu)** | Ambiente Linux no Windows para execução de comandos |
| **Docker Desktop** | Construção e execução de containers |
| **AWS CLI** | Interação com serviços AWS via terminal |
| **kubectl** | Gerenciamento de clusters Kubernetes |
| **Git + GitHub** | Versionamento e entrega de tarefas |

## Estrutura do Repositório

```
├── Aula 001/          # Fundamentos, Contêineres e Setup WSL/Linux
├── Aula 002/          # Arquitetura Docker e Docker Desktop no WSL
├── Aula 003/          # Construção de Imagens com Dockerfile
├── Aula 004/          # Volumes e Persistência de Dados
├── Aula 005/          # Redes no Docker
├── Aula 006/          # Docker Compose e Ambientes Multi-Contêiner
├── Aula 008/          # Introdução à Orquestração (Docker Swarm)
├── Aula 009/          # Fundamentos de Kubernetes (K8s)
├── Aula 010/          # Conceitos de Infraestrutura em Nuvem e AWS
├── Aula 011/          # Armazenamento e Banco de Dados na AWS
├── Aula 012/          # CI/CD Básico e Registro de Imagens (ECR)
├── Aula 013/          # Deploy de Containers na AWS com EKS
├── estruturaCurso.md  # Cronograma completo com módulos e aulas
├── conceitosAbordados.md  # Glossário de conceitos técnicos
├── ferramentasTecnologias.md  # Ferramentas utilizadas no curso
├── linksUteis.md      # Links de referência e documentação
└── troubleshooting.md # Soluções para problemas comuns
```

## Módulos do Curso

| Módulo | Aulas | Tema Principal | Carga Horária |
|--------|-------|----------------|---------------|
| **I** | 1-2 | Fundamentos e Setup WSL/Docker | 7h |
| **II** | 3-4 | Build de Imagens e Persistência | 7h |
| **III** | 5-6 | Redes Docker e Docker Compose | 7h |
| **IV** | 7-8 | Avaliação I + Orquestração (Swarm) | 7h |
| **V** | 9-10 | Kubernetes + Intro Cloud AWS | 7h |
| **VI** | 11-12 | AWS Storage + CI/CD com ECR | 7h |
| **VII** | 13-15 | Deploy EKS + Monitoramento + Revisão | 10,5h |
| **VIII** | 16 | Avaliação Final Prática | 3,5h |

## Estrutura de cada Aula

Cada pasta `Aula XXX/` contém:

| Arquivo | Descrição |
|---------|-----------|
| `LabXXX.md` | Laboratório prático passo a passo |
| `TAXXX.md` | Tarefa de Aula (exercícios em sala) |
| `TFXXX.md` | Tarefa Final (entrega avaliativa) |
| `README.md` | Resumo e objetivos da aula (quando disponível) |

## Fluxo de Entrega de Tarefas

1. Faça um **fork** deste repositório
2. Clone o fork para sua máquina local
3. Crie uma pasta com seu **RA** dentro da aula correspondente
4. Adicione suas respostas e evidências em um `README.md`
5. Faça **commit** e **push** para seu fork
6. Abra um **Pull Request** com o título: `RA - Nome do Aluno`

### Atualizando o Fork

```bash
git remote add upstream https://github.com/professor-ale/unifaat_implantacao_servidores-202601.git
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

## Requisitos do Ambiente

- Windows 10/11 com WSL2 habilitado
- Ubuntu (via Microsoft Store)
- Docker Desktop com integração WSL2
- Conta AWS Academy ou AWS Free Tier
- Git instalado no WSL
- Editor de código (VS Code recomendado)

## Links Úteis

- [Documentação Docker](https://docs.docker.com/)
- [Documentação Kubernetes](https://kubernetes.io/docs/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/)

## Licença

Este material é de uso educacional para a disciplina de Implementação de Servidor e Nuvem do curso de ADS da UniFAAT - Semestre 2026.1.
