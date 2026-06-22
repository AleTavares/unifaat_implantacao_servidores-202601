FROM nginx:alpine

# Remover conteúdo padrão do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar arquivos da aplicação
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/

# Expor porta 80
EXPOSE 80

# Comando padrão do Nginx
CMD ["nginx", "-g", "daemon off;"]
