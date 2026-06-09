# Aula 003 - Construção de Imagens com Dockerfile

## 📋 Visão Geral
**Módulo:** II - Build de Imagens e Persistência  
**Duração:** 3h30min  
**Foco:** Otimização de imagens e Multi-stage builds

## 🎯 Objetivos da Aula
- Criar Dockerfiles funcionais e otimizados
- Aplicar técnicas de otimização de imagens
- Compreender o sistema de camadas do Docker
- Implementar multi-stage builds

## 📚 Conteúdo Programático
- Sintaxe e instruções do Dockerfile
- Técnicas de otimização (layer caching, .dockerignore)
- Multi-stage builds para redução de tamanho
- Análise de camadas com docker history

## 📁 Arquivos da Aula
- **[Lab003.md](Lab003.md)** - Laboratório prático
- **[TF003.md](TF003.md)** - Tarefa para casa
- **Arte_e_Arquitetura_Dockerfile.pdf** - Material teórico
- **Aula003.png** - Infográfico da aula

## 🔧 Pré-requisitos
- Docker Desktop funcionando no WSL
- Conhecimento básico de comandos Linux
- Aulas 1 e 2 concluídas

## ⚠️ Troubleshooting Comum

### Problemas de Build
- **Build falha:** Verifique sintaxe do Dockerfile e contexto de build
- **Cache não funciona:** Use `docker build --no-cache` para rebuild completo
- **Imagem muito grande:** Implemente multi-stage builds e limpeza de cache

### Problemas de Contexto
- **Arquivos não copiados:** Verifique .dockerignore e caminhos relativos
- **Build lento:** Otimize ordem das instruções (menos mutáveis primeiro)
- **Permissões:** Ajuste permissões com `chmod` antes do COPY

## 🔑 Comandos Principais
```bash
docker build -t nome:tag .
docker history nome:tag
docker images
docker run --rm nome:tag
```

## ✅ Checklist de Conclusão
- [ ] Dockerfile criado e funcional
- [ ] Técnicas de otimização aplicadas
- [ ] Análise de camadas realizada
- [ ] Multi-stage build implementado
- [ ] Laboratório prático concluído