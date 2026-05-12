
aws ec2 describe-vpcs

### Questão 1: Modelos de Serviço em Nuvem (Teórica)
a) O AWS EC2 representa o modelo **IaaS (Infrastructure as a Service)**. A principal responsabilidade do usuário neste modelo é gerenciar o Sistema Operacional, aplicações, dados e middleware, enquanto a AWS fornece a infraestrutura física (servidores, armazenamento e rede). 

b) Um exemplo de serviço SaaS é o **AWS WorkDocs** (Software as a Service), onde o usuário apenas usa o software sem gerenciar infraestrutura. Um exemplo de PaaS é o **AWS Elastic Beanstalk** (Platform as a Service), onde o usuário desenvolve e implanta aplicações sem gerenciar servidores ou SO, c

### Questão 2: Identidade e Acesso (IAM) (Teórica)
a) A diferença fundamental é que um **Usuário IAM** é uma entidade individual com credenciais próprias (como Access Key e Secret Key) para acessar a AWS, enquanto um **Grupo IAM** é uma coleção de usuários que compartilham permissões comuns, facilitando o gerenciamento de acessos. No Lab010.md, isso é aplicado ao configurar credenciais IAM para autenticação via AWS CLI.

b) É uma melhor prática criar uma **Role IAM** porque roles fornecem permissões temporárias e não exigem chaves de acesso permanentes, reduzindo riscos de exposição (como vazamento de credenciais root). Instâncias EC2 assumem roles automaticamente, evitando o uso direto de chaves sensíveis. 

### Questão 3: Rede Virtual na AWS (VPC) (Teórica)
a) Uma **Subnet** é uma subdivisão de uma VPC que agrupa recursos em uma faixa de endereços IP. A diferença crucial é que uma **Subnet Pública** permite acesso direto à Internet (através de um Internet Gateway), ideal para recursos como servidores web, enquanto uma **Subnet Privada** não tem acesso direto à Internet, sendo usada para bancos de dados ou aplicações internas, isolando tráfego sensível.

b) O componente obrigatório é o **Internet Gateway** para que uma instância EC2 em Subnet Pública se conecte à Internet (enviando/recebendo tráfego). Para inspecionar tráfego em nível de Subnet, usa-se o **Network ACL (NACL)**, que controla regras de entrada/saída por subnet, complementando Security Groups (por instância)

### Questão 4: Instâncias EC2 (Prática Teórica)
a) O termo é **AMI (Amazon Machine Image)**, que é uma imagem pré-configurada do Sistema Operacional (como Ubuntu ou Amazon Linux) usada para lançar instâncias EC2.

b) O comando é: `ssh -i minha_chave.pem ec2-user@54.123.45.67`. 

### Questão 5: Comandos AWS CLI (Prática)

1. **Configurar credenciais:** `aws configure`

2. **Listar instâncias EC2:** `aws ec2 describe-instances` 

3. **Criar um bucket S3:** `aws s3 mb s3://meu-bucket-tf10 --region sa-east-1` 

4. **Descrever VPCs:** `aws ec2 describe-vpcs` 

### Questão 6: Evidências Práticas de Configuração e Criação de Recursos
1.![alt text](<Captura de tela 2026-05-11 202949.png>)

2![alt text](<Captura de tela 2026-05-11 214801.png>)

3![alt text](<Captura de tela 2026-05-11 215142.png>)
3![alt text](<Captura de tela 2026-05-11 215451.png>)

4![alt text](<Captura de tela 2026-05-11 215735.png>)

## PARTE 2
1![alt text](<Captura de tela 2026-05-11 220030.png>)
1![alt text](<Captura de tela 2026-05-11 220430.png>)