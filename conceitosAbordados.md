# Conceitos Técnicos Abordados

### 1. Containerização
**Docker Fundamentals**
- **Contêineres vs VMs:** Diferenças arquiteturais e de performance
- **Imagens Docker:** Camadas, registry, versionamento
- **Dockerfile:** Instruções, otimização, multi-stage builds
- **Docker Engine:** Daemon, CLI, API REST

**Gerenciamento de Recursos**
- **Volumes:** Named volumes, bind mounts, tmpfs mounts
- **Redes:** Bridge, host, overlay, macvlan drivers
- **Recursos:** CPU, memória, I/O limits

### 2. Orquestração
**Docker Compose**
- **Definição de serviços:** YAML syntax, dependencies
- **Networking:** Service discovery, custom networks
- **Scaling:** Horizontal scaling, load balancing
- **Environment management:** Variables, secrets, configs

**Docker Swarm**
- **Cluster management:** Managers, workers, consensus
- **Service deployment:** Rolling updates, rollbacks
- **Load balancing:** Internal load balancer, ingress network
- **High availability:** Leader election, fault tolerance

**Kubernetes (Introdução)**
- **Arquitetura:** Master/worker nodes, etcd, API server
- **Workloads:** Pods, Deployments, StatefulSets
- **Networking:** Services, Ingress, NetworkPolicies
- **Storage:** PersistentVolumes, StorageClasses

### 3. Cloud Computing (AWS)
**Compute Services**
- **EC2:** Instance types, AMIs, security groups
- **ECS:** Task definitions, services, clusters
- **Lambda:** Serverless computing, event-driven architecture

**Storage Services**
- **S3:** Object storage, buckets, lifecycle policies
- **EBS:** Block storage, volume types, snapshots
- **EFS:** Network file system, mount targets

**Database Services**
- **RDS:** Managed databases, Multi-AZ, read replicas
- **DynamoDB:** NoSQL, partition keys, global tables
- **ElastiCache:** In-memory caching, Redis, Memcached

**Networking & Security**
- **VPC:** Subnets, route tables, internet gateways
- **IAM:** Users, roles, policies, federation
- **Security Groups:** Stateful firewalls, ingress/egress rules

### 4. CI/CD e DevOps
**Continuous Integration**
- **Source control:** Git workflows, branching strategies
- **Build automation:** Docker build, image optimization
- **Testing:** Unit tests, integration tests, security scans

**Continuous Deployment**
- **Registry management:** ECR, image tagging, lifecycle
- **Deployment strategies:** Blue-green, rolling, canary
- **Infrastructure as Code:** CloudFormation, Terraform basics

**Monitoring & Logging**
- **Container monitoring:** Resource usage, health checks
- **Application monitoring:** Logs, metrics, tracing
- **AWS monitoring:** CloudWatch, CloudTrail, X-Ray

### 5. Ambiente de Desenvolvimento
**WSL Integration**
- **File system:** Windows/Linux interoperability
- **Networking:** Port forwarding, localhost access
- **Performance:** I/O optimization, resource allocation

**Development Workflow**
- **IDE integration:** VS Code, Docker extensions
- **Debugging:** Container debugging, remote development
- **Local testing:** Development environments, hot reload
