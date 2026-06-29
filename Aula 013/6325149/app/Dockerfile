FROM nginx:alpine

# Remover conteudo padrao do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar arquivos da aplicacao
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/

# Expor porta 80
EXPOSE 80

# Comando padrao do Nginx
CMD ["nginx", "-g", "daemon off;"]
