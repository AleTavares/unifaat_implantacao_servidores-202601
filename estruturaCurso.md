# Estrutura do Curso
## Carga Horária
- **Total:** 16 aulas
- **Modalidade:** Presencial com laboratórios práticos
- **Ambiente:** WSL2 + Docker Desktop + AWS

## Módulos e Cronograma

| Módulo | Aulas | Tema Principal | Carga Horária |
|--------|-------|----------------|---------------|
| **I** | 1-2 | Fundamentos e Setup WSL/Docker | 7h |
| **II** | 3-4 | Build de Imagens e Persistência | 7h |
| **III** | 5-6 | Redes Docker e Revisão | 7h |
| **IV** | 7-8 | Avaliação I + Docker Compose | 7h |
| **V** | 9-10 | Orquestração (Swarm/K8s) | 7h |
| **VI** | 11-12 | AWS Fundamentals + Storage | 7h |
| **VII** | 13-15 | CI/CD + ECR + Deploy + Revisão | 10,5h |
| **VIII** | 16 | Avaliação Final Prática | 3,5h |

## Detalhamento por Aula
### Módulo I: Fundamentos e Setup
#### Aula 1: Fundamentos, Contêineres e Setup do Ambiente WSL/Linux
- **Foco:** Instalação WSL2 e comandos Linux essenciais
- **Conteúdo:** 
  - Conceitos de virtualização e containerização
  - Instalação e configuração do WSL2
  - Comandos Linux fundamentais (navegação, manipulação de arquivos)
  - Permissões e administração básica

#### Aula 2: Arquitetura do Docker e Docker Desktop no WSL
- **Foco:** Configuração do Docker Desktop e comandos básicos
- **Conteúdo:**
  - Arquitetura Docker (Client-Daemon-Registry)
  - Instalação Docker Desktop + integração WSL2
  - Comandos básicos: run, ps, images, pull
  - Ciclo de vida de contêineres

### Módulo II: Construindo e Persistindo
#### Aula 3: Construção de Imagens com Dockerfile
- **Foco:** Otimização de imagens e Multi-stage builds
- **Conteúdo:**
  - Sintaxe e instruções do Dockerfile
  - Técnicas de otimização (layer caching, .dockerignore)
  - Multi-stage builds para redução de tamanho
  - Análise de camadas com docker history

#### Aula 4: Volumes e Persistência de Dados
- **Foco:** Tipos de volumes e bind mounts no WSL
- **Conteúdo:**
  - Named volumes vs Bind mounts vs tmpfs
  - Persistência de dados de banco
  - Gerenciamento de volumes
  - Integração com sistema de arquivos WSL

### Módulo III: Redes e Comunicação
#### Aula 5: Redes no Docker
- **Foco:** Network drivers e comunicação entre contêineres
- **Conteúdo:**
  - Tipos de rede: bridge, host, overlay, macvlan
  - DNS interno e service discovery
  - Mapeamento de portas
  - Redes customizadas

#### Aula 6: Docker Compose e Ambientes Multi-Contêiner
- **Foco:** Orquestração local e YAML
- **Conteúdo:**
  - Sintaxe docker-compose.yml
  - Services, networks, volumes
  - Variáveis de ambiente
  - Profiles e overrides

#### Aula 7: Revisão Geral e Resolução de Dúvidas
- **Foco:** Consolidação dos Módulos I, II e III
- **Conteúdo:**
  - Exercícios práticos integrados
  - Troubleshooting comum
  - Preparação para avaliação

### Módulo IV: Avaliação e Orquestração Local
#### Aula 7.1: PROVA TEÓRICA E PRÁTICA (Módulos I-III)
- **Foco:** Avaliação dos fundamentos do Docker
- **Formato:** 50% teórica + 50% prática com evidências


### Módulo V: Orquestração Avançada
#### Aula 8: Introdução à Orquestração (Docker Swarm)
- **Foco:** Swarm initialization e services
- **Conteúdo:**
  - Conceitos de cluster e orquestração
  - Inicialização do Swarm
  - Services, tasks e replicas
  - Load balancing automático

#### Aula 9: Fundamentos de Kubernetes (K8s) e Conceitos
- **Foco:** Pods, Deployments e Services (Minikube/K3s)
- **Conteúdo:**
  - Arquitetura Kubernetes
  - Pods, Deployments, Services
  - Kubectl básico
  - Comparação Swarm vs K8s

### Módulo VI: Cloud Computing com AWS
#### Aula 10: Conceitos de Infraestrutura em Nuvem e AWS
- **Foco:** Visão geral da AWS, EC2, VPC, IAM
- **Conteúdo:**
  - Modelos de cloud (IaaS, PaaS, SaaS)
  - Serviços AWS fundamentais
  - EC2: instâncias, security groups
  - IAM: users, roles, policies

#### Aula 11: Armazenamento e Banco de Dados na AWS
- **Foco:** S3, EBS, RDS e conexão via WSL
- **Conteúdo:**
  - S3: buckets, objetos, políticas
  - EBS: volumes, snapshots
  - RDS: instâncias gerenciadas
  - Conexão SSH via terminal WSL

### Módulo VII: CI/CD e Deploy
#### Aula 12: CI/CD Básico e Registro de Imagens (ECR)
- **Foco:** Pipeline simples e AWS ECR via WSL
- **Conteúdo:**
  - Conceitos de CI/CD
  - AWS ECR: repositórios, autenticação
  - AWS CLI no WSL
  - Pipeline básico de build e push

#### Aula 13: Deploy de Containers na AWS (ECS/EKS)
- **Foco:** Orquestração em produção com ECS e introdução ao EKS
- **Conteúdo:**
  - AWS ECS: clusters, tasks, services
  - Deploy de imagens do ECR no ECS
  - Introdução ao EKS (Elastic Kubernetes Service)
  - Comparação ECS vs EKS

#### Aula 14: Monitoramento e Logs em Containers AWS
- **Foco:** CloudWatch, X-Ray e observabilidade de containers
- **Conteúdo:**
  - AWS CloudWatch: métricas e logs
  - Container Insights para ECS/EKS
  - AWS X-Ray para tracing distribuído
  - Alertas e dashboards

#### Aula 15: Revisão Geral e Resolução de Dúvidas
- **Foco:** Consolidação dos Módulos IV-VII
- **Conteúdo:**
  - Integração completa Docker + AWS
  - Troubleshooting avançado
  - Preparação para prova final

### Módulo VIII: Avaliação Final
#### Aula 16: PROVA FINAL PRÁTICA: Deploy Completo na AWS
- **Foco:** Deploy de aplicação multi-contêiner em EC2/ECS
- **Formato:** Prática integrada com evidências obrigatórias
