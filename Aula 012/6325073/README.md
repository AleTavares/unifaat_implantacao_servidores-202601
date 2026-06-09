
O objetivo principal da fase de CD é disponibilizar o artefato gerado pela CI para implantação em ambientes de teste, homologação ou produção. Dependendo da abordagem: o artefato fica pronto para ser implantado, mas a publicação em produção geralmente requer uma aprovação manual (Continuous Delivery). Ou a implantação em produção ocorre automaticamente após a aprovação dos testes e validações (Continuous Deployment).

## Questão 2:

Jenkins, GitHub Actions, AWS CodeBuild

## Questão 3:

## A:

A principal vantagem do Amazon ECR é o controle de acesso e isolamento dentro da AWS, o que aumenta significativamente a segurança para aplicações privadas. o ECR reduz o risco de exposição de imagens e credenciais, sendo mais adequado para ambientes corporativos e aplicações sensíveis do que repositórios públicos como o Docker Hub.

## B:

O ECR é um serviço regional, ou seja, cada repositório existe dentro de uma região específica da AWS.

## Questão 4:

A sequência correta é: Passo de autenticação, Passo de Tagging e Passo de Upload (push)