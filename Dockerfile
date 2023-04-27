FROM nginx:alpine
COPY index.html /usr/share/nginx/html

EXPOSE 4200
EXPOSE 80
EXPOSE 8080